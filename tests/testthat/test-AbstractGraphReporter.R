context("AbstractGraphReporter Tests")
rm(list = ls())

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('AbstractGraphReporter public interface is as expected', {

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
    )

    reporter <- pkgnet:::AbstractGraphReporter$new()
    expect_setequal(object = names(reporter)
                    , expected = publicInterfaceExpected)
})

test_that("AbstractGraphReporter layout type setting works", {
    expect_equal(
        object = {
            x <- pkgnet:::AbstractGraphReporter$new()
            x$layout_type <- pkgnet:::.igraphAvailableLayouts()[[1]]
            x$layout_type
        }
        , expected = pkgnet:::.igraphAvailableLayouts()[[1]]
    )
    expect_error({
        x <- pkgnet:::AbstractGraphReporter$new()
        x$layout_type <- 'layout_as_newspaper'
    }, regexp = "layout_as_newspaper is not a supported layout by igraph")
})

test_that("AbstractGraphReporter errors on unimplemented methods", {
    expect_error({
        x <- pkgnet:::AbstractGraphReporter$new()
        x$nodes
    }, regexp = "Node extraction not implemented for this reporter")

    expect_error({
        x <- pkgnet:::AbstractGraphReporter$new()
        x$edges
    }, regexp = "Edge extraction not implemented for this reporter")

    expect_error({
        x <- pkgnet:::AbstractGraphReporter$new()
        x$pkg_graph
    }, regexp = "Reporter must set valid graph class")
})

test_that("AbstractGraphReporter$set_plot_node_color_scheme() correctly sets color palette", {
    x <- pkgnet:::AbstractGraphReporter$new()
    res <- x$.__enclos_env__$private$set_plot_node_color_scheme(
        field = "blegh"
        , palette = c("red", "blue")
    )
    color_scheme <- x$.__enclos_env__$private$plotNodeColorScheme
    expect_identical(
        color_scheme
        , list(field = "blegh", palette = c("red", "blue"))
    )
})

test_that("AbstractGraphReporter$set_plot_node_color_scheme() correctly rejects bad colors", {
    x <- pkgnet:::AbstractGraphReporter$new()
    expect_error({
        res <- x$.__enclos_env__$private$set_plot_node_color_scheme(
            field = "blegh"
            , palette = c("#32CD32", "32CD32")
        )
    }, "The following are invalid color")
})

### HELPER FUNCTIONS

test_that(".igraphAvailableLayouts returns layouts correctly", {
    expect_true({
        length(pkgnet:::.igraphAvailableLayouts()) > 0
    })
})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
