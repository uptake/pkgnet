#' @title Extract the Dependency Network from a Package
#' @name ExtractDependencyNetwork
#' @author P. Boueri
#' @description This function maps a package's reverse dependency
#'              network, allowing for analysis of a package's imports
#' @param pkgName (character) The name of the package from which to extract the network structure.
#' @param which a character vector passed on to \link[tools]{package_dependencies} indicating what to count
#'              as a package dependency. Default is "Imports"
#' @param installed a boolean whether to consider installed packages or CRAN packages. default is TRUE
#'                 FALSE is useful if you would like to vett a package before adding it as a dependency
#' @param ignorePackages a vector of package names to ignore in dependency analysis. They will show up if a package depends on them
#'                       but their dependencies will be ignored. Useful if you know certain packages are required and have 
#'                       and have a large number of dependencies that clutter the analysis.
#' @importFrom data.table data.table setnames rbindlist
#' @importFrom utils installed.packages
#' @importFrom tools package_dependencies
#' @return A data.table of edges from SOURCE package to TARGET package
#' @export
#' @examples
#' \dontrun{
#' nw <- ExtractDependencyNetwork("dplyr")
#' }
ExtractDependencyNetwork <- function(pkgName
                                     , which = "Imports"
                                     , installed = TRUE
                                     , ignorePackages = NULL
                                     ){
    
    log_info(sprintf('Constructing reverse dependency graph for %s',pkgName))
  
    if (installed){
        db <- utils::installed.packages()
        if (!is.element(pkgName, db[,1])) {
          msg <- sprintf('%s is not an installed package. Consider setting installed to FALSE.',pkgName)
          log_fatal(msg)
        }
    }else{
        db <- NULL
    }
    allDependencies <- unlist(tools::package_dependencies(pkgName
                                                          , reverse = FALSE
                                                          , recursive = TRUE
                                                          , db = db
                                                          , which = which))
    
    if (is.null(allDependencies) | identical(allDependencies, character(0))){
        msg <- sprintf('Could not resolve dependencies for package %s',pkgName)
        log_warn(msg)
        nodeDT <- data.table::data.table(nodes = pkgName, level = 1,  horizontal = 0.5)
        return(packageObj <- list(nodes = nodeDT, edges = list(), networkMeasures = list()))
    }
    
    allDependencies <- setdiff(allDependencies,ignorePackages)
    
    dependencyList <- tools::package_dependencies(c(pkgName,allDependencies)
                                                  , reverse = FALSE
                                                  , recursive = FALSE
                                                  , db = db
                                                  , which = which)
    
    nullList <-Filter(function(x){is.null(x)},dependencyList)
    if (length(nullList) > 0){
        log_info(paste("For package:"
                       , pkgName
                       , "with dependency types:"
                       , paste(which,collapse = ",")    
                       , "could not find dependencies:"
                       , paste(names(nullList),collapse = ",")))
    }
    
    dependencyList <- Filter(function(x){!is.null(x)},dependencyList)
    
    edges <- data.table::rbindlist(lapply(names(dependencyList), function(pkgN){data.table::data.table(SOURCE = rep(pkgN,length(dependencyList[[pkgN]]))
                                                                                                       ,TARGET = dependencyList[[pkgN]])
    }))
    
    return(edges)
}
