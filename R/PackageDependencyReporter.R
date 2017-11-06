#' @title Package Dependency Reporter Class
#' @name PackageDependencyReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other package dependencies, determining which package it relies on is most central,
#'              allowing for a developer to determine how to vett its dependency tree
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(packageName, ...)}}{
#'         \itemize{
#'             \item{Set the package that all operations in the object are done for.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{packageName}}: a string with the name of the package you are
#'                   analyzing.}
#'                 \item{\bold{\code{...}}: other arguments passed through to \code{extract_network}}
#'                  }
#'              }
#'          }
#'     }
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
#'                     would like to vett a package before adding it as a dependency}
#'                 \item{\bold{\code{ignorePackages}}: a vector of package names to ignore 
#'                     in dependency analysis. They will show up if a package depends on them
#'                     but their dependencies will be ignored. Useful if you know certain packages
#'                     are required and have and have a large number of dependencies that clutter
#'                     the analysis.
#'                }
#'             }
#'         }
#'         \item{\bold{Returns:}}{
#'             \itemize{
#'                 \item{A data.table of directed edges from SOURCE package to TARGET package}
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

        calculate_metrics = function(...){
            private$edges <- self$extract_network(...)
            print("here")
            private$nodes <- data.table::data.table(node = unique(c(private$edges[, SOURCE], private$edges[,TARGET])))
            print("there")
            private$pkgGraph <- private$make_graph_object(private$edges, private$nodes)
        },
        
        extract_network = function(depTypes = "Imports", installed = TRUE, ignorePackages = NULL){
            
            log_info(sprintf('Constructing reverse dependency graph for %s', private$packageName))
            
            if (installed){
                db <- utils::installed.packages()
                if (!is.element(pkgName, db[,1])) {
                    msg <- sprintf('%s is not an installed package. Consider setting installed to FALSE.', private$packageName)
                    log_fatal(msg)
                }
            }else{
                db <- NULL
            }
            allDependencies <- unlist(tools::package_dependencies(private$packageName
                                                                  , reverse = FALSE
                                                                  , recursive = TRUE
                                                                  , db = db
                                                                  , which = depTypes))
            
            if (is.null(allDependencies) | identical(allDependencies, character(0))){
                msg <- sprintf('Could not resolve dependencies for package %s',pkgName)
                log_warn(msg)
                nodeDT <- data.table::data.table(nodes = pkgName, level = 1,  horizontal = 0.5)
                return(list(nodes = nodeDT, edges = list(), networkMeasures = list()))
            }
            
            allDependencies <- setdiff(allDependencies, ignorePackages)
            
            dependencyList <- tools::package_dependencies(c(pkgName, allDependencies)
                                                          , reverse = FALSE
                                                          , recursive = FALSE
                                                          , db = db
                                                          , which = depTypes)
            
            nullList <- Filter(function(x){is.null(x)},dependencyList)
            if (length(nullList) > 0){
                log_info(paste("For package:"
                               , pkgName
                               , "with dependency types:"
                               , paste(which,collapse = ",")    
                               , "could not find dependencies:"
                               , paste(names(nullList), collapse = ",")))
            }
            
            dependencyList <- Filter(function(x){!is.null(x)}, dependencyList)
            
            edges <- data.table::rbindlist(lapply(names(dependencyList), function(pkgN){data.table::data.table(SOURCE = rep(pkgN,length(dependencyList[[pkgN]]))
                                                                                                               ,TARGET = dependencyList[[pkgN]])
            }))
            
            return(edges)
        }
    )
)
