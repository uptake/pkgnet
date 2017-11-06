#' @title Abstract Graph Reporter Class
#' @name AbstractGraphReporter
#' @description Defines the Abstract Class for all PackageGraphReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @family AbstractReporters
#' @section Public Methods:
#' \describe{
#'    \itemize{
#'         \item{\code{calculate_network_measures()}}{
#'             \itemize{
#'                 \item{extract network features on a node and network level}
#'                 \item{\bold{Returns:}}{
#'                     \itemize{
#'                     \item{\bold{\code{packageName}}: String with the name of the package}
#'                     \item{\bold{\code{packagePath}}: Optional path to the source code. 
#'                         To be used for test coverage, if provided.}
#'                    }
#'                 }
#'             }
#'        }
#'        \item{\code{get_summary_view}{Returns the output of calculateNetworkMetrics}}
#'        \item{\code{set_graph_layout}{Accepts a layoutType from either "tree" or "circle"
#'          and augments the nodes private field with level/horizontal coordinates 
#'          for a prettified layout}}
#'        \item{\code{plot_network}{Calls \code{PlotNetwork} and returns a plotly object }}
#'    }
#' }
#' @section Public Members:
#' \describe{
#'  \itemize{
#'    \item{\code{edges}{A data.table from SOURCE to TARGET nodes describing the connections}}
#'    \item{\code{nodes}{A data.table with node as an identifier, and augmenting information about each node}}
#'    \item{\code{pkgGraph}{An igraph object describing the package graph}}
#'    \item{\code{networkMeasures}{A list of network measures calculated by \code{CalcNetworkFeatures}}}
#'   }
#' }
#' @importFrom data.table data.table
#' @importFrom R6 R6Class
#' @importFrom igraph degree graph_from_edgelist graph.edgelist centralization.betweenness 
#' @importFrom igraph centralization.closeness centralization.degree hub_score
#' @importFrom igraph layout_as_tree layout_in_circle neighborhood.size page_rank V vcount vertex
#' @export
AbstractGraphReporter <- R6::R6Class(
    "AbstractGraphReporter",
    inherit = AbstractPackageReporter,
    
    public = list(
        
        calculate_network_measures = function(){
            
            # Create igraph
            pkgGraph <- private$make_graph_object(private$edges, private$nodes)
            
            # inital Data.tables
            outNodeDT <- data.table::data.table(node = names(igraph::V(pkgGraph)))
            outNetworkList <- list()
            
            #--------------#
            # out degree
            #--------------#
            outDegree <- igraph::centralization.degree(graph = pkgGraph
                                                       , mode = "out"
            )
            # update data.tables
            outNodeDT[, outDegree := outDegree[['res']]] # nodes
            outNetworkList[['centralization.OutDegree']] <- outDegree$centralization
            
            #--------------#
            # betweeness
            #--------------#
            outBetweeness <- igraph::centralization.betweenness(graph = pkgGraph
                                                                , directed = TRUE
            )
            # update data.tables
            outNodeDT[, outBetweeness := outBetweeness$res] # nodes
            outNetworkList[['centralization.betweenness']] <- outBetweeness$centralization
            
            #--------------#
            # closeness
            #--------------#
            outCloseness <- igraph::centralization.closeness(graph = pkgGraph
                                                             , mode = "out"
            )
            # update data.tables
            outNodeDT[, outCloseness := outCloseness$res] # nodes
            outNetworkList[['centralization.closeness']] <- outCloseness$centralization
            
            #--------------------------------------------------------------#
            # NODE ONLY METRICS
            #--------------------------------------------------------------#
            
            #--------------#
            # Number of Decendants - a.k.a neightborhood or ego
            #--------------#
            neighborHoodSize <- igraph::neighborhood.size(graph = pkgGraph
                                                          , order = vcount(pkgGraph)
                                                          , mode = "out"
            )
            
            # update data.tables
            outNodeDT[, numDescendants := neighborHoodSize] # nodes
            
            #--------------#
            # Hub Score 
            #--------------#
            hubScore <- igraph::hub_score(graph = pkgGraph
                                          , scale = TRUE
            )
            outNodeDT[, hubScore := hubScore$vector] # nodes
            #--------------#
            # PageRank
            #--------------#
            
            pageRank <- igraph::page_rank(graph = pkgGraph, directed = TRUE)
            outNodeDT[, pageRank := pageRank$vector] # nodes
            
            #--------------#
            # in degree
            #--------------#
            inDegree <- igraph::degree(pkgGraph, mode = "in")
            outNodeDT[, inDegree := inDegree] # nodes
            
            #--------------------------------------------------------------#
            # NETWORK ONLY METRICS
            #--------------------------------------------------------------#
            
            #motifs?
            #knn/assortivity?
            
            return(list(networkMeasures = outNetworkList, nodeMeasures = outNodeDT))
        },
        
        get_summary_view = function(){
            return(self$networkMeasures)
        },
        
        set_graph_layout = function(layoutType = "tree"){

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
        
        plot_network = function(colorFieldName = NULL){
            self$set_graph_layout()
            PlotNetwork(edges = private$edges
                        , nodes = private$nodes
                        , colorFieldName)
        }
    ),
    
    active = list(
        networkMeasures = function(){
            
            if (is.null(private$cache$networkMeasures)){
                log_info("Calculating network measures...")
                private$cache$networkMeaures <- self$calculate_network_measures()
                log_info("Done calculating network measures.")
            }
            
            return(private$cache$networkMeasures)
        }
    ),
    
    private = list(
        edges = NULL,
        nodes = NULL,
        pkgGraph = NULL,
        
        # Create a "cache" to be used when evaluating active bindings
        cache = list(
            networkMeasures = NULL  
        ),
        
        # [title] Make Graph Object Including Isolated Nodes
        # [description] Given a pkgGraph object created by \code{\link{ExtractFunctionNetwork}},
        #              use \code{igraph} to create a formal graph object
        # [param] edges a data.table of edges with two columns, SOURCE, and TARGET
        # [param] nodes a data.table of nodes with column node
        # [return] an igraph object
        make_graph_object = function(edges, nodes){
            
            log_info("Creating graph object...")
            
            inGraph <- igraph::graph.edgelist(as.matrix(edges[,list(SOURCE,TARGET)])
                                              , directed = TRUE)
            #add isolated nodes
            allNodes <- nodes$node
            nonConnectedNodes <- base::setdiff(allNodes, names(igraph::V(inGraph)))
            
            log_info("Done creating graph object")
            return(inGraph + igraph::vertex(nonConnectedNodes))
        }
    )
)
