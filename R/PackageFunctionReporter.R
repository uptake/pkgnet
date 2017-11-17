#' @title Package Function Reporter Class
#' @name PackageFunctionReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other functions, determining useful information such as which function is most 
#'              central to the package. Combined with testing information it can be used as a powerful tool
#'              to plan testing efforts.
#' @importFrom data.table data.table melt as.data.table data.table setnames
#' @importFrom mvbutils foodweb
#' @importFrom R6 R6Class
#' @importFrom utils lsf.str
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(packageName, packagePath)}}{
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
#'     \item{\code{calculate_metrics()}}{
#'         \itemize{
#'             \item{Create an edgelist with relationships between functions in a package}
#'         }
#'     }
#'     \item{\code{extract_network()}}{
#'         \itemize{
#'             \item{This function maps the relationships between
#'                   functions in a package. Optionally, a subset of functions
#'                   can be mapped}
#'         }
#'     }
#' }
#' @export
PackageFunctionReporter <- R6::R6Class(
    "PackageFunctionReporter",
    inherit = AbstractGraphReporter,
    
    public = list(
        
        calculate_metrics = function(...){
            
            private$edges <- self$extract_network(...)
            private$nodes <- data.table::data.table(node = unique(c(private$edges[,SOURCE],private$edges[,TARGET])))
            
            if (!is.null(private$packagePath)){
                private$package_test_coverage()
            }
            private$pkgGraph <- private$make_graph_object(private$edges, private$nodes)
            self$calculate_network_measures()
            
            return(invisible(NULL))
        },
        
        extract_network = function(){
            
            if (is.null(private$packageName)){
                log_fatal("packageName not yet set! Run set_package()")
            }
            
            log_info(sprintf('Loading %s...', private$packageName))
            suppressPackageStartupMessages({
                require(private$packageName, character.only = TRUE)
            })
            log_info(sprintf('Done loading %s', private$packageName))
            
            # Avoid mvbutils::foodweb bug on one function packages
            numFuncs <- as.character(unlist(utils::lsf.str(asNamespace(private$packageName)))) # list of functions within Package
            if (length(numFuncs) == 1) {
                log_warn(sprintf('No Network Available.  Only one function in %s.', private$packageName))
                
                nodeDT <- data.table::data.table(nodes = numFuncs, level = 1,  horizontal = 0.5)
                return(packageObj <- list(nodes = nodeDT, edges = list(), networkMeasures = list()))
            }
            
            log_info(sprintf('Constructing network representation...'))
            funcMap <- mvbutils::foodweb(where = paste("package", private$packageName, sep = ":"), plotting = FALSE)
            log_info("Done constructing network representation")
            
            # Function Connections: Arcs
            edges <- data.table::melt(data.table::as.data.table(funcMap$funmat, keep.rownames = TRUE)
                                      , id.vars = "rn")[value != 0]
            data.table::setnames(edges,c('rn','variable'), c('TARGET','SOURCE'))
            
            return(edges)
        }
    ),
    
    private = list(
        
        # TODO [patrick.bouer@uptake.com]: Implement packageTestCoverage metrics
        package_test_coverage = function(){
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
        log_fatal(msg)
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


# [title] Obtain Ratio of Coverage For Each Function Within A Package
# [name] GetCoverageByFunction
# [description] Obtain Ratio of Coverage For Each Function Within A Package
# [param] pkgPath path to the package you want to examine
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
GetCoverageByFunction <- function(pkgPath) {
    
    # Grab Test Coverage
    coverage <- covr::package_coverage(pkgPath)
    
    # Aggregation on coverage by function
    res <- data.table::as.data.table(covr::tally_coverage(coverage))
    outDT <- res[, list(test_coverage = 100*sum(value > 0) / length(value))
                 , by = list(filename, functions)]
    
    # Rename for compatibility
    data.table::setnames(outDT, old = 'functions', new = 'node')
    
    return(outDT)
}
