#' @title Package Dependency Reporter Class
#' @name DependencyReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other package dependencies, determining which package it relies on is most central,
#'              allowing for a developer to determine how to vet its dependency tree
#' @importFrom data.table data.table setnames rbindlist
#' @importFrom R6 R6Class
#' @importFrom utils installed.packages
#' @importFrom tools package_dependencies
#' @export
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
DependencyReporter <- R6::R6Class(
    "DependencyReporter",
    inherit = AbstractGraphReporter,

    #TODO [patrick.boueri@uptake.com]: Add more robust error checks and logging
    #TODO [patrick.boueri@uptake.com]: Add version information to dependency structure

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
        },

        get_summary_view = function(){
            
            # Calculate network measures if not already done
            # since we want the node measures in summary
            invisible(self$network_measures)
            
            # Create DT for display
            tableObj <- DT::datatable(
                data = self$nodes
                , rownames = FALSE
                , options = list(
                    searching = FALSE
                    , pageLength = 50
                    , lengthChange = FALSE
                )
            )
            # Round the double columns to three digits for formatting reasons
            numCols <- names(which(unlist(lapply(tableObj$x$data, is.double))))
            tableObj <- DT::formatRound(columns = numCols, table = tableObj
                                        , digits=3)
            return(tableObj)
        }

    ),

    active = list(
        edges = function(){
            if (is.null(private$cache$edges)){
                log_info("Calling extract_network() with default arguments...")
                private$extract_network()
            }
            return(private$cache$edges)
        },
        nodes = function(){
            if (is.null(private$cache$nodes)){
                log_info("Calling extract_network() with default arguments...")
                private$extract_network()
            }
            return(private$cache$nodes)
        },
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_dependency_reporter.Rmd"), package = "pkgnet")
        }
    ),

    private = list(

        dep_types = NULL,
        ignore_packages = NULL,
        installed = NULL,
        extract_network = function(){

            # Check that package has been set
            if (is.null(self$pkg_name)){
                log_fatal('Must set_package() before extracting dependency network.')
            }

            # Reset cache, because any cached stuff will be outdated with a new package
            private$reset_cache()

            log_info(sprintf('Constructing reverse dependency graph for %s', self$pkg_name))

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

            edges <- data.table::rbindlist(lapply(
                names(dependencyList),
                function(pkgN){
                    data.table::data.table(
                        SOURCE = dependencyList[[pkgN]]
                        , TARGET = rep(pkgN,length(dependencyList[[pkgN]]))
                    )
                }
            ))

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
            private$cache$nodes <- nodes

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
    )
)
