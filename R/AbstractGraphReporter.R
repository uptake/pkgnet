#' @title Abstract Graph Reporter Class
#' @name AbstractGraphReporter
#' @description Defines the Abstract Class for all PackageGraphReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @family AbstractReporters
#' @section Public Methods:
#' \describe{
#'    \item{\code{calculateNetworkMetrics}{Uses \link{CalcNetworkFeatures} to calculate nodes and edges to create summary metrics of the overall graph structure, including centrality measures etc.}}
#'    \item{\code{getSummaryView}{Returns the output of calculateNetworkMetrics}}
#'    \item{\code{setGraphLayout}{Accepts a layoutType from either "tree" or "circle" and augments the nodes private field with level/horizontal co-ordinates for a prettified layout}}
#'    \item{\code{plotNetwork}{Calls \code{PlotNetwork} and returns a plotly object }}
#' }
#' @section Public Members:
#' \describe{
#'    \item{\code{edges}{A data.table from SOURCE to TARGET nodes describing the connections}}
#'    \item{\code{nodes}{A data.table with node as an identifier, and augementing information about each node}}
#'    \item{\code{pkgGraph}{An igraph object describing the package graph}}
#'    \item{\code{networkMeasures}{A list of network measures calculated by \link{CalcNetworkFeatures}}}
#' }
#' @importFrom data.table data.table
#' @importFrom R6 R6Class
#' @importFrom igraph graph_from_edgelist layout_as_tree layout_in_circle V
#' @export
AbstractGraphReporter <- R6::R6Class(
    "AbstractGraphReporter",
    inherit = AbstractPackageReporter,
    
    public = list(
        calculateNetworkMetrics = function(){
            private$networkMeasures <- CalcNetworkFeatures(private$edges,private$nodes)
        },
        
        getSummaryView = function(){
            return(private$networkMeasures)
        },
        
        setGraphLayout = function(layoutType = "tree"){

            if (layoutType == "tree"){
                plotMat <- suppressWarnings(igraph::layout_as_tree(private$pkgGraph)) 
            } else if (layout == "circle"){
                plotMat <- igraph::layout_in_circle(private$pkgGraph)
            } else {
                stop(paste0("Unkown parameter passed to setGraphLayout",layoutType))
            }
            plotDT <- data.table::data.table(node = names(igraph::V(private$pkgGraph))
                                             , level = plotMat[,2]
                                             , horizontal = plotMat[,1])
            private$nodes <- merge(x = private$nodes, y = plotDT, all.x = TRUE, by="node")
        },
        
        plotNetwork = function(colorFieldName = NULL){
            self$setGraphLayout()
            PlotNetwork(edges = private$edges
                        ,nodes = private$nodes
                        ,colorFieldName)
        }
    ),
    
    private = list(
        edges = NULL,
        nodes = NULL,
        pkgGraph = NULL,
        networkMeasures = NULL
    )
)
