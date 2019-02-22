AbstractGraph <- R6::R6Class(
    classname = "AbstractGraph"
    , public = list(
        initialize = function(nodes, edges) {

            # Store pointers to node and edge data.tables
            private$protected$nodes <- nodes
            private$protected$edges <- edges

            return(invisible(self))
        }

        , node_measures = function(measures = NULL){

            # If not specifying, return node table
            if (is.null(measures)) {
                return(self$nodes)
            }

            assertthat::assert_that(is.character(measures))

            for (m in measures) {
                # Input validation
                assertthat::assert_that(
                    all(m %in% self$available_node_measures())
                    , msg = sprintf('%s not in $available_node_measures()', m)
                )

                # If not already calculated it, calculate and add to node DT
                if (!m %in% names(self$nodes)) {
                    log_info(sprintf("Calculating %s...", m))
                    result <- private$node_measure_functions[[m]](self)
                    resultDT <- data.table::data.table(
                        node_name = names(result)
                        , result = result
                    )
                    setkeyv(resultDT, 'node_name')
                    self$nodes[, eval(m) := resultDT[node, result]]
                }
            }

            return(self$nodes[, .SD, .SDcols = c('node', measures)])
        }

        , available_node_measures = function(){
            names(private$node_measure_functions)
        }

        , graph_measures = function(measures = NULL){

            # If not specifying, return full list
            if (is.null(measures)) {
                return(private$protected$graph_measures)
            }

            assertthat::assert_that(is.character(measures))

            for (m in measures) {
                # Input validation
                assertthat::assert_that(
                    m %in% self$available_graph_measures()
                    , msg = sprintf('%s not in $available_graph_measures()', m)
                )

                # If not already calculated, calculate
                if (!m %in% names(private$protected$graph_measures)) {
                    log_info(sprintf("Calculating %s", m))
                    result <- private$graph_measure_functions[[m]](self)
                    private$protected$graph_measures[[m]] <- result
                }
            }
            return(private$protected$graph_measures[measures])
        }

        , available_graph_measures = function(){
            names(private$graph_measure_functions)
        }

        , print = function(){
            print(self$igraph)
            invisible(self)
        }

    ) # /public

    , active = list(
        # Read-only access to node and edge data.tables
        nodes = function(){return(private$protected$nodes)}
        , edges = function(){return(private$protected$edges)}

        # Read-only access to igraph objects
        , igraph = function(){
            if (is.null(private$protected$igraph)) {
                private$initialize_igraph()
            }
            return(private$protected$igraph)
        }
    ) # /active

    , private = list(
        protected = list(
            nodes = NULL
            , edges = NULL
            , igraph = NULL
            , graph_measures = list()
        )

        , initialize_igraph = function(directed){

            log_info("Constructing igraph object...")

            # Connected graph
            if (nrow(self$edges) > 0) {
                # A graph with edges
                connectedGraph <- igraph::graph.edgelist(
                    as.matrix(self$edges[,list(SOURCE,TARGET)])
                    , directed = directed
                )
            } else {
                connectedGraph <- igraph::make_empty_graph(directed = directed)
            }

            # Unconnected graph
            orphanNodes <- base::setdiff(
                self$nodes[, node]
                , unique(c(self$edges[, SOURCE], self$edges[, TARGET]))
            )
            unconnectedGraph <- igraph::make_empty_graph(directed = directed) + igraph::vertex(orphanNodes)

            # Complete graph
            completeGraph <- connectedGraph + unconnectedGraph

            # Store in protected cache
            private$protected$igraph <- completeGraph

            log_info("...done constructing igraph object.")

            return(invisible(NULL))
        }

        # Functions for node measures
        # All functions should return a named vector of node measure values
        , node_measure_functions = list()

        # Functions for graph-level measures
        # All functions should return numeric of length 1
        , graph_measure_functions = list()

    )  # /private
)

#' @export
DirectedGraph <- R6::R6Class(
    classname = "DirectedGraph"
    , inherit = AbstractGraph
    , public = list(
        default_node_measures = function() {
            return(c(
                "outDegree"
                , "inDegree"
                , "outSubgraphSize"
                , "inSubgraphSize"
                , "betweenness"
                , "pageRank"
            ))
        }

        , default_graph_measures = function() {
            return(c(
                "graphOutDegree"
                , "graphInDegree"
                , "graphBetweenness"
            ))
        }
    ) # / public
    , private = list(

        # Initialize igraph object
        initialize_igraph = function() {
            super$initialize_igraph(directed = TRUE)
        }

        # Functions for node measures
        # All functions should return a named vector of node measure values
        , node_measure_functions = list(

            # Out-Degree
            outDegree = function(self){
                igraph::degree(
                    graph = self$igraph
                    , mode = "out"
                    , loops = TRUE
                )
            }

            # In-Degree
            , inDegree = function(self){
                igraph::degree(
                    graph = self$igraph
                    , mode = "in"
                    , loops = TRUE
                )
            }

            # Out-Closeness
            # Closeness doesn't really work for directed graphs that are not
            # strongly connected.
            # igraph calculates a thing anyways and gives a warning
            # Typically given as normalized values
            , outCloseness = function(self){
                suppressWarnings(igraph::closeness(
                    graph = self$igraph
                    , mode = "out"
                    , normalized = TRUE
                ))
            }

            # In-Closeness
            # Closeness doesn't really work for directed graphs that are not
            # strongly connected.
            # igraph calculates a thing anyways and gives a warning
            # Typically given as normalized values
            , inCloseness = function(self){
                suppressWarnings(igraph::closeness(
                    graph = self$igraph
                    , mode = "out"
                    , normalized = TRUE
                ))
            }

            # Out-Subgraph Size -- Rooted subgraph out from node
            , outSubgraphSize = function(self){
                # Calculate using out-neighborhood size with order of longest
                # possible path
                result <- igraph::neighborhood.size(
                    graph = self$igraph
                    , order = igraph::vcount(self$igraph)
                    , mode = "out"
                )
                # Subtract 1 so we don't include the root node itself
                result <- result - 1
                names(result) <- igraph::V(self$igraph)$name
                return(result)
            }

            # In-Subgraph Size -- Rooted subgraph into node
            , inSubgraphSize = function(self){
                # Calculate using in-neighborhood size with order of longest
                # possible path
                result <- igraph::neighborhood.size(
                    graph = self$igraph
                    , order = igraph::vcount(self$igraph)
                    , mode = "in"
                )
                # Subtract 1 so we don't include the root node itself
                result <- result - 1
                names(result) <- igraph::V(self$igraph)$name
                return(result)
            }

            # Betweenness
            , betweenness = function(self){
                igraph::betweenness(
                    graph = self$igraph
                    , directed = TRUE
                )
            }

            # Page Rank
            , pageRank = function(self){
                igraph::page_rank(
                    graph = self$igraph
                    , directed = TRUE
                )$vector
            }

            # Hub Score
            , hubScore = function(self){
                igraph::hub_score(
                    graph = self$igraph
                    , scale = TRUE
                )$vector
            }

            # Authority Score
            , authorityScore = function(self){
                igraph::authority_score(
                    graph = self$igraph
                    , scale = TRUE
                )$vector
            }

        ) #/node_measure_functions

        # Functions for graph-level measures
        # All functions should return numeric of length 1
        , graph_measure_functions = list(

            graphOutDegree = function(self){
                measure <- 'outDegree'
                igraph::centralize(
                    scores = self$node_measures(measure)[, get(measure)]
                    , theoretical.max = igraph::centr_degree_tmax(
                        graph = self$igraph
                        , mode = "out"
                        , loops = TRUE
                    )
                    , normalized = TRUE
                )
            }

            , graphInDegree = function(self){
                measure <- 'inDegree'
                igraph::centralize(
                    scores = self$node_measures(measure)[, get(measure)]
                    , theoretical.max = igraph::centr_degree_tmax(
                        graph = self$igraph
                        , mode = "in"
                        , loops = TRUE
                    )
                    , normalized = TRUE
                )
            }

            , graphOutCloseness = function(self){
                measure <- 'outCloseness'
                igraph::centralize(
                    scores = self$node_measures(measure)[, get(measure)]
                    , theoretical.max = igraph::centr_clo_tmax(
                        graph = self$igraph
                        , mode = "out")
                    , normalized = TRUE
                )
            }

            , graphInCloseness = function(self){
                measure <- 'inCloseness'
                igraph::centralize(
                    scores = self$node_measures(measure)[, get(measure)]
                    , theoretical.max = igraph::centr_clo_tmax(
                        graph = self$igraph
                        , mode = "in")
                    , normalized = TRUE
                )
            }

            , graphBetweenness = function(self){
                measure <- 'betweenness'
                igraph::centralize(
                    scores = self$node_measures(measure)[, get(measure)]
                    , theoretical.max = igraph::centr_betw_tmax(
                        graph = self$igraph
                        , directed = TRUE)
                    , normalized = TRUE
                )
            }

        ) # /graph_measures_functions
    ) # /private
)
