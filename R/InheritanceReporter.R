#' @title Class Inheritance Reporter
#' @name InheritanceReporter
#' @family Network Reporters
#' @family Package Reporters
#' @description This reporter takes a package and traces the class inheritance
#'   structure. Currently the following object-oriented systems are supported:
#'   \itemize{
#'       \item{S4 Classes}
#'       \item{Reference Classes (sometimes informally called "R5")}
#'       \item{R6 Classes}
#'   }
#'   S3 classes are not supported, as their inheritance is defined on an ad hoc
#'   basis per object and not formally by class definitions.
#' @section Class Constructor:
#' \preformatted{InheritanceReporter$new()}
#' @inheritSection PackageReporters Class Constructor
#' @inheritSection PackageReporters Public Methods
#' @inheritSection NetworkReporters Public Methods
#' @inheritSection PackageReporters Public Fields
#' @inheritSection NetworkReporters Public Fields
#' @inheritSection PackageReporters Special Methods
#' @details Note the following details about class naming:
#'   \itemize{
#'       \item{Reference Classes : The name passed as \code{Class} in
#'       \code{\link[methods:ReferenceClasses]{setRefClass}} is used as the node
#'       name by this reporter. This is the class name that is used when
#'       specifying inheritance. The generator object returned by
#'       \code{\link[methods:ReferenceClasses]{setRefClass}} does not have to be
#'       assigned and can have a different name.}
#'       \item{R6 Classes : The name of the generator object in the package
#'       namespace is used as the node name by this reporter. The generator
#'       object returned by \code{\link[R6:R6Class]{R6::R6Class}} is what is
#'       used when specifying inheritance. The name passed as \code{classname}
#'       passed to \code{\link[R6:R6Class]{R6::R6Class}} can be a different name
#'       or even NULL.}
#'  }
#'
#'   For more info about R's built-in object-oriented systems, check out the
#'   relevant chapter in \href{http://adv-r.had.co.nz/OO-essentials.html}{Hadley
#'   Wickham's \emph{Advanced R}}. For more info about R6, check out their
#'   \href{https://r6.r-lib.org/index.html}{docs website} or the chapter in
#'   \href{https://adv-r.hadley.nz/r6.html}{\emph{Advanced R}'s second edition}.
NULL

#' @importFrom R6 R6Class is.R6Class
#' @importFrom data.table data.table rbindlist setkeyv
#' @importFrom methods is
#' @importFrom visNetwork visHierarchicalLayout
#' @export
InheritanceReporter <- R6::R6Class(
    "InheritanceReporter"
    , inherit = AbstractGraphReporter

    , active = list(
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_inheritance_reporter.Rmd"), package = "pkgnet")
        }
    ) # /active

    , private = list(
        # Class of graph to initialize
        # Should be constructor
        graph_class = "DirectedGraph"

        # Default graph viz layout
        , private_layout_type = "layout_as_tree"

        # Default color scheme for graph viz
        , plotNodeColorScheme = list(
            field = "classType"
            , palette = c('#f0f9e8', '#bae4bc', '#7bccc4')
        )

        , extract_nodes = function() {
            log_info(sprintf("Extracting classes in %s as nodes...", self$pkg_name))

            pkg_env <- private$get_pkg_env()

            # Start with empty node data.table
            nodeList <- list(data.table::data.table(
                node = character(0), classType = character(0)
            ))

            for (thisObjName in names(pkg_env)) {

                thisObj <- get(thisObjName, pkg_env)

                # S4 classes and References classes
                # Specified class name is the important name
                if (grepl("^\\.__C__", thisObjName) & isS4(thisObj)) {

                    thisObjClassType <- "S4"
                    if (methods::is(thisObj, "refClassRepresentation")) {
                        thisObjClassType <- "Reference"
                    }

                    nodeList <- c(nodeList, list(data.table::data.table(
                        node = thisObj@className
                        , classType = thisObjClassType
                    )))

                    # R6 classes
                    # Generator object name is the important name
                } else if (R6::is.R6Class(thisObj)) {

                    nodeList <- c(nodeList, list(data.table::data.table(
                        node = thisObjName
                        , classType = "R6"
                    )))

                }

                # If not any of the class types, do nothing
            }

            # Bind all rows together into one data.table
            nodeDT <- data.table::rbindlist(nodeList)

            if (nrow(nodeDT) == 0) {
                msg <- sprintf(
                    'No S4, Reference, or R6 class definitions found in package %s'
                    , self$pkg_name
                )
                log_warn(msg)
            }

            data.table::setkeyv(nodeDT, 'node')

            log_info("...done extracting classes as nodes.")

            private$cache$nodes <- nodeDT
            return(invisible(NULL))
        }

        # Edge direction convention is per UML class diagrams
        # Child class is the SOURCE and Parent class is the TARGET
        , extract_edges = function() {

            nodeDT <- self$nodes

            log_info(sprintf(
                "Extracting class inheritance within %s as edges...", self$pkg_name
            ))

            pkg_env <- private$get_pkg_env()
            edgeList <- list(data.table::data.table(
                SOURCE = character(0)
                , TARGET = character(0)
            ))
            for (thisNode in nodeDT[, node]) {

                # S4 or Reference Class
                if (nodeDT[node == thisNode, classType %in% c("S4" ,"Reference")]) {
                    classDef <- getClass(thisNode, where = pkg_env)
                    parents <- setdiff(
                        selectSuperClasses(classDef, direct = TRUE, namesOnly = TRUE)
                        , "envRefClass" # Base class defined by R that all reference classes inherit
                    )
                    if (length(parents) > 0) {
                        edgeList <- c(
                            edgeList
                            , list(data.table::data.table(
                                SOURCE = thisNode
                                , TARGET = parents
                            ))
                        )
                    }

                    # R6 Class
                } else if (nodeDT[node == thisNode, classType == "R6"]) {
                    classDef <- get(thisNode, pkg_env)
                    parent <- classDef$inherit
                    if (!is.null(parent)) {
                        edgeList <- c(
                            edgeList
                            , list(data.table::data.table(
                                SOURCE = thisNode
                                , TARGET = deparse(parent)
                            ))
                        )
                    }
                }
            }

            # Combine all edges together
            edgeDT <- data.table::rbindlist(edgeList)

            # Filter out any parents that are external to the package
            edgeDT <- edgeDT[TARGET %in% nodeDT[, node]]

            data.table::setkeyv(edgeDT, c('SOURCE', 'TARGET'))

            log_info("...done extracting class inheritance as edges.")

            private$cache$edges <- edgeDT
            return(invisible(NULL))
        } # /extract_edges

        , get_pkg_env = function() {
            if (is.null(private$cache$pkg_env)) {
                # create a custom environment w/ this package's contents
                private$cache$pkg_env <- loadNamespace(self$pkg_name)
            }
            return(private$cache$pkg_env)
        }

        , plot_network = function() {
            g <- (
                super$plot_network()
                %>% visNetwork::visHierarchicalLayout(
                    sortMethod = "directed"
                    , direction = "DU")
            )
            return(g)
        }
    ) # /private

)
