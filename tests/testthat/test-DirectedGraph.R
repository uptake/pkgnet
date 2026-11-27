##### TEST SET UP #####

milneNodes <- data.table::fread(file.path('testdata', 'milne_function_nodes.csv'))
milneEdges <- data.table::fread(file.path('testdata', 'milne_function_edges.csv'))

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('DirectedGraph public interface is as expected', {

    publicInterfaceExpected <- c(
        # R6 Special Methods
        ".__enclos_env__"
        , "initialize"
        , "clone"
        , "print"

        # AbstractGraph methods
        , "node_measures"
        , "available_node_measures"
        , "default_node_measures"
        , "graph_measures"
        , "available_graph_measures"
        , "default_graph_measures"

        # AbstractGraph fields and active bindings
        , "nodes"
        , "edges"
        , "igraph"
    )

    graphObj <- pkgnet:::DirectedGraph$new(
        nodes = milneNodes
        , edges = milneEdges
    )
    expect_setequal(object = names(graphObj)
                    , expected = publicInterfaceExpected)

})

### USAGE OF PUBLIC METHODS AND FIELDS ###

test_that('DirectedGraph public methods are properly defined and run end-to-end', {

    nodeDT <- data.table::fread(file.path('testdata', 'milne_function_nodes.csv'))
    edgeDT <- data.table::fread(file.path('testdata', 'milne_function_edges.csv'))

    testObj <- pkgnet:::DirectedGraph$new(nodes = nodeDT, edges = edgeDT)

    # $node_measures() returns node table
    expect_true({data.table::is.data.table(testObj$node_measures())})

    # $available_node_measures returns values
    expect_true({is.character(testObj$available_node_measures)})
    expect_true({length(testObj$default_node_measures) > 0})

    # $default_node_measures returns values
    expect_true({is.character(testObj$default_node_measures)})
    expect_true({length(testObj$default_node_measures) > 0})
    expect_true({
        all(testObj$default_node_measures %in% testObj$available_node_measures)
    })

    # $graph_measures() returns list
    expect_true({is.list(testObj$graph_measures())})

    # $available_graph_measures returns values
    expect_true({is.character(testObj$available_graph_measures)})
    expect_true({length(testObj$default_graph_measures) > 0})

    # $default_graph_measures returns values
    expect_true({is.character(testObj$default_graph_measures)})
    expect_true({length(testObj$default_graph_measures) > 0})
    expect_true({
        all(testObj$default_graph_measures %in% testObj$available_graph_measures)
    })

    # $print() runs without error
    expect_true({
        testObj$print
        TRUE
    })
})

### VALUES OF MEASURE FUNCTIONS ARE EXPECTED ###

# tests removed in v0.5.1.  igraph values trusted.  
# Burden of this section of unit tests otherwise unsupportable.

test_that('DirectedGraph inCloseness uses mode = "in"', {

    nodes <- data.table::data.table(node = c("a", "b", "c"))
    edges <- data.table::data.table(
        SOURCE = c("a", "b")
        , TARGET = c("b", "c")
    )
    graphObj <- pkgnet:::DirectedGraph$new(
        nodes = nodes
        , edges = edges
    )

    measuresDT <- graphObj$node_measures(c("outCloseness", "inCloseness"))
    expectedOut <- suppressWarnings(igraph::closeness(
        graph = graphObj$igraph
        , mode = "out"
        , normalized = TRUE
    ))
    expectedIn <- suppressWarnings(igraph::closeness(
        graph = graphObj$igraph
        , mode = "in"
        , normalized = TRUE
    ))

    expect_equal(
        object = measuresDT[, outCloseness]
        , expected = unname(expectedOut[measuresDT[, node]])
    )
    expect_equal(
        object = measuresDT[, inCloseness]
        , expected = unname(expectedIn[measuresDT[, node]])
    )

    expectedGraphIn <- igraph::centralize(
        scores = unname(expectedIn[measuresDT[, node]])
        , theoretical.max = igraph::centr_clo_tmax(
            graph = graphObj$igraph
            , mode = "in"
        )
        , normalized = TRUE
    )
    expect_equal(
        object = graphObj$graph_measures("graphInCloseness")$graphInCloseness
        , expected = expectedGraphIn
    )
})


### EXPECTED ERRORS ###

test_that('DirectedGraph constructor errors on bad inputs', {

    # Inputs are data.tables
    expect_error(
        object = pkgnet:::DirectedGraph$new(
            nodes = 'not_a_data.table'
            , edges = milneEdges
        )
        , regexp = "data.table::is.data.table(x = nodes) is not TRUE"
        , fixed = TRUE
    )
    expect_error(
        object = pkgnet:::DirectedGraph$new(
            nodes = milneNodes
            , edges = 'note_a_data.table'
        )
        , regexp = "data.table::is.data.table(x = edges) is not TRUE"
        , fixed = TRUE
    )

    # Inputs have expected columns
    expect_error(
        object = pkgnet:::DirectedGraph$new(
            nodes = data.table::copy(milneNodes)[, id := node][, node := NULL]
            , edges = milneEdges
        )
        , regexp = '`%in%`(x = "node", table = names(nodes))'
        , fixed = TRUE
    )
    expect_error(
        object = pkgnet:::DirectedGraph$new(
            nodes = milneNodes
            , edges = data.table::copy(milneEdges)[, from := SOURCE][, SOURCE := NULL]
        )
        , regexp = 'c("SOURCE", "TARGET") %in% names(edges)'
        , fixed = TRUE
    )
    expect_error(
        object = pkgnet:::DirectedGraph$new(
            nodes = milneNodes
            , edges = data.table::copy(milneEdges)[, to := TARGET][, TARGET := NULL]
        )
        , regexp = 'c("SOURCE", "TARGET") %in% names(edges)'
        , fixed = TRUE
    )
})
