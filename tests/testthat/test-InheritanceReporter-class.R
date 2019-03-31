context("InheritanceReporter Class Tests")
rm(list = ls())

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('InheritanceReporter public interface is as expected', {

    publicInterfaceExpected <- c(
        # R6 Special Methods
        ".__enclos_env__"
        , "clone"

        # Graph Reporter fields and active bindings
        , "pkg_name"
        , "nodes"
        , "edges"
        , "pkg_graph"
        , "network_measures"
        , "graph_viz"
        , "layout_type"

        # Graph Reporter methods
        , "set_package"
        , "calculate_default_measures"
        , "get_summary_view"
        , "report_markdown_path"

        # InheritanceReporter-specific
        # N/A
    )

    reporter <- pkgnet::InheritanceReporter$new()
    expect_setequal(object = names(reporter)
                    , expected = publicInterfaceExpected)

})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('InheritanceReporter Methods Work', {
    testObj <- InheritanceReporter$new()

    # inherited set_package works, even with pkg_path
    expect_silent({
        testObj$set_package(
            pkg_name = "milne"
            , pkg_path = system.file("milne"
                                     , package = "pkgnet"
                                     , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
            )
        )
    })

    ## Node and Edge extraction work ##
    expect_silent({
        testObj$nodes
        testObj$edges
    })

    expect_true(data.table::is.data.table(testObj$nodes))
    expect_true(object = is.element("node", names(testObj$nodes))
                , info = "Node column created")

    expect_true(data.table::is.data.table(testObj$edges))
    expect_true(object = all(c("TARGET", "SOURCE") %in% names(testObj$edges))
                , info = "TARGET and SOURCE fields in edge table at minimum")

    ## pkg_graph works ##
    expect_silent({testObj$pkg_graph})
    expect_true({"AbstractGraph" %in% class(testObj$pkg_graph)})
    expect_true({"DirectedGraph" %in% class(testObj$pkg_graph)})
    expect_true({igraph::is_igraph(testObj$pkg_graph$igraph)})
    expect_setequal(
        object = igraph::get.vertex.attribute(testObj$pkg_graph$igraph)[['name']]
        , expected = testObj$nodes[, node]
    )
    expect_setequal(
        object = igraph::get.edgelist(testObj$pkg_graph$igraph)[,1]
        , expected = testObj$edges[, SOURCE]
    )
    expect_setequal(
        object = igraph::get.edgelist(testObj$pkg_graph$igraph)[,2]
        , expected = testObj$edges[, TARGET]
    )

    ## calculate_default_measures works ##
    expect_true({
        testObj$calculate_default_measures()
        TRUE
    })
    # Default node measures were generated
    expect_true({
        all(testObj$pkg_graph$default_node_measures %in% names(testObj$nodes))
    })
    # Default graph measures were generated
    expect_true({
        all(testObj$pkg_graph$default_graph_measures %in% names(testObj$network_measures))
    })

    ## graph_viz works ##
    expect_silent({testObj$graph_viz})
    expect_true(object = is.element("visNetwork", attributes(testObj$graph_viz)))
    expect_equivalent(
        object = as.data.table(testObj$graph_viz$x$nodes)[, .(id)]
        , expected = testObj$nodes[, .(id = node)]
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )
    expect_equivalent(
        object = as.data.table(testObj$graph_viz$x$edges)[, .(from, to)]
        , expected = testObj$edges[, .(from = SOURCE, to = TARGET)]
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )
})

test_that('InheritanceReporter$report_markdown_path returns path to real file', {
    reporter <- InheritanceReporter$new()
    expect_true(is.character(reporter$report_markdown_path))
    expect_true(file.exists(reporter$report_markdown_path))
})

test_that("InheritanceReporter does not let you set_package twice", {
    expect_error({
        x <- InheritanceReporter$new()
        x$set_package("baseballstats")
        x$set_package("baseballstats")
    }, regexp = "A package has already been set for this reporter")
})

test_that("InheritanceReporter rejects bad packages with an informative error", {
    expect_error({
        reporter <- InheritanceReporter$new()
        reporter$set_package(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
})


test_that("InheritanceReporter should give warning for packages with no classes", {
    expect_warning({
        reporter <- InheritanceReporter$new()
        reporter$set_package("baseballstats")
        reporter$edges
    }, regexp = "No S4, Reference, or R6 class definitions found")
})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
