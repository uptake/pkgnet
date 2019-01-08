#' @title Abstract Graph Reporter Class
#' @name AbstractGraphReporter
#' @description Defines the Abstract Class for all PackageGraphReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @family AbstractReporters
#' @section Public Members:
#' \describe{
#'    \item{\code{edges}}{A data.table from SOURCE to TARGET nodes describing the connections}
#'    \item{\code{nodes}}{A data.table with node as an identifier, and augmenting information about each node}
#'    \item{\code{pkg_graph}}{An igraph object describing the package graph}
#'    \item{\code{network_measures}}{A list of network measures calculated by \code{calculate_network_features}}
#'    \item{\code{layout_type}}{Character string indicating currently active graph layout}
#'    \item{\code{graph_viz}}{\code{visNetwork} object of package graph}
#' }
#' @section Active Bindings:
#' \describe{
#'    \item{\code{pkg_graph}}{Returns the graph object}
#'    \item{\code{network_measures}}{Returns a table of network measures, one row per node}
#'    \item{\code{graph_viz}}{Returns the graph visualization object}
#'    \item{\code{layout_type}}{If no value given, the current layout type for the graph visualization is returned.
#'        If a valid layout type is given, this function will update the layout_type field.
#'        You can use \code{grep("^layout_\\\\S", getNamespaceExports("igraph"), value = TRUE)} to see valid options.}
#' }
#' @importFrom data.table data.table copy uniqueN setkeyv
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
    active = list(
        pkg_graph = function(){
            if (is.null(private$cache$pkg_graph)){
                log_info("Creating graph object...")
                private$make_graph_object()
                log_info("Done creating graph object")
            }
            return(private$cache$pkg_graph)
        },
        network_measures = function(){
            if (is.null(private$cache$network_measures)){
                log_info("Calculating network measures...")
                # Set from NULL to empty list
                private$cache$network_measures <- list()
                private$calculate_network_measures()
                log_info("Done calculating network measures.")
            }
            return(private$cache$network_measures)
        },
        graph_viz = function(){
            if (is.null(private$cache$graph_viz)) {
                log_info('Creating graph visualization plot...')
                private$cache$graph_viz <- private$plot_network()
                log_info('Done creating graph visualization plot.')
            }
            return(private$cache$graph_viz)
        },
        layout_type = function(layout) {
            # If the person isn't using <- assignment, return the cached value
            if (!missing(layout)) {
                # Input validation
                assertthat::assert_that(
                    layout %in% .igraphAvailableLayouts()
                    , msg = sprintf(
                        "%s is not a supported layout by igraph. See documentation."
                        , layout
                    )
                )
                # Reset graph viz if it already exists
                if (!is.null(private$cache$graph_viz)) {
                    private$reset_graph_viz()
                }

                private$private_layout_type <- layout
            }
            return(private$private_layout_type)
        }
    ),

    private = list(
        plotNodeColorScheme = list(
            field = NULL
            , palette = '#97C2FC'
        ),

        # Create a "cache" to be used when evaluating active bindings
        # There is a default cache to reset to
        cache = list(
            nodes = NULL,
            edges = NULL,
            pkg_graph = NULL,
            network_measures = NULL,
            graph_viz = NULL
        ),

        # Default graph viz layout
        private_layout_type = "layout_nicely",

        # Calculate graph-related measures for pkg_graph
        calculate_network_measures = function(){

            # Use igraph object
            pkg_graph <- self$pkg_graph

            # Pointer to cached nodes data.table
            # Note that this is a reference, so changes will update cached table
            outNodeDT <- self$nodes

            #--------------#
            # out degree
            #--------------#
            outDegreeResult <- igraph::centralization.degree(
                graph = pkg_graph
                , mode = "out"
            )

            # update data.tables
            outNodeDT[, outDegree := outDegreeResult[['res']]] # nodes
            private$cache$network_measures[['centralization.OutDegree']] <- outDegreeResult$centralization

            #--------------#
            # betweeness
            #--------------#
            outBetweenessResult <- igraph::centralization.betweenness(
                graph = pkg_graph
                , directed = TRUE
            )

            # update data.tables
            outNodeDT[, outBetweeness := outBetweenessResult$res] # nodes
            private$cache$network_measures[['centralization.betweenness']] <- outBetweenessResult$centralization

            #--------------#
            # closeness
            #--------------#
            suppressWarnings({
                outClosenessResult <- igraph::centralization.closeness(
                    graph = pkg_graph
                    , mode = "out"
                )
            })

            # update data.tables
            outNodeDT[, outCloseness := outClosenessResult$res] # nodes
            private$cache$network_measures[['centralization.closeness']] <- outClosenessResult$centralization

            #--------------------------------------------------------------#
            # NODE ONLY METRICS
            #--------------------------------------------------------------#

            #--------------#
            # Size of Out-Subgraph - meaning the rooted graph out from a node
            # computed using out-neighborhood with order of longest possible path
            #--------------#
            numOutNodes <- igraph::neighborhood.size(
                graph = pkg_graph
                , order = vcount(pkg_graph)
                , mode = "out"
            )

            # update data.tables
            outNodeDT[, outSubgraphSize := numOutNodes] # nodes

            #--------------#
            # Size of In-Subgraph - meaning the rooted graph into a node
            # computed using in-neighborhood with order of longest possible path
            #--------------#
            numInNodes <- igraph::neighborhood.size(
                graph = pkg_graph
                , order = vcount(pkg_graph)
                , mode = "in"
            )

            # update data.tables
            outNodeDT[, inSubgraphSize := numInNodes] # nodes

            #--------------#
            # Hub Score
            #--------------#
            hubScoreResult <- igraph::hub_score(
                graph = pkg_graph
                , scale = TRUE
            )
            outNodeDT[, hubScore := hubScoreResult$vector] # nodes

            #--------------#
            # PageRank
            #--------------#
            pageRankResult <- igraph::page_rank(graph = pkg_graph, directed = TRUE)
            outNodeDT[, pageRank := pageRankResult$vector] # nodes

            #--------------#
            # in degree
            #--------------#
            inDegreeResult <- igraph::degree(pkg_graph, mode = "in")
            outNodeDT[, inDegree := inDegreeResult] # nodes

            #--------------------------------------------------------------#
            # NETWORK ONLY METRICS
            #--------------------------------------------------------------#

            #motifs?
            #knn/assortivity?

            return(invisible(NULL))
        },

        # Creates pkg_graph igraph object
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

            private$cache$pkg_graph <- outGraph

            return(invisible(NULL))
        },

        # Variables for the plot
        set_plot_node_color_scheme = function(field
                                              , palette){

            # Check field is length 1 string vector
            if (typeof(field) != "character" || length(field) != 1) {
                log_fatal(paste0("'field' in set_plot_node_color_scheme must be a string vector of length one. "
                                 , "Coloring by multiple fields not supported."))
            }

            # Confirm All Colors in palette are Colors
            areColors <- function(x) {
                sapply(x, function(X) {
                    tryCatch({
                        is.matrix(col2rgb(X))
                    }, error = function(e){
                        FALSE
                    })
                })
            }

            if (!all(areColors(palette))) {
                notColors <- names(areColors)[areColors == FALSE]
                notColorsTXT <- paste(notColors, collapse = ", ")
                log_fatal(sprintf("The following are invalid colors: %s"
                                  , notColorsTXT))
            }

            private$plotNodeColorScheme <- list(
                field = field
                , palette = palette
            )

            log_info(sprintf("Node color scheme updated: field [%s], palette [%s]."
                             , private$plotNodeColorScheme[['field']]
                             , paste(private$plotNodeColorScheme[['palette']], collapse = ",")
            ))

            return(invisible(NULL))
        },

        # Function to update nodes
        # This function updates the cached nodes data.table, and if it exists, the pkg_graph object
        update_nodes = function(metadataDT) {
            log_info('Updating cached nodes data.table with metadata...')

            # Merge new DT with cached DT, but overwrite any colliding columns
            colsToKeep <- setdiff(names(self$nodes), names(metadataDT))
            private$cache$nodes <- merge(
                x = self$nodes[, .SD, .SDcols = c("node", colsToKeep)]
                , y = metadataDT
                , by = "node"
                , all.x = TRUE
            )
            return(invisible(NULL))
        },

        # Creates visNetwork graph viz object
        # Uses pkg_graph active binding
        plot_network = function(){

            log_info("Creating plot...")

            log_info(paste("Using igraph layout:", self$layout_type))

            ## FORMAT NODES ##

            # format for plot
            plotDTnodes <- data.table::copy(self$nodes) # Don't modify original
            plotDTnodes[, id := node]
            plotDTnodes[, label := id]

            ## Color Nodes

            # Flag for us to do stuff later
            colorByGroup <- FALSE

            # If no field specified, use uniform color for all nodes
            if (is.null(private$plotNodeColorScheme[['field']])) {

                # Default Color for all Nodes
                plotDTnodes[, color := private$plotNodeColorScheme[['palette']]]

            # Otherwise use specified field to color node
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

                colorFieldPalette <- private$plotNodeColorScheme[['palette']]
                colorFieldValues <- plotDTnodes[, unique(get(colorFieldName))]
                log_info(sprintf("Coloring plot nodes by %s...", colorFieldName))

                # If colorFieldValues are character or factor
                # then we are coloring by group
                if (is.character(colorFieldValues) | is.factor(colorFieldValues)) {

                    # Create palette by unique values
                    valCount <- length(colorFieldValues)
                    newPalette <- grDevices::colorRampPalette(colors = colorFieldPalette)(valCount)

                    # For each character value, update all nodes with that value
                    plotDTnodes[, color := newPalette[.GRP], by = .(get(colorFieldName))]

                    # Set the group column to the field
                    plotDTnodes[, group := get(colorFieldName)]

                    # Set flag for us to build a legend in the graph viz later
                    colorByGroup <- TRUE

                # If colorFieldValues are numeric, assume continuous variable
                # Then we want to create a continuous palette
                } else if (is.numeric(colorFieldValues)) {


                    # Create Continuous Color Palette
                    newPalette <- grDevices::colorRamp(colors = colorFieldPalette)

                    # Scale Values to be with range 0 - 1
                    plotDTnodes[!is.na(get(colorFieldName)), scaledColorValues := get(colorFieldName) / max(get(colorFieldName))]

                    # Assign Color Values From Palette
                    plotDTnodes[!is.na(scaledColorValues), color := grDevices::rgb(newPalette(scaledColorValues), maxColorValue = 255)]

                    # NA Values get gray color
                    plotDTnodes[is.na(scaledColorValues), color := "gray"]

                # If none of the above, something is wrong
                } else {
                    # Error Out
                    log_fatal(
                        sprintf(
                            paste0("A character, factor, or numeric field can be used to color nodes. "
                                , "Field %s is of type %s.")
                            , colorFieldName
                            , typeof(colorFieldValues)
                        )
                    )
                } # end non-default color field
            } # end color setting

            # Order nodes alphabetically to make them easier to find in dropdown
            data.table::setkeyv(plotDTnodes, 'id')

            ## END FORMAT NODES##

            ## FORMAT EDGES ##

            if (length(self$edges) > 0) {
                plotDTedges <- data.table::copy(self$edges) # Don't modify original
                plotDTedges[, from := SOURCE]
                plotDTedges[, to := TARGET]
                plotDTedges[, color := '#848484'] # TODO Make edge formatting flexible too
            } else {
                plotDTedges <- NULL
            }

            ## END FORMAT EDGES ##

            # Create Plot
            g <- (visNetwork::visNetwork(nodes = plotDTnodes
                                        , edges = plotDTedges)
                %>% visNetwork::visIgraphLayout(layout = self$layout_type)
                %>% visNetwork::visEdges(arrows = 'to')

                # Default options
                %>% visNetwork::visOptions(
                        highlightNearest = list(
                            enabled = TRUE
                            , degree = nrow(plotDTnodes) # guarantee full path
                            , algorithm = "hierarchical"
                        )
                    , nodesIdSelection = TRUE
                )
            )


            if (colorByGroup) {
                # Add group definitions
                log_info(paste(colorFieldValues))
                for (groupVal in colorFieldValues) {
                    thisGroupColor <- plotDTnodes[
                            get(colorFieldName) == groupVal
                            , color
                        ][1]
                    g <- visNetwork::visGroups(
                        graph = g
                        , groupname = groupVal
                        , color = thisGroupColor
                    )
                }

                # Add legend
                # but it is broken if there is only one level
                # so hard-code for now to skip if there is only one level
                # TODO: remove if statement when the following issue is resolved:
                # https://github.com/datastorm-open/visNetwork/issues/290
                if (length(colorFieldValues) > 1) {
                    g <- visNetwork::visLegend(
                        graph = g
                        , position = "right"
                        , main = list(
                            text = colorFieldName
                            , style = 'font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;'
                        )
                    )
                }
            }


            log_info("Done creating plot.")

            # Save plot in the cache
            private$cache$graph_viz <- g

            return(g)
        },

        # Function to reset cached graph_viz
        reset_graph_viz = function() {
            log_info('Resetting cached graph_viz...')
            private$cache$graph_viz <- NULL
            return(invisible(NULL))
        }

    )
)

# [title] Available Graph Layout Functions from igraph
# [name] .igraphAvailableLayouts
# [description] Returns available \link[igraph:layout_]{igraph layout function}
# names. These names can be passed to
# \code{\link[visNetwork:visIgraphLayout]{visNetwork::visIgraphLayout}} or set
# as the \code{layout_type} for any reporters that inherit from
# \code{\link{AbstractGraphReporter}}.
# [return] a character vector of igraph layout function names
.igraphAvailableLayouts <- function() {
    return(grep("^layout_\\S", getNamespaceExports("igraph"), value = TRUE))
}
