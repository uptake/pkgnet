
# [title] Plot Network Structure
# [description] Plot the network structure of an R package.
# [param] edges a data.table with SOURCE and TARGET nodes
# [param] nodes a data.table with node and augmenting metadata
# [param] colorFieldName (character) The name of column to use to color the nodes. This can
#                       be any column in the "nodes" table inside the object produced by
#                       \code{ExtractFunctionNetwork}. Default is outDegree. If you estimated
#                       test coverage when creating the network representation,
#                       try setting this field to "test_coverage"!
#' @importFrom visNetwork visNetwork visHierarchicalLayout visEdges visOptions
#' @importFrom magrittr %>%
# [return] A plotly object (local, not on plot.ly)
PlotNetwork <- function(edges
                        , nodes
                        , colorFieldName = NULL) {
    # format for plot
    nodes[, id := node]
    nodes[, label := id]
    #nodes[, x := horizontal]
    #nodes[, y := level]
    
    edges[, from := SOURCE]
    edges[, to := TARGET]
    
    defaultNodeColor <- "blue" 
    if (is.null(colorFieldName)) {
        
        # Same Color for all nodes
        g <- visNetwork::visNetwork(nodes = nodes, edges = edges) %>%
             visNetwork::visHierarchicalLayout(sortMethod = "directed", direction = "DU") %>%
             visNetwork::visEdges(arrows = 'to') %>%
             visNetwork::visOptions(highlightNearest = list(enabled = TRUE, degree = 2000, algorithm = "hierarchical"))
    
    } else if (is.factor(nodes[,colorFieldName, with = FALSE]) | is.character(nodes[,colorFieldName, with = FALSE])) {
        # Color By Discrete Factor
    } else {
        # Assume continuous number scale
    }
    
    print(g) # to be removed once we have an HTML report function
    return(g)
  
}
