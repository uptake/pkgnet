

#' @title Extract the Network Relationship Between Functions in A Package
#' @name ExtractFunctionNetwork
#' @author B. Burns
#' @description This function maps the relationships between
#'              functions in a package. Optionally, a subset of functions
#'              can be mapped.
#' @param pkgName (character) The name of the package from which to extract the network structure.
#' @param pkgPath (character) String, optional, with a path to the package's source code.
#'                                You need to provide this if you want to add test coverage
#'                                to the function nodes.
#' @importFrom data.table melt as.data.table data.table setnames
#' @importFrom data.table setnames melt
#' @importFrom mvbutils foodweb
#' @importFrom utils lsf.str
#' @seealso mvbutils::foodweb
#' @return A list with three (3) elements: \itemize{
#' \item{edges} {A data.table of dependencies between functions.}
#' }
#' @export
#' @examples
#' \dontrun{
#' nw <- ExtractFunctionNetwork("data.table")
#' }
ExtractFunctionNetwork <- function(pkgName
                           , pkgPath = NULL
){
    
  futile.logger::flog.info(sprintf('Loading %s...', pkgName))
  suppressPackageStartupMessages({
    require(pkgName, character.only = TRUE)
  })
  futile.logger::flog.info('DONE.\n')
  
  # Avoid mvbutils::foodweb bug on one function packages
  numFuncs <- as.character(unlist(utils::lsf.str(asNamespace(pkgName)))) # list of functions within Package
  if (length(numFuncs) == 1) {
    msg <- sprintf('No Network Available.  Only one function in %s.', pkgName)
    futile.logger::flog.warn(msg)
    warning(msg)
    nodeDT <- data.table::data.table(nodes = numFuncs, level = 1,  horizontal = 0.5)
    return(packageObj <- list(nodes = nodeDT, edges = list(), networkMeasures = list()))
  }
  
  futile.logger::flog.info(sprintf('Constructing network representation...'))
  funcMap <- mvbutils::foodweb(where = paste("package", pkgName, sep = ":"), plotting = FALSE)
  
  # Function Connections: Arcs
  edges <- data.table::melt(data.table::as.data.table(funcMap$funmat, keep.rownames = TRUE)
                , id.vars = "rn")[value != 0]
  data.table::setnames(edges,c('rn','variable'), c('TARGET','SOURCE'))
  
  return(edges)
}


#' @title Plot Network Structure
#' @description Plot the network structure of an R package.
#' @param edges a data.table with SOURCE and TARGET nodes
#' @param nodes a data.table with node and augmenting metadata
#' @param colorFieldName (character) The name of column to use to color the nodes. This can
#'                       be any column in the "nodes" table inside the object produced by
#'                       \code{ExtractFunctionNetwork}. Default is outDegree. If you estimated
#'                       test coverage when creating the network representation,
#'                       try setting this field to "test_coverage"!
#' @importFrom visNetwork visNetwork visHierarchicalLayout visEdges visOptions
#' @importFrom magrittr %>%
#' @return A plotly object (local, not on plot.ly)
#' @export 
#' @examples
#' \dontrun{
#' nw <- ExtractFunctionNetwork("lubridate")
#' nw$nodes[,test := runif(.N)]
#' PlotNetwork(nw, colorFieldName = "test")
#' }
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
    
    
  } else if (is.factor(nodes[,colorFieldName, with = F]) | is.character(nodes[,colorFieldName, with = F])) {
    # Color By Discrete Factor
  } else {
    # Assume continuous number scale
  }
  
  print(g) # to be removed once we have an HTML report function
  return(g)
  
}
