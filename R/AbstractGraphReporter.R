#' @title Abstract Graph Reporter Class
#' @name AbstractGraphReporter
#' @description Defines the Abstract Class for all PackageGraphReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @family AbstractReporters
#' @section Public Methods:
#' \describe{
#'    \itemize{
#'         \item{\code{plot_network()}}{
#'             \itemize{
#'                 \item{Creates a network visualization of extracted package graph.}
#'                 \item{\bold{Args:}}{
#'                     \itemize{
#'                         \item{\bold{\code{...}}: ...}
#'                     }
#'                 }
#'                 \item{\bold{Returns:}}{
#'                     \itemize{
#'                         \item{A `visNetwork` object}
#'                    }
#'                 }
#'             }
#'        }
#'    }
#' }
#' @section Public Members:
#' \describe{
#'    \item{\code{edges}}{A data.table from SOURCE to TARGET nodes describing the connections}
#'    \item{\code{nodes}}{A data.table with node as an identifier, and augmenting information about each node}
#'    \item{\code{pkgGraph}}{An igraph object describing the package graph}
#'    \item{\code{networkMeasures}}{A list of network measures calculated by \code{calculate_network_features}}
#'    \item{\code{layoutType}}{Character string indicating currently active graph layout}
#'    \item{\code{graphViz}}{\code{visNetwork} object of package graph}
#' }
#' @section Active Bindings:
#' \describe{
#'    \item{\code{pkgGraph()}}{Returns the graph object}
#'    \item{\code{networkMeasures()}}{Returns a table of network measures, one row per node}
#'    \item{\code{graphViz()}}{Returns ths graph visualization object}
#'    \item{\code{orphanNodes()}}{Returns the list of orphan nodes}
#'    \item{\code{layoutType(value)}}{If no value given, the current layout type for the graph visualization is returned.  
#'    If a vaild layput type is given, this fucntion will update the layoutType field.}
#'    \item{\code{orphanNodeClusteringThreshold(value)}}{If no value given, the current orphan node clustering threshold is returned. 
#'    If a valid orphan node clustering threshold is given, this function will update the orphan node clustering threshold.}
#' }
#' @importFrom data.table data.table copy uniqueN
#' @importFrom R6 R6Class
#' @importFrom igraph degree graph_from_edgelist graph.edgelist centralization.betweenness 
#' @importFrom igraph centralization.closeness centralization.degree hub_score
#' @importFrom igraph layout_as_tree layout_in_circle neighborhood.size page_rank V vcount vertex
#' @importFrom magrittr %>%
#' @importFrom methods hasArg formalArgs
#' @importFrom visNetwork visNetwork visHierarchicalLayout visEdges visOptions
#' @export
AbstractGraphReporter <- R6::R6Class(
    "AbstractGraphReporter",
    inherit = AbstractPackageReporter,
    
    public = list(
        
        # Creates visNetwork graph viz object
        # Uses pkgGraph active binding
        plot_network = function(){
            
            log_info("Creating plot...")
            
            # TODO:
            # Open these up to users or remove all the active binding code
            self$layoutType <- "tree"
            self$orphanNodeClusteringThreshold <- 10

            # format for plot
            plotDTnodes <- data.table::copy(self$nodes) # Don't modify original
            plotDTnodes[, id := node]
            plotDTnodes[, label := id]
            
            log_info(paste("Plotting with layout:", self$layoutType))
            plotDTnodes <- private$calculate_graph_layout(
                plotDT = plotDTnodes
            )
            
            if (length(self$edges) > 0) {
                plotDTedges <- data.table::copy(self$edges) # Don't modify original
                plotDTedges[, from := SOURCE]
                plotDTedges[, to := TARGET]
                plotDTedges[, color := '#848484'] # TODO Make edge formatting flexible too
            } else {
                plotDTedges <- NULL
            }
            
            # Color By Field
            if (is.null(private$plotNodeColorScheme[['field']])) {
                
                # Default Color for all Nodes
                plotDTnodes[, color := private$plotNodeColorScheme[['pallete']]]
                
            } else {
              
                # Fetch Color Scheme Values
                colorFieldName <- private$plotNodeColorScheme[['field']]
                
                # Check that that column exists in nodes table
                if (!is.element(colorFieldName, names(self$nodes))) {
                    log_fatal(sprintf(paste0("'%s' is not a field in the nodes table",
                                             " and as such cannot be used in plot color scheme.")
                                      , private$plotNodeColorScheme[['field']])
                    )
                }
                
                colorFieldPallete <- private$plotNodeColorScheme[['pallete']]
                colorFieldValues <- plotDTnodes[[colorFieldName]]
                log_info(sprintf("Coloring plot nodes by %s..."
                                 , colorFieldName))
              
                # If colorFieldValues are character 
                if (is.character(colorFieldValues) | is.factor(colorFieldValues)) {

                    # Create pallete by unique values
                    valCount <- data.table::uniqueN(colorFieldValues)
                    newPallete <- grDevices::colorRampPalette(colors = colorFieldPallete)(valCount)
                    
                    # For each character value, update all nodes with that value
                    plotDTnodes[, color := newPallete[.GRP]
                                , by = list(get(colorFieldName))]
                    
                } else if (is.numeric(colorFieldValues)) {
                    # If colorFieldValues are numeric, assume continuous
                  
                    # Create Continuous Color Pallete
                    newPallete <- grDevices::colorRamp(colors = colorFieldPallete)
                    
                    # Scale Values to be with range 0 - 1
                    plotDTnodes[!is.na(get(colorFieldName)), scaledColorValues := get(colorFieldName) / max(get(colorFieldName))]
                    
                    # Assign Color Values From Pallete
                    plotDTnodes[!is.na(scaledColorValues), color := grDevices::rgb(newPallete(scaledColorValues), maxColorValue = 255)]
                    
                    # NA Values get gray color
                    plotDTnodes[is.na(scaledColorValues), color := "gray"]
                    
                } else {
                    # Error Out
                    log_fatal(sprintf(paste0("A character, factor, or numeric field can be used to color nodes. "
                                             , "Field %s is of type %s.")
                                      , colorFieldName
                                      , typeof(colorFieldValues)
                                      )
                              )
                    
                } # end non-default color field
                
            } # end color field creation
            
            # If threshold to group orphan nodes, then assign group
            numOrphanNodes <- length(self$orphanNodes)
            numOrphanThreshold <- self$orphanNodeClusteringThreshold
            if (numOrphanNodes > numOrphanThreshold) {
                log_info(paste(sprintf("Number of orphan nodes %s exceeds orphanNodeClusteringThreshold %s."
                                 , numOrphanNodes
                                 , numOrphanThreshold
                                 )
                               , "Clustering orphan nodes..."
                               ))
                plotDTnodes[, group := NA_character_]
                plotDTnodes[node %in% self$orphanNodes, group := "orphan"]
            }
            
            # Create Plot
            g <- visNetwork::visNetwork(nodes = plotDTnodes
                                        , edges = plotDTedges) %>%
                 visNetwork::visHierarchicalLayout(sortMethod = "directed"
                                                   , direction = "UD") %>%
                 visNetwork::visEdges(arrows = 'to') %>%
                 visNetwork::visOptions(highlightNearest = list(enabled = TRUE
                                                                , degree = nrow(plotDTnodes) #guarantee full path
                                                                , algorithm = "hierarchical"))
            
            # Add orphan node clustering
            if (numOrphanNodes > numOrphanThreshold) {
                g <- g %>% visNetwork::visClusteringByGroup(groups = c("orphan"))
            }
            
            log_info("Done creating plot.")
            
            # Save plot in the cache
            private$cache$graphViz <- g
            
            return(g)
        }
    ),
    
    active = list(
        pkgGraph = function(){
            if (is.null(private$cache$pkgGraph)){
                log_info("Creating graph object...")
                private$make_graph_object()
                log_info("Done creating graph object")
            }
            return(private$cache$pkgGraph)
        },
        networkMeasures = function(){
            if (is.null(private$cache$networkMeasures)){
                log_info("Calculating network measures...")
                private$calculate_network_measures()
                log_info("Done calculating network measures.")
            }
            return(private$cache$networkMeasures)
        },
        graphViz = function(){
            if (is.null(private$cache$graphViz)) {
                log_info('Creating graph visualization plot...')
                private$cache$graphViz <- self$plot_network()
                log_info('Done creating graph visualization plot.')
            }
            return(private$cache$graphViz)
        },
        orphanNodes = function() {
            if (is.null(private$cache$orphanNodes)) {
                private$cache$orphanNodes <- private$identify_orphan_nodes()
            }
            return(private$cache$orphanNodes)
        },
        layoutType = function(value) {
            
            # If the person isn't using <- assignment, return the cached value
            if (!missing(value)) {
                if (!value %in% names(private$graph_layout_functions)) {
                    log_fatal(paste("Unsupported layoutType:", value))
                }
                if (!is.null(private$cache$graphViz)) {
                    private$reset_graph_viz()
                }
                private$private_layoutType <- value
            }
            return(private$private_layoutType)
        },
        orphanNodeClusteringThreshold = function(value) {
            
            # If the person isn't using <- assignment, return the cached value
            if (!missing(value)) {
                if (class(value) != 'numeric') {
                    log_fatal("orphanNodeClusteringThreshold must be numeric.")
                }
                
                if (value < 1) {
                    log_fatal("orphanNodeClusteringThreshold must at least 1.")
                }
                
                # Set new value and reset graph viz
                if (!is.null(private$cache$graphViz)) {
                    private$reset_graph_viz()
                }
                private$private_orphanNodeClusteringThreshold <- value
            }
            return(private$private_orphanNodeClusteringThreshold)
        }
    ),
    
    private = list(
        plotNodeColorScheme = list(
            field = NULL
            , pallete = '#97C2FC'
        ),
        
        # Create a "cache" to be used when evaluating active bindings
        # There is a default cache to reset to
        cache = list(
            nodes = NULL,
            edges = NULL,
            pkgGraph = NULL,
            networkMeasures = NULL,
            graphViz = NULL,
            orphanNodes = NULL
        ),
        
        private_orphanNodeClusteringThreshold = 10,
        private_layoutType = "tree",
        
        # Calculate graph-related measures for pkgGraph
        calculate_network_measures = function(){
            
            # Create igraph
            pkgGraph <- self$pkgGraph
            
            # inital Data.tables
            outNodeDT <- self$nodes
            outNetworkList <- list()
            
            #--------------#
            # out degree
            #--------------#
            outDegreeResult <- igraph::centralization.degree(
                graph = pkgGraph
                , mode = "out"
            )
            
            # update data.tables
            outNodeDT[, outDegree := outDegreeResult[['res']]] # nodes
            outNetworkList[['centralization.OutDegree']] <- outDegreeResult$centralization
            
            #--------------#
            # betweeness
            #--------------#
            outBetweenessResult <- igraph::centralization.betweenness(
                graph = pkgGraph
                , directed = TRUE
            )
            
            # update data.tables
            outNodeDT[, outBetweeness := outBetweenessResult$res] # nodes
            outNetworkList[['centralization.betweenness']] <- outBetweenessResult$centralization
            
            #--------------#
            # closeness
            #--------------#
            suppressWarnings({
                outClosenessResult <- igraph::centralization.closeness(
                    graph = pkgGraph
                    , mode = "out"
                )
            })
            
            # update data.tables
            outNodeDT[, outCloseness := outClosenessResult$res] # nodes
            outNetworkList[['centralization.closeness']] <- outClosenessResult$centralization
            
            #--------------------------------------------------------------#
            # NODE ONLY METRICS
            #--------------------------------------------------------------#
            
            #--------------#
            # Number of Decendants - a.k.a neightborhood or ego
            #--------------#
            neighborHoodSizeResult <- igraph::neighborhood.size(
                graph = pkgGraph
                , order = vcount(pkgGraph)
                , mode = "out"
            )
            
            # update data.tables
            outNodeDT[, numDescendants := neighborHoodSizeResult] # nodes
            
            #--------------#
            # Hub Score 
            #--------------#
            hubScoreResult <- igraph::hub_score(
                graph = pkgGraph
                , scale = TRUE
            )
            outNodeDT[, hubScore := hubScoreResult$vector] # nodes
            
            #--------------#
            # PageRank
            #--------------#
            pageRankResult <- igraph::page_rank(graph = pkgGraph, directed = TRUE)
            outNodeDT[, pageRank := pageRankResult$vector] # nodes
            
            #--------------#
            # in degree
            #--------------#
            inDegreeResult <- igraph::degree(pkgGraph, mode = "in")
            outNodeDT[, inDegree := inDegreeResult] # nodes
            
            #--------------------------------------------------------------#
            # NETWORK ONLY METRICS
            #--------------------------------------------------------------#
            
            #motifs?
            #knn/assortivity?
            
            private$cache$networkMeasures <- outNetworkList
            private$cache$nodes <- outNodeDT
            
            return(invisible(NULL))
        },
        
        # Creates pkgGraph igraph object
        # Requires edges and nodes
        make_graph_object = function(){
            edges <- self$edges
            nodes <- self$nodes
            
            if (nrow(edges) > 0) {
                
                # A graph with edges
                inGraph <- igraph::graph.edgelist(
                    as.matrix(edges[,list(SOURCE,TARGET)])
                    , directed = TRUE
                )
                
                # add isolated nodes
                allNodes <- nodes$node
                nonConnectedNodes <- base::setdiff(allNodes, names(igraph::V(inGraph)))
                
                outGraph <- inGraph + igraph::vertex(nonConnectedNodes)
            } else {
                # An unconnected graph
                allNodes <- nodes$node
                outGraph <- igraph::make_empty_graph() + igraph::vertex(allNodes)
            }
            
            private$cache$pkgGraph <- outGraph
            
            return(invisible(NULL))
        },
        
        # Variables for the plot 
        set_plot_node_color_scheme = function(field
                                              , pallete){
            
            # Check field is length 1 string vector
            if (typeof(field) != "character" || length(field) != 1) {
                log_fatal(paste0("'field' in set_plot_node_color_scheme must be a string vector of length one. "
                                 , "Coloring by multiple fields not supported."))
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
            
            private$plotNodeColorScheme <- list(
                field = field
                , pallete = pallete
            )
            
            log_info(sprintf("Node color scheme updated: field [%s], pallete [%s]."
                             , private$plotNodeColorScheme[['field']]
                             , paste(private$plotNodeColorScheme[['pallete']], collapse = ",")
            ))
            
            return(invisible(NULL))
        },
        
        # Function to update nodes
        # This function updates the cached nodes data.table, and if it exists, the pkgGraph object
        update_nodes = function(metadataDT) {
            log_info('Updating cached nodes data.table with metadata...')
            
            # Merge new DT with cached DT, but overwrite any colliding columns
            colsToKeep <- setdiff(names(self$nodes), names(metadataDT))
            private$cache$nodes <- merge(x = self$nodes[, .SD, .SDcols = c("node", colsToKeep)]
                                         , y = metadataDT
                                         , by = "node"
                                         , all.x = TRUE)
            return(invisible(NULL))
        },
        
        # Function to reset cached graphViz
        reset_graph_viz = function() {
            log_info('Resetting cached graphViz...')
            private$cache$graphViz <- NULL
            return(invisible(NULL))
        },
        
        # Identify orphan nodes
        identify_orphan_nodes = function() {
            orphanNodes <- base::setdiff(self$nodes[, node]
                                         , unique(c(self$edges[, SOURCE], self$edges[, TARGET]))
                                        )
            # If there are none, then will be character(0)
            return(orphanNodes)
        },
        
        graph_layout_functions = list(
            "tree" = function(pkgGraph) {igraph::layout_as_tree(pkgGraph)},
            "circle" = function(pkgGraph) {igraph::layout_in_circle(pkgGraph)}
        ),
        
        calculate_graph_layout = function(plotDT) {
            
            log_info(paste("Calculating graph layout for type:", self$layoutType))
            
            # Calculate positions for specified layoutType
            graph_func <- private$graph_layout_functions[[self$layoutType]]
            plotMat <- graph_func(self$pkgGraph)
            
            # It might be important to get the nodes from pkgGraph so that they
            # are in the same order as in plotMat?
            coordsDT <- data.table::data.table(
                node = names(igraph::V(self$pkgGraph))
                , level = plotMat[, 2]
                , horizontal = plotMat[, 1]
            )
            
            # Merge coordinates with plotDT
            plotDT <- merge(plotDT, coordsDT, by = 'node', all.x = TRUE)
            
            return(plotDT)
        }
    )
)
