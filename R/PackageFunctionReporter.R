#' @title Package Function Reporter Class
#' @name PackageFunctionReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other functions, determining useful information such as which function is most 
#'              central to the package. Combined with testing information it can be used as a powerful tool
#'              to plan testing efforts.
#' @importFrom data.table data.table
#' @importFrom R6 R6Class
#' @section Dependency Methods:
#' \describe{
#'  \itemize{
#'    \item{\code{set_package}{Uses \code{ExtractFunctionNetwork} to create edges}}
#'    \item{\code{package_test_coverage}{Uses \code{GetCoverageByFunction} to calculate node test coverage}}
#'  }
#' }
#' @export
PackageFunctionReporter <- R6::R6Class(
    "PackageFunctionReporter",
    inherit = AbstractGraphReporter,
    
    public = list(
        
        set_package = function(packageName, packagePath = NULL) {
            private$edges <- ExtractFunctionNetwork(packageName)
            private$nodes <- data.table::data.table(node = unique(c(private$edges[,SOURCE],private$edges[,TARGET])))
            private$packageName <- packageName
            if (is.null(packagePath)){
                self$package_test_coverage(packagePath)
            }
            private$pkgGraph <- MakeGraphObject(private$edges,private$nodes)
            self$calculate_network_metrics()
        },
        
        # TODO [patrick.bouer@uptake.com]: Implement packageTestCoverage metrics
        package_test_coverage = function(packagePath){
            return(invisible(NULL))
            
            # log_info('Checking package coverage...')
            # packageObj <- .UpdateNodes(nodes
            #                            , metadataDT = GetCoverageByFunction(pkgPath)) 
            # 
            # # weighted test coverage
            # dependencyWeightedTestCoverage <- packageObj[['nodes']][,sum(test_coverage * (outDegree + 1)) / sum((outDegree + 1))]
            # packageObj <- .UpdateNetworkMeasures(pkgGraph = packageObj
            #                             , networkMeasureList = list(dependencyWeightedTestCoverage = dependencyWeightedTestCoverage)
            # )
            # log_info'DONE.\n')
        }
    )
)


# [title] Add metadata to nodes in a package graph
# [name] .UpdateNodes
# [description] Given a pkgGraph object created by \code{\link[pkgnet]{ExtractFunctionNetwork}}
#              and a data.table of metadata, this function will append those metadata to
#              the internal object used to manage node properties
# [param] pkgGraph An object created by \code{\link[pkgnet]{ExtractFunctionNetwork}}
# [param] metadataDT A data.table with node metadata. This table must have a 'node'
#                   column with the names of nodes (e.g. function names) to be updated.
# [examples]
#
# library(pkgnet)
# nw <- ExtractFunctionNetwork("ggplot2")
# 
# # Add random stuff
# coverageDT <- data.table(node = c('log.warn', 'GetAPIInfo'), coverage = c(95, 100))
# newNW <- pkgnet:::.UpdateNodes(nw, coverageDT)
.UpdateNodes <- function(pkgGraph, metadataDT){
    
    # Input checks
    if (!'nodes' %in% names(pkgGraph)){
        msg <- paste0("Did you generate pkgGraph with ExtractFunctionNetwork? ",
                      "It should be a list with a 'nodes' element.")
        log_fatal(msg)
    }
    if (!'data.table' %in% class(pkgGraph[['nodes']])){
        msg <- "the object in the 'nodes' element of pkgGraph should be a data.table!"
        log_fatal(msg)
    }
    if (!'data.table' %in% class(metadataDT)){
        msg <- "the object passed to metadataDT should be a data.table!"
        log_fatal(msg)
    }
    if (!'node' %in% names(metadataDT)){
        msg <- "metadataDT should have a column called 'node'"
        logal_fatal(msg)
    }
    
    # Append metadata
    pkgGraph[['nodes']] <- merge(pkgGraph[['nodes']]
                                 , metadataDT
                                 , all.x = TRUE
                                 , all.y = FALSE
                                 , by = 'node')
    
    return(pkgGraph)
    
}


# [title] Add network measures in a package graph
# [name] .UpdateNetworkMeasures
# [description] Given a pkgGraph object created by \code{\link[pkgnet]{ExtractFunctionNetwork}}
#              and a list of network measures, this function will append the network measures to
#              the internal network measures object if it is a new measure.  Otherwise, it will 
#              replace an existing network measure with a new value.
# [param] pkgGraph An object created by \code{\link[pkgnet]{ExtractFunctionNetwork}}
# [param] networkMeasureList A list with network measures.
# [examples]
#
# library(pkgnet)
# nw <- ExtractFunctionNetwork("ggplot2")
# 
# # Add random stuff
# newNetworkMeasure <- list(awesomness = 11)
# newNW <- pkgnet:::.UpdateNetworkMeasures(nw, newNetworkMeasure)
#' @importFrom data.table is.data.table
.UpdateNetworkMeasures <- function(pkgGraph, networkMeasureList){
    
    # Input checks
    if (!'nodes' %in% names(pkgGraph)){
        msg <- paste0("Did you generate pkgGraph with ExtractFunctionNetwork? ",
                      "It should be a list with a 'nodes' element.")
        log_fatal(msg)
    }
    if (!data.table::is.data.table(pkgGraph[['nodes']])){
        msg <- "the object in the 'nodes' element of pkgGraph should be a data.table!"
        log_fatal(msg)
    }
    if (!is(networkMeasureList, "list")){
        msg <- "the object passed to networkMeasureList should be a list!"
        log_fatal(msg)
    }
    
    # replace Value is exists already. otherwise append
    currentNames <- names(pkgGraph[['networkMeasures']])
    newNames <- names(networkMeasureList)
    existingIX <- match(x = newNames, table = currentNames)
    r <- 0
    for(i in existingIX){
        r <- r + 1
        if(is.na(i)) {
            #append
            pkgGraph[['networkMeasures']] <- c(pkgGraph[['networkMeasures']], networkMeasureList[r])
        } else {
            #replace
            pkgGraph[['networkMeasures']][i] <- networkMeasureList[r]
        }
    }
    
    return(pkgGraph)
    
}
