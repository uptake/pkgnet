#' @title Function Interdependency Reporter
#' @name FunctionReporter
#' @family Network Reporters
#' @family Package Reporters
#' @description This reporter looks at the network of interdependencies of its
#'    defined functions. Measures of centrality from graph theory can indicate
#'    which function is most important to a package. Combined with unit test
#'    coverage information---also provided by this reporter--- it can be used
#'    as a powerful tool to prioritize test writing.
#' @section Class Constructor:
#' \preformatted{FunctionReporter$new()}
#' @inheritSection PackageReporters Class Constructor
#' @inheritSection PackageReporters Public Methods
#' @inheritSection NetworkReporters Public Methods
#' @inheritSection PackageReporters Public Fields
#' @inheritSection NetworkReporters Public Fields
#' @inheritSection PackageReporters Special Methods
#' @details
#' \subsection{R6 Method Support:}{
#'     R6 classes are supported, with their methods treated as functions by the
#'     reporter.
#'
#'    \itemize{
#'       \item{R6 methods will be named like
#'          \code{<classname>$<methodtype>$<methodname>}, e.g.,
#'          \code{FunctionReporter$private_methods$extract_nodes}.
#'       }
#'       \item{Note that the class name used will be the \strong{name of the
#'          generator object in the package's namespace}.
#'       }
#'       \item{The \code{classname} attribute of the class is \strong{not} used.
#'          In general, it is not required to be defined or the same as the
#'          generator object name. This attribute is used primarily for
#'          S3 dispatch.
#'       }
#'    }
#' }
#' \subsection{Known Limitations:}{
#'    \itemize{
#'        \item{Using non-standard evaluation to refer to things (e.g, dataframe
#'           column names) that have the same name as a function will trick
#'           \code{FunctionReporter} into thinking the function was called. This
#'           can be avoided if you don't use reuse function names for other
#'           purposes.
#'        }
#'        \item{Functions stored as list items and not assigned to the package
#'           namespace will be invisible to \code{FunctionReporter}.
#'        }
#'        \item{Calls to methods of instantiated R6 or reference objects will
#'           not be recognized. We don't have a reliable way of identifying
#'           instantiated objects, or identifying their class.
#'        }
#'        \item{Reference class methods are not yet supported. They will not be
#'           identified as nodes by \code{FunctionReporter}.
#'        }
#'    }
#' }
NULL


#' @importFrom R6 R6Class is.R6Class
#' @importFrom assertthat assert_that is.string
#' @importFrom covr package_coverage
#' @importFrom data.table data.table as.data.table rbindlist setkeyv
#' @importFrom methods is
#' @importFrom visNetwork visHierarchicalLayout
#' @export
FunctionReporter <- R6::R6Class(
    "FunctionReporter",
    inherit = AbstractGraphReporter,

    public = list(

        calculate_default_measures = function() {
            # Calculate test coverage if pkg_path is set and source code available
            if (!is.null(private$pkg_path)){
                private$calculate_test_coverage()
            }

            super$calculate_default_measures()

            return(invisible(self))
        }

    )

    , active = list(

        report_markdown_path = function(){
            system.file(file.path("package_report", "package_function_reporter.Rmd"), package = "pkgnet")
        }

    )

    , private = list(

        # Default graph viz layout
        private_layout_type = "layout_with_graphopt",

        # Class of graph to initialize
        # Should be constructor
        graph_class = "DirectedGraph",

        get_pkg_env = function() {
            if (is.null(private$cache$pkg_env)) {
                # create a custom environment w/ this package's contents
                private$cache$pkg_env <- loadNamespace(self$pkg_name)
            }
            return(private$cache$pkg_env)
        },

        get_pkg_R6_classes = function() {
            if (is.null(private$cache$pkg_R6_classes)) {
                pkg_env <- private$get_pkg_env()
                private$cache$pkg_R6_classes <- Filter(
                    f = function(x, p = pkg_env){
                        R6::is.R6Class(get(x, p))
                    }
                    , x = names(pkg_env)
                )
            }
            return(private$cache$pkg_R6_classes)
        },

        get_pkg_R6_methods = function() {
            if (is.null(private$cache$pkg_R6_methods)){
                private$cache$pkg_R6_methods <- data.table::rbindlist(lapply(
                    X = private$get_pkg_R6_classes()
                    , FUN = function(x, p = private$get_pkg_env()) {
                        .get_R6_class_methods(x, get(x,p))
                    }
                ))
            }
            return(private$cache$pkg_R6_methods)
        },

        get_pkg_R6_inheritance = function() {
            if (is.null(private$cache$pkg_R6_inheritance)) {
                private$cache$pkg_R6_inheritance <- .get_R6_class_inheritance(
                    private$get_pkg_R6_classes()
                    , self$pkg_name
                    , private$get_pkg_env()
                )
            }
            return(private$cache$pkg_R6_inheritance)
        },

        # add coverage to nodes table
        calculate_test_coverage = function(){

            log_info(sprintf("Calculating test coverage for %s...", self$pkg_name))

            pkgCovDT <- data.table::as.data.table(covr::package_coverage(
                path = private$pkg_path
                , type = "tests"
                , combine_types = FALSE
            ))

            pkgCovDT <- pkgCovDT[, .(coveredLines = sum(value > 0)
                                    , totalLines = .N
                                    , coverageRatio = sum(value > 0)/.N
                                    , meanCoveragePerLine = sum(value)/.N
                                    , filename = filename[1]
            )
            , by = .(node = functions)]

            # Update Node with Coverage Info
            private$update_nodes(pkgCovDT)

            # Set Graph to Color By Coverage
            private$set_plot_node_color_scheme(
                field = "coverageRatio"
                # colorbrewer2.org PiYG - Colorblind Safe Palatte
                , palette = c("#e9a3c9"         # Shocking - low values
                              , "#f7f7f7"       # White Smoke - mid range values
                              , "#a1d76a"       # Feijoa - high values
                              )
            )

            meanCoverage <-  pkgCovDT[, sum(coveredLines, na.rm = TRUE) / sum(totalLines, na.rm = TRUE)]
            private$cache$network_measures[['packageTestCoverage.mean']] <- meanCoverage

            betweennessDT <- self$pkg_graph$node_measures('betweenness')

            weightedCoverageDT <- merge(x = pkgCovDT
                                        , y = betweennessDT
                                        , by = 'node')
            weightedCoverageDT[, weight := betweenness / sum(betweenness, na.rm = TRUE)]

            betweenness_mean <- weightedCoverageDT[,
                weighted.mean(
                    x = coverageRatio
                    , w = weight
                    , na.rm = TRUE
            )]
            private$cache$network_measures[['packageTestCoverage.betweenessWeightedMean']] <- betweenness_mean

            log_info(msg = "...done calculating test coverage.")
            return(invisible(NULL))
        },

        extract_nodes = function() {
            if (is.null(self$pkg_name)) {
                log_fatal('Must set_package() before extracting nodes.')
            }

            log_info(sprintf('Extracting functions from %s as graph nodes...'
                             , self$pkg_name))

            pkg_env <- private$get_pkg_env()

            ## FUNCTIONS ##

            # Filter objects in package environment to just functions
            # This will now be a character vector full of function names
            funs <- Filter(
                f = function(x, p = pkg_env){
                    (is.function(get(x, p))
                        # Exclude Reference Class object generators for now
                        & !methods::is(get(x, p), "refObjectGenerator")
                    )
                }
                , x = names(pkg_env)
            )

            # Create nodes data.table
            nodes <- data.table::data.table(
                node = funs
                , type = "function"
            )

            # Figure out which functions are exported
            # We need the package to be loaded first
            suppressPackageStartupMessages({
                require(self$pkg_name
                        , lib.loc = .libPaths()[1]
                        , character.only = TRUE)
            })
            exported_obj_names <- ls(sprintf("package:%s", self$pkg_name))
            nodes[, isExported := node %in% exported_obj_names]

            # Check if we have R6 functions
            if (length(private$get_pkg_R6_classes()) > 0) {
                r6DT <- private$get_pkg_R6_methods()[, .(
                    node = paste(CLASS_NAME, METHOD_TYPE, METHOD_NAME, sep = "$")
                    , type = "R6 method"
                    , isExported = CLASS_NAME %in% exported_obj_names
                )]

                nodes <- data.table::rbindlist(list(nodes, r6DT))
            }

            data.table::setkeyv(nodes, 'node')

            private$cache$nodes <- nodes

            log_info(sprintf('... done extracting functions as nodes.'
                             , self$pkg_name))

            return(invisible(nodes))
        },

        extract_edges = function(){
            if (is.null(self$pkg_name)) {
                log_fatal('Must set_package() before extracting edges.')
            }

            log_info(paste(
                sprintf('Extracting dependencies between functions in %s', self$pkg_name)
                , "as graph edges..."
            ))

            # create a custom environment w/ this package's contents
            pkg_env <- private$get_pkg_env()

            ### FUNCTIONS ###

            # Get table of edges between functions
            # for each function, check if anything else in the package
            # was called by it
            funs <- self$nodes[type == "function", node]
            edgeDT <- data.table::rbindlist(
                lapply(
                    X = funs
                    , FUN = .called_by
                    , all_functions = funs
                    , pkg_env = pkg_env
                )
                , fill = TRUE
            )

            ### R6 METHODS ###
            if (length(private$get_pkg_R6_classes()) > 0) {
                edgeDT <- data.table::rbindlist(c(
                    list(edgeDT)
                    , mapply(
                        FUN = .determine_R6_dependencies
                        , method_name = private$get_pkg_R6_methods()[, METHOD_NAME]
                        , method_type = private$get_pkg_R6_methods()[, METHOD_TYPE]
                        , class_name = private$get_pkg_R6_methods()[, CLASS_NAME]
                        , MoreArgs = list(
                            methodsDT = private$get_pkg_R6_methods()
                            , inheritanceDT = private$get_pkg_R6_inheritance()
                            , pkg_env = private$get_pkg_env()
                            , pkg_functions = funs
                            )
                        )
                    )
                    , fill = TRUE
                )
            }

            # If there are no edges, we still want to return a length-zero
            # data.table with correct columns
            if (nrow(edgeDT) == 0) {
                log_info("Edge list is empty.")
                edgeDT <- data.table::data.table(
                                SOURCE = character()
                                , TARGET = character()
                            )
            }

            data.table::setkeyv(edgeDT, c('SOURCE', 'TARGET'))

            log_info("...done extracting function dependencies as edges.")

            private$cache$edges <- edgeDT

            return(invisible(edgeDT))
        }

        , plot_network = function() {
            g <- (
                super$plot_network()
                %>% visNetwork::visHierarchicalLayout(enabled = FALSE)
            )
            return(g)
        }
    )
)

# [description] given a function name, return edgelist of
#               all other functions it calls
#' @importFrom assertthat is.string
#' @importFrom data.table data.table
.called_by <- function(fname, all_functions, pkg_env){

    assertthat::assert_that(
        is.environment(pkg_env)
        , is.character(all_functions)
        , assertthat::is.string(fname)
    )

    # Get only the body of the function
    # We will potentially miss calls if they are in attributes of the closure,
    # e.g., the way the decorators package implements decorators
    f <- body(get(fname, envir = pkg_env))

    # get the literal code of the function
    f_vec <- .parse_function(f)

    # Figure out which ones mix
    matches <- match(
        x = f_vec
        , table = all_functions
        , nomatch = 0
    )
    matches <- matches[matches > 0]

    if (length(matches) == 0){
        return(invisible(NULL))
    }

    # Convention: If A depends on B, then A is the SOURCE
    # and B is the TARGET so that it looks like A -> B
    # This is consistent with the UML dependency convention
    # fname calls <matches>. So fname depends on <matches>.
    # So fname is SOURCE and <matches> are TARGETs
    edgeDT <- data.table::data.table(
        SOURCE = fname
        , TARGET = unique(all_functions[matches])
    )

    return(edgeDT)
}

# [description] parse out a function's body into a character
#               vector separating the individual symbols
.parse_function <- function (x) {
    # If expression x is not an atomic value or symbol (i.e., name of object) or
    # an environment pointer then we can break x up into list of components
    listable <- (!is.atomic(x) && !is.symbol(x) && !is.environment(x))
    if (!is.list(x) && listable) {
        x <- as.list(x)

        # Check for expression of the form foo$bar
        # We still want to split it up because foo might be a function
        # but we want to get rid of bar, because it's a symbol in foo's namespace
        # and not a symbol that could be reliably matched to the package namespace
        if (identical(x[[1]], quote(`$`))) {
            x <- x[1:2]
        }
    }



    if (listable){
        # Filter out atomic values because we don't care about them
        x <- Filter(f = Negate(is.atomic), x = x)

        # Parse each listed expression recursively until
        # they can't be listed anymore
        out <- unlist(lapply(x, .parse_function), use.names = FALSE)
    } else {

        # If not listable, deparse into a character string
        out <- paste(deparse(x), collapse = "\n")
    }
    return(out)
}

# [description] given an R6 class, returns a data.table
# enumerating all of its public, active binding, and private methods
#' @importFrom assertthat assert_that
#' @importFrom R6 is.R6Class
.get_R6_class_methods <- function(className, classGenerator) {
    assertthat::assert_that(
        assertthat::is.string(className)
        , R6::is.R6Class(classGenerator)
    )

    method_types <- c('public_methods', 'active', 'private_methods')

    methodsDT <- data.table::rbindlist(do.call(
        c,
        lapply(method_types, function(mtype) {
            lapply(names(classGenerator[[mtype]]), function(mname) {
                list(METHOD_TYPE = mtype, METHOD_NAME = mname)
            })
        })
    ))
    methodsDT[, CLASS_NAME := className]

    return(methodsDT)
}

# [description] given a list of R6 class names and the associated package
# environment, return a data.table of their parent classes
#' @importFrom data.table rbindlist
.get_R6_class_inheritance <- function(class_names, pkg_name, pkg_env) {
    inheritanceDT <- data.table::rbindlist(lapply(
        X = class_names
        , FUN = function(x, p = pkg_env) {
            parentClassName <- deparse(get(x, p)$inherit)
            parentClassGenerator <- get(x, p)$get_inherit()
            return(list(
                CLASS_NAME = x
                , PARENT_NAME = if (!is.null(parentClassGenerator)) {
                        parentClassName
                    } else {
                        NA_character_
                    }
                , PARENT_IN_PKG = (pkg_name == environmentName(parentClassGenerator$parent_env))
            ))
        }
    ))
}

# [description] given an R6 method, parse its body and find all
# dependencies that it calls, returning as a pkgnet edge data.table
#' @importFrom data.table data.table
.determine_R6_dependencies <- function(method_name
                                       , method_type
                                       , class_name
                                       , methodsDT
                                       , inheritanceDT
                                       , pkg_env
                                       , pkg_functions
) {
    # Get body of method
    mbody <- body(get(class_name, envir = pkg_env)[[method_type]][[method_name]])

    # Parse into symbols
    mbodyDT <- data.table::data.table(
        SYMBOL = unique(.parse_R6_expression(mbody))
    )

    # Match to R6 methods
    mbodyDT[grepl('(^self\\$|^private\\$)', SYMBOL)
            , MATCH := vapply(X = SYMBOL
                              , FUN = .match_R6_class_methods
                              , FUN.VALUE = character(1)
                              , class_name = class_name
                              , methodsDT = methodsDT
                              , inheritanceDT = inheritanceDT
            )]

    # Match to R6 superclass methods. This has a different recursion strategy
    mbodyDT[grepl('(^super\\$)', SYMBOL)
            , MATCH := vapply(X = unlist(strsplit(
                                        SYMBOL, split = "$", fixed = TRUE
                                    ))[[2]]
                              , FUN = .match_R6_super_methods
                              , FUN.VALUE = character(1)
                              , parent_name = inheritanceDT[CLASS_NAME == class_name
                                                                , PARENT_NAME]
                              , methodsDT = methodsDT
                              , inheritanceDT = inheritanceDT
            )]

    # Match to functions in package
    mbodyDT[!grepl('(^self\\$|^private\\$)', SYMBOL)
            & is.na(MATCH)
            & SYMBOL %in% pkg_functions
            , MATCH := SYMBOL
            ]

    if (nrow(mbodyDT[!is.na(MATCH)]) == 0) {
        return(NULL)
    }

    # Convention: If A depends on B, then A is the SOURCE
    # and B is the TARGET so that it looks like A -> B
    # This is consistent with the UML dependency convention.
    # The method calls the MATCHes, so method is SOURCE and
    # the MATCHes are the TARGETs
    edgeDT <- data.table::data.table(
        SOURCE = paste(class_name, method_type, method_name, sep = "$")
        , TARGET = unique(mbodyDT[!is.na(MATCH), MATCH])
    )

    return(edgeDT)
}


# [description] given a symbol name that is an R6 internal reference
# (self$x or private$x), match to a provided data.table of known R6 methods.
# Searches up inheritance tree.
#' @importFrom assertthat assert_that
.match_R6_class_methods <- function(symbol_name, class_name, methodsDT, inheritanceDT) {
    # Check if symbol matches method in this class
    splitSymbol <- unlist(strsplit(symbol_name, split = "$", fixed = TRUE))
    assertthat::assert_that(splitSymbol[1] %in% c('self', 'private'))
    if (splitSymbol[1] == "self") {
        out <- methodsDT[CLASS_NAME == class_name
                         & METHOD_TYPE %in% c("public_methods", "active")
                         & splitSymbol[2] == METHOD_NAME
                         , paste(CLASS_NAME, METHOD_TYPE, METHOD_NAME, sep = "$")
                         ]
    } else if (splitSymbol[1] == "private") {
        out <- methodsDT[CLASS_NAME == class_name
                         & METHOD_TYPE == "private_methods"
                         & splitSymbol[2] == METHOD_NAME
                         , paste(CLASS_NAME, METHOD_TYPE, METHOD_NAME, sep = "$")
                         ]
    }

    # Above returns character(0) if not matched. Convert to NA_character
    if (identical(out, character(0))) {
        out <- NA_character_
    }

    # Not not matched, try parent if there is one and it is in package
    if (is.na(out)
        && inheritanceDT[CLASS_NAME == class_name
                         , !is.na(PARENT_NAME) && PARENT_IN_PKG]) {
        out <- .match_R6_class_methods(
            symbol_name
            , inheritanceDT[CLASS_NAME == class_name, PARENT_NAME]
            , methodsDT
            , inheritanceDT
        )
    }

    # We should only have at most one match
    assertthat::assert_that(
        assertthat::is.string(out)
    )

    return(out)
}


# [description] given a symbol name that is an internal reference to a superclass
# method (super$<method_name>), match to a provided data.table of known R6 methods
# by checking searching ancestor classes. We need this as a separate function because
# super$method_name calls don't specify public, private, or active.
# So we have to search all three for a parent class before moving up
# to the next parent class. Luckily, within one class definition you're not allowed
# to name things the same so we should only have one result.
#' @importFrom assertthat assert_that is.string
.match_R6_super_methods <- function(method_name, parent_name, methodsDT, inheritanceDT) {

    out <- methodsDT[CLASS_NAME == parent_name
                     & method_name == METHOD_NAME
                     , paste(CLASS_NAME, METHOD_TYPE, METHOD_NAME, sep = "$")
                     ]

    # Above returns character(0) if not matched. Convert to NA_character
    if (identical(out, character(0))) {
        out <- NA_character_
    }

    # If not matched, try parent if there is one and it is in package
    if (is.na(out)
        && inheritanceDT[CLASS_NAME == parent_name
                         , !is.na(PARENT_NAME) && PARENT_IN_PKG]) {
        out <- .match_R6_super_methods(
            method_name
            , inheritanceDT[CLASS_NAME == parent_name, PARENT_NAME]
            , methodsDT
            , inheritanceDT
        )
    }

    # We should only have at most one match
    assertthat::assert_that(
        assertthat::is.string(out)
    )

    return(out)
}


# [description] parses R6 expressions into a character vector of symbols and atomic
# values. Will not break up expressions of form self$foo, private$foo, or super$foo
.parse_R6_expression <- function(x) {

    # If expression x is not an atomic value or symbol (i.e., name of object) or
    # an environment pointer then we can break x up into list of components
    listable <- (!is.atomic(x) && !is.symbol(x) && !is.environment(x))

    if (!is.list(x) && listable) {
        xList <- as.list(x)

        # Check if expression x is from _$_
        if (identical(xList[[1]], quote(`$`))) {

            # Check if expression x is of form self$foo, private$foo, or super$foo
            # We want to keep those together because they could refer to the class'
            # methods. So expression is not listable
            if (identical(xList[[2]], quote(self))
                || identical(xList[[2]], quote(private))
                || identical(xList[[2]], quote(super))) {
                listable <- FALSE

            # If expression lefthand side is not keyword, we still want to split
            # it up because left might be a function
            # but we want to get rid of right, because it's a symbol in left's namespace
            # and not a symbol that could be reliably matched to the package namespace
            } else {
                x <- xList
                x <- x[1:2]
            }

        # Otherwise list as usual
        } else {
            x <- xList
        }
    }

    if (listable){
        # Filter out atomic values because we don't care about them
        x <- Filter(f = Negate(is.atomic), x = x)

        # Parse each listed expression recursively until
        # they can't be listed anymore
        out <- unlist(lapply(x, .parse_R6_expression), use.names = FALSE)
    } else {
        # If not listable, deparse into a character string
        out <- paste(deparse(x), collapse = "\n")
    }
    return(out)
}

