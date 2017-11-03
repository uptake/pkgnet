#' @title Calculate Network and Node Level Statistics
#' @name CalcNetworkFeatures
#' @description Given an ExtractFunctionNetwork object, extract network features on a node and network level
#' @param edges a data.table of edges with two columns, SOURCE, and TARGET
#' @param nodes a data.table of nodes with column node
#' @importFrom igraph graph.edgelist centralization.betweenness centralization.closeness centralization.degree 
#' @importFrom igraph V vcount neighborhood.size hub_score page_rank degree
#' @return A two element list: \describe{
#' \item{networkMeasures}{a list of network level measures.}
#' \item{nodeMeasures}{a data.table with a node column andone column per node level statistic.}
#' }
#' @export
CalcNetworkFeatures <- function(edges,nodes) {

  # Create igraph
  pkgGraph <- MakeGraphObject(edges,nodes)
  
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
  
}


#' @title Make Graph Object Including Isolated Nodes
#' @name MakeGraphObject
#' @description Given a pkgGraphect created by \code{\link{ExtractFunctionNetwork}},
#'              use \code{igraph} to create a formal graph object
#' @param edges a data.table of edges with two columns, SOURCE, and TARGET
#' @param nodes a data.table of nodes with column node
#' @importFrom igraph vertex V graph.edgelist
#' @return an igraph object
MakeGraphObject <- function(edges,nodes){
  
  inGraph <- igraph::graph.edgelist(as.matrix(edges[,list(SOURCE,TARGET)])
                                    , directed = TRUE)
  #add isolated nodes
  allNodes <- nodes$node
  nonConnectedNodes <- base::setdiff(allNodes, names(igraph::V(inGraph)))
  return(inGraph + igraph::vertex(nonConnectedNodes))
}
