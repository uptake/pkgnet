#' @title Package Dependency Reporter Class
#' @name PackageDependencyReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other package dependencies, determining which package it relies on is most central,
#'              allowing for a developer to determine how to vet its dependency tree
#' @section Public Methods:
#' \describe{
#'    
#'    \itemize{
#'         \item{\code{plot_network()}}{
#'             \itemize{
#'                 \item{Creates a network visualization of extracted package graph.}
#'                 \item{\bold{Returns:}}{
#'                     \itemize{
#'                         \item{A `visNetwork` object}
#'                    }
#'                 }
#'             }
#'        }
#'    }
#'     
#'     \item{\code{set_package(packageName, packagePath = NULL)}}{
#'         \itemize{
#'             \item{Set properties of this reporter. If packageName overrides a 
#'                 previously-set package name, any cached data will be removed.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{packageName}}: String with the name of the package}
#'                 \item{\bold{\code{packagePath}}: Optional path to the source code. 
#'                     To be used for test coverage, if provided.}
#'                }
#'             }
#'         }
#'     }
#' }
#' 
#' @importFrom data.table data.table setnames rbindlist
#' @importFrom R6 R6Class
#' @importFrom utils installed.packages
#' @importFrom tools package_dependencies
#' @export
#' @examples 
#' \donttest{
#' 
#' # Instantiate an object
#' reporter <- PackageDependencyReporter$new()
#' 
#' # Seed it with a package
#' reporter$set_package("ggplot2")
#' 
#' # plot it up
#' reporter$plot_network()
#' }
PackageDependencyReporter <- R6::R6Class(
    "PackageDependencyReporter",
    inherit = AbstractGraphReporter,
    
    #TODO [patrick.boueri@uptake.com]: Add more robust error checks and logging
    #TODO [patrick.boueri@uptake.com]: Add version information to dependency structure

    public = list(
        
        initialize = function(depTypes = "Imports", installed = TRUE){
            
            # Check inputs
            assertthat::assert_that(
                assertthat::is.string(depTypes)
                , assertthat::is.flag(installed)
            )
            
            private$depTypes <- depTypes
            private$installed <- installed
            return(invisible(NULL))
        },
        
        get_summary_view = function(){
          tableObj <- DT::datatable(
            data = self$nodes
            , rownames = FALSE
            , options = list(
              searching = FALSE
              , pageLength = 50
              , lengthChange = FALSE
            )
          )
          return(tableObj)
        }
        
    ),
    
    active = list(
        edges = function(){
            if (is.null(private$cache$edges)){
                log_info("Calling extract_network() with default arguments...")
                private$extract_network()
                private$calculate_network_measures()
            }
            return(private$cache$edges)
        },
        nodes = function(){
            if (is.null(private$cache$nodes)){
                log_info("Calling extract_network() with default arguments...")
                private$extract_network()
                private$calculate_network_measures()
            }
            return(private$cache$nodes)
        },
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_dependency_reporter.Rmd"), package = "pkgnet")
        }
    ),
    
    private = list(
        
        depTypes = NULL,
        ignorePackages = NULL,
        installed = NULL,
        extract_network = function(){
            
            # Check that package has been set
            if (is.null(private$packageName)){
                log_fatal('Must set_package() before extracting dependency network.')
            }
            
            # Reset cache, because any cached stuff will be outdated with a new package
            private$reset_cache()
            
            log_info(sprintf('Constructing reverse dependency graph for %s', private$packageName))
            
            # Consider only installed packages when building dependency network
            if (private$installed){
                db <- utils::installed.packages()
                if (!is.element(private$packageName, db[,1])) {
                    msg <- sprintf('%s is not an installed package. Consider setting installed to FALSE.', private$packageName)
                    log_fatal(msg)
                }
                
                # Otherwise consider all CRAN packages
            } else {
                db <- NULL
            }
            
            # Recursively search dependencies, terminating search at ignorePackage nodes
            allDependencies <- private$recursive_dependencies(
                package = private$packageName
                , db = db
            )
            
            if (is.null(allDependencies) | identical(allDependencies, character(0))){
                msg <- sprintf('Could not resolve dependencies for package %s',private$packageName)
                log_warn(msg)
                
                nodeDT <- data.table::data.table(
                    nodes = private$packageName
                    , level = 1
                    ,  horizontal = 0.5
                )
                
                return(invisible(NULL))
            }
            
            # Remove ignorePackages from getting constructed again
            allDependencies <- setdiff(allDependencies, private$ignorePackages)
            
            # Get dependency relationships for all packages
            dependencyList <- tools::package_dependencies(
                allDependencies
                , reverse = FALSE
                , recursive = FALSE
                , db = db
                , which = private$depTypes
            )
            
            # Get list of dependencies that were not present
            nullList <- Filter(function(x){is.null(x)}, dependencyList)
            
            if (length(nullList) > 0){
                log_info(paste("For package:"
                               , private$packageName
                               , "with dependency types:"
                               , paste(which,collapse = ",")
                               , "could not find dependencies:"
                               , paste(names(nullList), collapse = ",")))
            }
            
            dependencyList <- Filter(function(x){!is.null(x)}, dependencyList)
            
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
            nodes <- data.table::data.table(node = unique(c(self$edges[, SOURCE]
                                                            , self$edges[, TARGET])))
            private$cache$nodes <- nodes
            
            return(invisible(NULL))
        },
        
        recursive_dependencies = function(package, db, seenPackages = NULL) {
            
            # Case 1: Package is blacklisted by ignorePackages, stop searching
            if (package %in% private$ignorePackages){
                return(c(seenPackages, package))
            }

            # Case 2: If package is already seen (memoization)
            if (package %in% seenPackages){
                return(seenPackages)
            }
            
            # Case 3: Otherwise, get all of packages dependencies, and call this function recursively
            deps <- unlist(tools::package_dependencies(
                package
                , reverse = FALSE
                , recursive = FALSE
                , db = db
                , which = private$depTypes
            ))
            
            outPackages <- c(seenPackages, package)
            
            # Identify new packages to search dependencies for
            newDeps <- setdiff(deps, outPackages)
            for (dep in newDeps) {
                outPackages <- unique(c(
                    outPackages
                    , private$recursive_dependencies(
                        package = dep
                        , db = db
                        , seenPackages = outPackages
                    )
                ))
            }
            return(outPackages)
        }
    )
)
