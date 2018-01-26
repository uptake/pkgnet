#' @title Package Dependency Reporter Class
#' @name PackageDependencyReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other package dependencies, determining which package it relies on is most central,
#'              allowing for a developer to determine how to vet its dependency tree
#' @section Public Methods:
#' \describe{
#'     \item{\code{extract_network(which = "Imports", installed = TRUE, ignorePackages = NULL)}}{
#'         \itemize{
#'             \item{This function maps a package's reverse dependency
#'                   network, allowing for analysis of a package's imports}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{depTypes}}: a character vector passed on to \code{which} argument of
#'                     \link[tools]{package_dependencies} indicating what to count
#'                     as a package dependency. Default is "Imports".}
#'                 \item{\bold{\code{installed}}: a boolean whether to consider installed
#'                     packages or CRAN packages. default is TRUE. FALSE is useful if you 
#'                     would like to vet a package before adding it as a dependency}
#'                 \item{\bold{\code{ignorePackages}}: a vector of package names to ignore 
#'                     in dependency analysis. They will show up if a package depends on them
#'                     but their dependencies will be ignored. Useful if you know certain packages
#'                     are required and have and have a large number of dependencies that clutter
#'                     the analysis.}
#'             }
#'         }
#'         \item{\bold{Returns: a list with}}{
#'             \itemize{
#'                 \item{\bold{\code{edges}}: A data.table of directed edges from SOURCE package to TARGET package}
#'                 \item{\bold{\code{nodes}}: A data.table of nodes, where each node is a package}
#'             }
#'         }
#'     }
#'   }
#' }
#' 
#' @importFrom data.table data.table setnames rbindlist
#' @importFrom R6 R6Class
#' @importFrom utils installed.packages
#' @importFrom tools package_dependencies
#' @export
PackageDependencyReporter <- R6::R6Class(
    "PackageDependencyReporter",
    inherit = AbstractGraphReporter,
    
    #TODO [patrick.boueri@uptake.com]: Add more robust error checks and logging
    #TODO [patrick.boueri@uptake.com]: Add version information to dependency structure

    public = list(
        
        extract_network = function(depTypes = "Imports", installed = TRUE, ignorePackages = NULL){
            
            # Check that package has been set
            if (is.null(private$packageName)){
                log_fatal('Must set_package() before extracting dependency network.')
            }
            
            # Reset cache, because any cached stuff will be outdated with a new package
            private$reset_cache()
            
            log_info(sprintf('Constructing reverse dependency graph for %s', private$packageName))
            
            # Consider only installed packages when building dependency network
            if (installed){
                db <- utils::installed.packages()
                if (!is.element(private$packageName, db[,1])) {
                    msg <- sprintf('%s is not an installed package. Consider setting installed to FALSE.', private$packageName)
                    log_fatal(msg)
                }
                
            # Otherwise consider all CRAN packages
            }else{
                db <- NULL
            }
            
            # Recursively search dependencies, terminating search at ignorePackage nodes
            allDependencies <- private$recursive_dependencies(package = private$packageName
                                                              , db = db
                                                              , depTypes = depTypes
                                                              , ignorePackages = ignorePackages
                                                              )
            
            if (is.null(allDependencies) | identical(allDependencies, character(0))){
                msg <- sprintf('Could not resolve dependencies for package %s',private$packageName)
                log_warn(msg)
                nodeDT <- data.table::data.table(nodes = private$packageName, level = 1,  horizontal = 0.5)
                return(list(nodes = nodeDT, edges = list(), networkMeasures = list()))
            }
            
            # Remove ignorePackages from getting constructed again
            allDependencies <- setdiff(allDependencies, ignorePackages)
            
            # Get dependency relationships for all packages
            dependencyList <- tools::package_dependencies(allDependencies
                                                          , reverse = FALSE
                                                          , recursive = FALSE
                                                          , db = db
                                                          , which = depTypes)
            
            
            nullList <- Filter(function(x){is.null(x)},dependencyList)
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
                    data.table::data.table(SOURCE = dependencyList[[pkgN]], 
                                           TARGET = rep(pkgN,length(dependencyList[[pkgN]])))
                    }
                ))
            
            private$cache$edges <- edges
            
            # Get and save nodes
            nodes = data.table::data.table(node = unique(c(self$edges[, SOURCE], self$edges[, TARGET])))
            private$cache$nodes <- nodes
            
            return(list(edges = edges, nodes = nodes))
        },
        
        calculate_all_metrics = function(...) {
            # Check if we need to re-extract network
            private$parse_extract_args(list(...))
            
            metricsList <- list()
            
            # Calculate network measures
            metricsList <- c(metricsList, self$calculate_network_measures())
            
            return(metricsList)
        }
        
        
    ),
    
    active = list(
        nodes = function(){
            if (is.null(private$cache$nodes)){
                log_info("Calling extract_network() with default arguments...")
                invisible(self$extract_network())
            }
            return(private$cache$nodes)
        },
        edges = function(){
            if (is.null(private$cache$edges)){
                log_info("Calling extract_network() with default arguments...")
                invisible(self$extract_network())
            }
            return(private$cache$edges)
        }
    ),
    
    private = list(
        recursive_dependencies = function(package, db, depTypes, ignorePackages, seenPackages = NULL) {
            
            # Case 1: Package is blacklisted by ignorePackages, stop searching
            if (package %in% ignorePackages){
                return(c(seenPackages, package))
            }

            # Case 2: If package is already seen (memoization)
            if (package %in% seenPackages){
                return(seenPackages)
            }
            
            # Case 3: Otherwise, get all of packages dependencies, and call this function recursively
            deps <- unlist(tools::package_dependencies(package
                                                       , reverse = FALSE
                                                       , recursive = FALSE
                                                       , db = db
                                                       , which = depTypes))
            outPackages <- c(seenPackages, package)
            
            # Identify new packages to search dependencies for
            newDeps <- setdiff(deps, outPackages)
            for (dep in newDeps) {
                outPackages <- unique(c(outPackages
                                        , private$recursive_dependencies(package = dep, db = db
                                                                         , depTypes = depTypes
                                                                         , ignorePackages = ignorePackages
                                                                         , seenPackages = outPackages)
                ))
            }
            return(outPackages)
            
        }
    )
)
