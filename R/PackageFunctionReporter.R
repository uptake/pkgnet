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
        
        package_test_coverage = function(packagePath){
            return(invisible(NULL))
            # TODO [patrick.bouer@uptake.com]: Implement packageTestCoverage metrics
            # futile.logger::flog.info('Checking package coverage...')
            # packageObj <- .UpdateNodes(nodes
            #                            , metadataDT = GetCoverageByFunction(pkgPath)) 
            # 
            # # weighted test coverage
            # dependencyWeightedTestCoverage <- packageObj[['nodes']][,sum(test_coverage * (outDegree + 1)) / sum((outDegree + 1))]
            # packageObj <- .UpdateNetworkMeasures(pkgGraph = packageObj
            #                             , networkMeasureList = list(dependencyWeightedTestCoverage = dependencyWeightedTestCoverage)
            # )
            # futile.logger::flog.info('DONE.\n')
        }
    )
)
