context("DirectedGraph Class Tests")
rm(list = ls())

##### TEST SET UP #####



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
        nodes = data.table::fread(file.path('testdata', 'milne_function_edges.csv'))
        , edges = data.table::fread(file.path('testdata', 'milne_function_edges.csv'))
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

    # $available_node_measures() returns values
    expect_true({is.character(testObj$available_node_measures())})
    expect_true({length(testObj$default_node_measures()) > 0})

    # $default_node_measures() returns values
    expect_true({is.character(testObj$default_node_measures())})
    expect_true({length(testObj$default_node_measures()) > 0})
    expect_true({
        all(testObj$default_node_measures() %in% testObj$available_node_measures())
    })

    # $graph_measures() returns list
    expect_true({is.list(testObj$graph_measures())})

    # $available_graph_measures() returns values
    expect_true({is.character(testObj$available_graph_measures())})
    expect_true({length(testObj$default_graph_measures()) > 0})

    # $default_graph_measures() returns values
    expect_true({is.character(testObj$default_graph_measures())})
    expect_true({length(testObj$default_graph_measures()) > 0})
    expect_true({
        all(testObj$default_graph_measures() %in% testObj$available_graph_measures())
    })

    # $print() runs without error
    expect_true({
        testObj$print
        TRUE
    })
})

### VALUES OF MEASURE FUNCTIONS ARE EXPECTED ###

testList <- list(
    list(pkg = 'baseballstats', reporter = 'DependencyReporter')
    , list(pkg = 'baseballstats', reporter = 'FunctionReporter')
    , list(pkg = 'milne', reporter = 'InheritanceReporter')
)

for (thisTest in testList) {
    test_that(
        sprintf('DirectedGraph node measure values are expected for %s, %s'
            , thisTest[['pkg']], thisTest[['reporter']]
        ), {

        expectedNodeMeasuresDT <- data.table::fread(file.path('testdata'
            , sprintf('node_measures_%s_%s.csv'
                      , thisTest[['pkg']], thisTest[['reporter']])
        ))

        reporter <- get(thisTest[['reporter']])$new()$set_package(thisTest[['pkg']])

        for (nodeMeas in reporter$pkg_graph$available_node_measures()) {

            expect_equivalent(
                object = reporter$pkg_graph$node_measures(nodeMeas)
                , expected = expectedNodeMeasuresDT[, .SD, .SDcols = c('node', nodeMeas)]
                , ignore.col.order = TRUE
                , ignore.row.order = TRUE
                , info = sprintf("Value testing for %s, %s : %s"
                                 , thisTest[['pkg']]
                                 , thisTest[['reporter']]
                                 , nodeMeas)
            )
        } # /for nodeMeas
    }) # /test_that
} # /for thisTest

for (thisTest in testList) {
    test_that(
        sprintf('DirectedGraph graph measure values are expected for %s, %s'
                , thisTest[['pkg']], thisTest[['reporter']]
        ), {

        expectedGraphMeasuresDT <- data.table::fread(file.path('testdata'
            , sprintf('graph_measures_%s_%s.csv'
            , thisTest[['pkg']], thisTest[['reporter']])
        ))

        reporter <- get(thisTest[['reporter']])$new()$set_package(thisTest[['pkg']])

        for (graphMeas in reporter$pkg_graph$available_graph_measures()) {
            expect_equivalent(
                object = reporter$pkg_graph$graph_measures(graphMeas)
                , expected = expectedGraphMeasuresDT[measure == graphMeas, value]
                , ignore.col.order = TRUE
                , ignore.row.order = TRUE
                , info = sprintf("Value testing for %s, %s : %s"
                                 , thisTest[['pkg']]
                                 , thisTest[['reporter']]
                                 , nodeMeas)
            )
        } # /for graphMeas
        }) # /test_that
} # /for thisTest
