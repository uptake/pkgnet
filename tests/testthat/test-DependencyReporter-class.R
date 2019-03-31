context("DependencyReporter Class Tests")
rm(list = ls())

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('DependencyReporter public interface is as expected', {

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

        # DependencyReporter-specific
        , "initialize"
    )

    reporter <- pkgnet::DependencyReporter$new()
    expect_setequal(object = names(reporter)
                    , expected = publicInterfaceExpected)

})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('DependencyReporter works end-to-end for typical use', {
    testObj <- DependencyReporter$new()

    # inherited set_package works, even with pkg_path
    expect_silent({
        testObj$set_package(
            pkg_name = "baseballstats"
            , pkg_path = system.file("baseballstats"
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

test_that('DependencyReporter$report_markdown_path returns path to real file', {
    reporter <- DependencyReporter$new()
    expect_true(is.character(reporter$report_markdown_path))
    expect_true(file.exists(reporter$report_markdown_path))
})

test_that("DependencyReporter does not let you set_package twice", {
    expect_error({
        x <- DependencyReporter$new()
        x$set_package("baseballstats")
        x$set_package("baseballstats")
    }, regexp = "A package has already been set for this reporter")
})

test_that("DependencyReporter rejects bad packages with an informative error", {
    expect_error({
        testObj <- DependencyReporter$new()
        testObj$set_package(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
})


test_that("DependencyReporter should break with an informative error for packages with no deps", {
    expect_error({
        reporter <- DependencyReporter$new()
        reporter$set_package("base")
        reporter$graph_viz
    }, regexp = "consider adding more dependency types in your definition of DependencyReporter")
})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
