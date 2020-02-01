#' @title Network Reporters for Packages
#' @name NetworkReporters
#' @keywords internal
#' @concept Reporters
#' @description \pkg{pkgnet} defines several package reporter R6 classes that model
#'     a particular network aspect of a package as a graph. These network
#'     reporter classes are extended from \code{AbstractGraphReporter}, which
#'     itself extends the \code{\link[=PackageReporters]{AbstractPackageReporter}}
#'     with graph-modeling-related functionality.
#'
#'     This article describes the additional fields added by the
#'     \code{AbstractGraphReporter} class definition.
#'
#' @section Public Methods:
#' \describe{
#'     \item{\code{calculate_default_measures()}}{
#'         \itemize{
#'             \item{Calculates the default node and network measures for this
#'                reporter.
#'             }
#'             \item{\bold{Returns:}}{
#'                 \itemize{
#'                     \item{Self, invisibly.}
#'                 }
#'             }
#'         }
#'     }
#' }
#' @section Public Fields:
#' \describe{
#'     \item{\bold{\code{nodes}}}{: a data.table, containing information about
#'        the nodes of the network the reporter is analyzing. The \code{node}
#'        column acts the identifier. Read-only.
#'     }
#'     \item{\bold{\code{edges}}}{: a data.table, containing information about
#'        the edge connections of the network the reporter is analyzing. Each
#'        row is one edge, and the columns \code{SOURCE} and \code{TARGET}
#'        specify the node identifiers. Read-only.
#'     }
#'     \item{\bold{\code{network_measures}}}{: a list, containing any measures
#'        of the network calculated by the reporter. Read-only.
#'     }
#'     \item{\bold{\code{pkg_graph}}}{: a graph model object. See \link{DirectedGraph}
#'        for additional documentation. Read-only.
#'     }
#'     \item{\bold{\code{graph_viz}}}{: a graph visualization object. A
#'        \code{\link[visNetwork:visNetwork]{visNetwork::visNetwork}} object.
#'        Read-only.
#'     }
#'     \item{\bold{\code{layout_type}}}{: a character string, the current layout
#'        type for the graph visualization. Can be assigned a new valid layout
#'        type value. Use use
#'        \code{grep("^layout_\\\\S", getNamespaceExports("igraph"), value = TRUE)}
#'        to see valid options.
#'     }
#' }
NULL


#' @importFrom R6 R6Class
#' @importFrom DT datatable formatRound
#' @importFrom data.table data.table copy setkeyv
#' @importFrom assertthat assert_that
#' @importFrom grDevices colorRamp colorRampPalette rgb
#' @importFrom magrittr %>%
#' @importFrom visNetwork visNetwork visIgraphLayout visEdges visOptions
#' visGroups visLegend
AbstractGraphReporter <- R6::R6Class(
    "AbstractGraphReporter"
    , inherit = AbstractPackageReporter

    , public = list(
        calculate_default_measures = function() {
            self$pkg_graph$node_measures(
                measures = self$pkg_graph$default_node_measures
            )
            self$pkg_graph$graph_measures(
                measures = self$pkg_graph$default_graph_measures
            )
            return(invisible(self))
        }

        , get_summary_view = function(){

            # Create DT for display of the nodes data.table
            tableObj <- DT::datatable(
                data = self$nodes[order(node)]
                , rownames = FALSE
                , options = list(
                    searching = FALSE
                    , pageLength = 50
                    , lengthChange = FALSE
                    , scrollX = TRUE
                )
            )

            # Round the double columns to three digits for formatting reasons
            doubleCols <- names(which(unlist(lapply(tableObj$x$data, is.double))))

            tableObj <- DT::formatRound(
                columns = doubleCols
                , table = tableObj
                , digits = 3
            )
            return(tableObj)
        }

    ) # /public

    , active = list(

        nodes = function(){
            if (is.null(private$cache$nodes)){
                private$extract_nodes()
            }
            return(private$cache$nodes)
        },

        edges = function(){
            if (is.null(private$cache$edges)) {
                private$extract_edges()
            }
            return(private$cache$edges)
        },

        network_measures = function() {
            return(c(private$cache$network_measures
                     , private$cache$pkg_graph$graph_measures()))
        },

        pkg_graph = function(){
            if (is.null(private$cache$pkg_graph)){
                if (is.null(private$graph_class)) {
                    log_fatal("Reporter must set valid graph class.")
                }

                # Get graph object constructor
                assertthat::assert_that(
                    private$graph_class %in% names(getNamespace('pkgnet'))
                )
                graphConstructor <- get(private$graph_class
                                        , pos = getNamespace('pkgnet')
                                        )

                log_info("Creating graph model for network...")
                pkg_graph <- graphConstructor$new(self$nodes, self$edges)
                private$cache$pkg_graph <- pkg_graph
                log_info("...graph model stored as pkg_graph.")
            }
            return(private$cache$pkg_graph)
        },

        graph_viz = function(){
            if (is.null(private$cache$graph_viz)) {
                private$cache$graph_viz <- private$plot_network()
            }
            return(private$cache$graph_viz)
        },

        layout_type = function(layout) {
            # If user using <- assignment, set layout and reset viz
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
            # Otherwise, return the cached value
            return(private$private_layout_type)
        }
    ) # /active

    , private = list(
        plotNodeColorScheme = list(
            field = NULL
            , palette = '#97C2FC'
        ),

        # Default graph viz layout
        private_layout_type = "layout_nicely",

        # Class of graph to initialize
        # Should be constructor
        graph_class = NULL,

        # Protected private variables
        cache = list(
            nodes = NULL,
            edges = NULL,
            pkg_graph = NULL,
            network_measures = list(),
            graph_viz = NULL
        ),

        # Placeholder methods to extract ndoes and edges
        extract_nodes = function() {
            log_fatal('Node extraction not implemented for this reporter.')
        },
        extract_edges = function() {
            log_fatal('Edge extraction not implemented for this reporter.')
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
                sapply(x, function(color_string) {
                    tryCatch({
                        is.matrix(col2rgb(color_string))
                    }, error = function(e){
                        FALSE
                    })
                })
            }

            colorChecks <- areColors(palette)
            if (!all(colorChecks)) {
                notColors <- names(colorChecks)[colorChecks == FALSE]
                notColorsTXT <- paste(notColors, collapse = ", ")
                log_fatal(sprintf(
                    "The following are invalid colors: %s"
                    , notColorsTXT
                ))
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

        # Function to update nodes data.table in-place
        update_nodes = function(newColsDT) {
            log_info('Updating cached nodes data.table with metadata...')

            # Validate that input has node column
            assertthat::assert_that(
                "node" %in% names(newColsDT)
                , anyDuplicated(newColsDT, by = 'node') == 0
            )

            data.table::setkeyv(newColsDT, 'node')

            # Iterate through each column and assign to nodes data.table inplace
            colsToAdd <- setdiff(names(newColsDT), "node")
            for (colName in colsToAdd) {
                self$nodes[, eval(colName) := newColsDT[node, get(colName)]]
            }

            return(invisible(NULL))
        },

        # Creates visNetwork graph viz object
        # Uses pkg_graph active binding
        plot_network = function(){

            log_info("Plotting graph visualization...")

            log_info(paste("Using igraph layout:", self$layout_type))

            ## FORMAT NODES ##

            # format for plot
            plotDTnodes <- data.table::copy(self$nodes) # Don't modify original
            plotDTnodes[, id := node]
            plotDTnodes[, label := id]

            ## Color Nodes

            # This flag controls whether nodes are colored by categorical
            # groups or some continuous attribute
            colorByField <- !is.null(private$plotNodeColorScheme[['field']])

            if (!colorByField){

                # Default Color for all Nodes
                plotDTnodes[, color := private$plotNodeColorScheme[['palette']]]

            }

            if (colorByField){

                colorFieldName <- private$plotNodeColorScheme[['field']]
                nodeColorPalette <- private$plotNodeColorScheme[['palette']]

                # If that column doesn't exist, throw an error
                if (!is.element(colorFieldName, names(self$nodes))) {
                    msg <- sprintf(
                        "'%s' is not a field in the nodes table and as such cannot be used in plot color scheme."
                        , colorFieldName
                    )
                    log_fatal(msg)
                }

                # if that column isn't a type we recognize, throw an error
                colorFieldValues <- plotDTnodes[, unique(get(colorFieldName))]
                colorFieldIsContinuous <- is.numeric(colorFieldValues)
                colorFieldIsCategorical <- is.character(colorFieldValues) | is.factor(colorFieldValues)
                if (!(colorFieldIsContinuous | colorFieldIsCategorical)){
                    msg <- sprintf(
                        "A character, factor, or numeric field can be used to color nodes. Field '%s' is of type '%s'."
                        , colorFieldName
                        , typeof(colorFieldValues)
                    )
                    log_fatal(msg)
                }

                log_info(sprintf("Coloring plot nodes by field '%s'...", colorFieldName))

                # For categorical coloring, all nodes stay at the default color unless the value
                # of colorFieldValues is found in the provided palette
                if (colorFieldIsCategorical){

                    for (val in names(nodeColorPalette)){
                        thisColor <- nodeColorPalette[[val]]
                        plotDTnodes[get(colorFieldName) == val, color := thisColor]
                    }

                    # Set the group column to the field
                    plotDTnodes[, group := get(colorFieldName)]
                }

                # For continuous coloring, use a ramp palette
                if (colorFieldIsContinuous){

                    newPalette <- grDevices::colorRamp(
                        colors = nodeColorPalette
                    )

                    # Scale Values to be with range 0 - 1
                    plotDTnodes[
                        !is.na(get(colorFieldName))
                        , scaledColorValues := get(colorFieldName) / max(get(colorFieldName))
                    ]

                    # Assign Color Values From Palette
                    plotDTnodes[
                        !is.na(scaledColorValues)
                        , color := grDevices::rgb(
                            newPalette(scaledColorValues)
                            , maxColorValue = 255
                        )
                    ]

                    # NA Values get gray color
                    plotDTnodes[is.na(scaledColorValues), color := "gray"]
                }
            }

            # Order nodes alphabetically to make them easier to find in dropdown
            data.table::setkeyv(plotDTnodes, 'id')

            ## END FORMAT NODES##

            ## FORMAT EDGES ##

            if (length(self$edges) > 0) {
                plotDTedges <- data.table::copy(self$edges) # Don't modify original
                plotDTedges[, from := SOURCE]
                plotDTedges[, to := TARGET]
                plotDTedges[, color := '#848484']
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

            if (colorByField) {
                # Add group definitions
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

                palette_vec <- private$plotNodeColorScheme[["palette"]]
                legendControlDT <- data.table::data.table(
                    label = names(palette_vec)
                    , color = unname(palette_vec)
                )
                legendControlDT[, shape := "ellipse"]

                # when you draw circles or ellipses in visNetwork::addLegend(),
                # their width is determined by the number of characters
                # in the label you write. Pad the labels with whitespace
                # to get shapes of the same size.
                label_lengths <- legendControlDT[, nchar(label)]
                new_labels <- sapply(
                    X = legendControlDT[, label]
                    , FUN = function(label_val, max_length){
                        num_spaces_to_add <- max_length - nchar(label_val)
                        return(paste0(
                            label_val
                            , paste0(rep(" ", num_spaces_to_add), collapse = "")
                        ))
                    }
                    , max_length = max(label_lengths)
                )
                legendControlDT[, label := new_labels]

                # Add legend
                g <- visNetwork::visLegend(
                    graph = g
                    , position = "right"
                    , main = list(
                        text = colorFieldName
                        , style = 'font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;text-align:center;'
                    )
                    , zoom = FALSE
                    , addNodes = legendControlDT
                    , useGroups = FALSE
                    , enabled = TRUE
                )
            }

            log_info("...done plotting visualization.")

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

    ) # /private
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
