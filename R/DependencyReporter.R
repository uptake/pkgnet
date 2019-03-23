#' @title Recursive Package Dependency Reporter
#' @name DependencyReporter
#' @family Network Reporters
#' @family Package Reporters
#' @description This reporter looks at the recursive network of its dependencies
#'    on other packages. This allows a developer to understand how individual
#'    dependencies might lead to a much larger set of dependencies, potentially
#'    informing decisions on including or removing them.
#' @section Class Constructor:
#' \preformatted{DependencyReporter$new()}
#' @inheritSection PackageReporters Class Constructor
#' @inheritSection PackageReporters Public Methods
#' @inheritSection NetworkReporters Public Methods
#' @inheritSection PackageReporters Public Fields
#' @inheritSection NetworkReporters Public Fields
#' @inheritSection PackageReporters Special Methods
#' @examples
#' \donttest{
#'
#' # Instantiate an object
#' reporter <- DependencyReporter$new()
#'
#' # Seed it with a package
#' reporter$set_package("ggplot2")
#'
#' # plot it up
#' reporter$plot_network()
#' }
NULL

#' @importFrom R6 R6Class
#' @importFrom assertthat assert_that is.flag
#' @importFrom utils installed.packages
#' @importFrom tools package_dependencies
#' @importFrom data.table data.table rbindlist setkeyv
#' @importFrom visNetwork visHierarchicalLayout
#' @export
DependencyReporter <- R6::R6Class(
    "DependencyReporter",
    inherit = AbstractGraphReporter,

    public = list(

        initialize = function(dep_types = c("Imports", "Depends"), installed = TRUE){

            # Check inputs
            assertthat::assert_that(
                is.character(dep_types)
                , assertthat::is.flag(installed)
            )

            private$dep_types <- dep_types
            private$installed <- installed
            return(invisible(NULL))
        }
    ),

    active = list(
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_dependency_reporter.Rmd"), package = "pkgnet")
        }
    ),

    private = list(
        # Class of graph to initialize
        # Should be constructor
        graph_class = "DirectedGraph",

        # Default graph viz layout
        private_layout_type = "layout_as_tree",

        dep_types = NULL,
        ignore_packages = NULL,
        installed = NULL,

        extract_nodes = function() {private$extract_nodes_and_edges()},
        extract_edges = function() {private$extract_nodes_and_edges()},
        extract_nodes_and_edges = function(){

            # Check that package has been set
            if (is.null(self$pkg_name)){
                log_fatal('Must set_package() before extracting dependency network.')
            }

            log_info(sprintf('Constructing dependency network for %s', self$pkg_name))

            # Consider only installed packages when building dependency network
            if (private$installed){
                db <- utils::installed.packages(lib.loc = .libPaths())
                if (!is.element(self$pkg_name, db[,1])) {
                    msg <- sprintf('%s is not an installed package. Consider setting installed to FALSE.', self$pkg_name)
                    log_fatal(msg)
                }

                # Otherwise consider all CRAN packages
            } else {
                db <- NULL
            }

            # Recursively search dependencies, terminating search at ignore_package nodes
            allDependencies <- private$recursive_dependencies(
                package = self$pkg_name
                , db = db
            )

            if (is.null(allDependencies) | identical(allDependencies, character(0))){
                msg <- sprintf('Could not resolve dependencies for package %s',self$pkg_name)
                log_warn(msg)

                nodeDT <- data.table::data.table(
                    nodes = self$pkg_name
                    , level = 1
                    ,  horizontal = 0.5
                )

                return(invisible(NULL))
            }

            # Remove ignore_packages from getting constructed again
            allDependencies <- setdiff(allDependencies, private$ignore_packages)

            # Get dependency relationships for all packages
            dependencyList <- tools::package_dependencies(
                allDependencies
                , reverse = FALSE
                , recursive = FALSE
                , db = db
                , which = private$dep_types
            )

            # Get list of dependencies that were not present
            nullList <- Filter(function(x){is.null(x)}, dependencyList)

            if (length(nullList) > 0){
                log_info(paste("For package:"
                               , self$pkg_name
                               , "with dependency types:"
                               , paste(which,collapse = ",")
                               , "could not find dependencies:"
                               , paste(names(nullList), collapse = ",")))
            }

            dependencyList <- Filter(function(x){!is.null(x)}, dependencyList)

            if (identical(names(dependencyList), self$pkg_name)){
                msg <- paste0(
                    "Package '%s' does not have any dependencies in [%s]. If you think this is an error ",
                    "consider adding more dependency types in your definition of DependencyReporter. ",
                    "For example: DependencyReporter$new(dep_types = c('Imports', 'Depends', 'Suggests'))"
                )
                log_fatal(sprintf(msg, self$pkg_name, paste(private$dep_types, collapse = ", ")))
            }

            # If pkg A depends on pkg B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            edges <- data.table::rbindlist(lapply(
                names(dependencyList),
                function(pkgN){
                    data.table::data.table(
                        SOURCE = rep(pkgN, length(dependencyList[[pkgN]]))
                        , TARGET = dependencyList[[pkgN]]
                    )
                }
            ))
            data.table::setkeyv(edges, c('SOURCE', 'TARGET'))
            private$cache$edges <- edges

            # Get and save nodes
            nodes <- data.table::data.table(
                node = unique(
                    c(
                        self$edges[, SOURCE]
                        , self$edges[, TARGET]
                     )
                )
            )
            data.table::setkeyv(nodes, 'node')
            private$cache$nodes <- nodes

            log_info('...done constructing dependency network.')

            return(invisible(NULL))
        },

        recursive_dependencies = function(package, db, seen_packages = NULL) {

            # Case 1: Package is blacklisted by ignore_packages, stop searching
            if (package %in% private$ignore_packages){
                return(c(seen_packages, package))
            }

            # Case 2: If package is already seen (memoization)
            if (package %in% seen_packages){
                return(seen_packages)
            }

            # Case 3: Otherwise, get all of packages dependencies, and call this function recursively
            deps <- unlist(tools::package_dependencies(
                package
                , reverse = FALSE
                , recursive = FALSE
                , db = db
                , which = private$dep_types
            ))

            outPackages <- c(seen_packages, package)

            # Identify new packages to search dependencies for
            newDeps <- setdiff(deps, outPackages)
            for (dep in newDeps) {
                outPackages <- unique(c(
                    outPackages
                    , private$recursive_dependencies(
                        package = dep
                        , db = db
                        , seen_packages = outPackages
                    )
                ))
            }
            return(outPackages)
        }

        , plot_network = function() {
            g <- (
                super$plot_network()
                %>% visNetwork::visHierarchicalLayout(
                        sortMethod = "directed"
                        , direction = "UD")
            )
            return(g)
        }
    ) # /private
)
