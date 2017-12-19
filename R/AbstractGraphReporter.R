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
#'
#'         \item{\code{plot_network(colorFieldName=NULL)}}{
#'             \itemize{
#'                 \item{Creates a network visualization from tables of edges and nodes}
#'                 \item{\bold{Args:}}{
#'                     \itemize{
#'                         \item{\bold{\code{packageName}}: The name of column to use to 
#'                             color the nodes. This can be any column in the "nodes" table
#'                             inside the object produced by \code{extract_network}.
#'                             Default is outDegree. If you estimated test coverage 
#'                             when creating the network representation, try setting 
#'                             this field to "test_coverage"}
#'                     }
#'                 }
#'                 \item{\bold{Returns:}}{
#'                     \itemize{
#'                         \item{A plotly object (local, not on plot.ly)}
#'                    }
#'                 }
#'             }
#'        }
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
#' @importFrom magrittr %>%
#' @importFrom visNetwork visNetwork visHierarchicalLayout visEdges visOptions
#' @export
AbstractGraphReporter <- R6::R6Class(
    "AbstractGraphReporter",
    inherit = AbstractPackageReporter,
    
    public = list(
        
        calculate_network_measures = function(){
            
            # Create igraph
            pkgGraph <- private$make_graph_object(private$edges, private$nodes)
            
            # inital Data.tables
            outNodeDT <- private$nodes
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
        
        plot_network = function(){
          
            log_info("Creating plot...")
          
            self$set_graph_layout()
            
            # format for plot
            plotDTnodes <- data.table::copy(private$nodes) # Don't modify original
            plotDTnodes[, id := node]
            plotDTnodes[, label := id]
            
            if(!is.null(private$edges)) {
              plotDTedges <- data.table::copy(private$edges) # Don't modify original
              plotDTedges[, from := SOURCE]
              plotDTedges[, to := TARGET]
              plotDTedges[, color := '#848484'] # TODO Make edge formatting flexible too
            }

            
            
            # Color By Field
            if(is.null(private$plotNodeColorScheme[['field']])) {
              
              # Default Color for all Nodes
              plotDTnodes[, color := private$plotNodeColorScheme[['pallete']]]
              
            } else {
              colorFieldName <- private$plotNodeColorScheme[['field']]
              colorFieldPallete <- private$plotNodeColorScheme[['pallete']]
              colorFieldValues <- plotDTnodes[[colorFieldName]]
              
              log_info(sprintf("Coloring plot nodes by %s..."
                               , colorFieldName))
              
              # If character field
              if(is.character(colorFieldValues) | is.factor(colorFieldValues)) {
                # Create pallete by unique values
                valCount <- data.table::uniqueN(colorFieldValues)
                newPallete <- grDevices::colorRampPalette(colors = colorFieldPallete)(valCount)
                
                
                # For each character value, update all nodes with that value
                plotDTnodes[, color := newPallete[.GRP]
                              , by = list(get(colorFieldName))]
                
              } else if (is.numeric(colorFieldValues)) {
                # If numeric field, assume continuous
                newPallete <- grDevices::colorRamp(colors = colorFieldPallete)
                plotDTnodes[, color := newPallete(get(colorFieldName))]
                
              } else {
                log_fatal(sprintf(paste0("A character, factor, or numeric field can be used to color nodes. "
                                         , "Field %s is of type %s.")
                                  , colorFieldName
                                  , typeof(colorFieldValues)
                                  )
                          )
                
              } # end non-default color field
              
            } # end color field creation
            
            # Create Plot
            g <- visNetwork::visNetwork(nodes = plotDTnodes
                                        , edges = plotDTedges) %>%
              visNetwork::visHierarchicalLayout(sortMethod = "directed"
                                                , direction = "DU") %>%
              visNetwork::visEdges(arrows = 'to') %>%
              visNetwork::visOptions(highlightNearest = list(enabled = TRUE
                                                             , degree = nrow(plotDTnodes) #guarantee full path
                                                             , algorithm = "hierarchical")) 
            log_info("Done creating plot.")
            
            print(g) # to be removed once we have an HTML report function
            return(g)
            
        }, 
        
        # Variables for the plot 
        
        set_plot_node_color_scheme = function(field
                                              , pallete){
          # Check field is length 1 string vector
          if (typeof(field) != "character" || length(field) != 1) {
            log_fatal(paste0("'field' in set_plot_node_color_scheme must be a string vector of length one. "
                             , "Coloring by multiple fields not supported."))
          }
          
          # Check field is in nodes table 
          if (!is.element(field, names(private$nodes))) {
            log_fatal(sprintf(paste0("'%s' is not a field in the nodes table",
                                     " and as such cannot be used in plot color scheme.")
                              , field)
            )
          }
          
          # Confirm All Colors in pallete are Colors
          areColors <- function(x) {
            sapply(x, function(X) {
              tryCatch(is.matrix(col2rgb(X)), 
                       error = function(e) FALSE)
            })
          }
          
          if (!all(areColors(pallete))) {
            notColors <- names(areColors)[areColors == FALSE]
            notColorsTXT <- paste(notColors, collapse = ", ")
            log_fatal(sprintf("The following are invalid colors: %s"
                              , notColorsTXT))
          }
          
          
          private$plotNodeColorScheme <- list(field = field
                                              , pallete = pallete)
          
          log_info(sprintf("Node color scheme updated: field [%s], pallete [%s]."
                           , private$plotNodeColorScheme[['field']]
                           , paste(private$plotNodeColorScheme[['pallete']], collapse = ",")
                           ))
          
        },
        
        get_plot_node_color_scheme = function(){
          return(private$plotNodeColorScheme)
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
        plotNodeColorScheme = list(field = NULL
                                 , pallete = '#97C2FC'
                                 ),
        
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
            
            if (!is.null(edges) && length(edges) != 0) {
              # A graph with edges
              inGraph <- igraph::graph.edgelist(as.matrix(edges[,list(SOURCE,TARGET)])
                                                , directed = TRUE)
              
              # add isolated nodes
              allNodes <- nodes$node
              nonConnectedNodes <- base::setdiff(allNodes, names(igraph::V(inGraph)))
              
              outGraph <- inGraph + igraph::vertex(nonConnectedNodes)
            } else {
              # An unconnected graph
              allNodes <- nodes$node
              outGraph <- igraph::make_empty_graph() + igraph::vertex(allNodes)
                
            }
            
            log_info("Done creating graph object")
            return(outGraph)
        }
    )
)
