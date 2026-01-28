##### TEST SET UP #####

test_that('node coloring by discrete and continuous', {
    b <- FunctionReporter$new()
    b$set_package('baseballstats'
                  , pkg_path = system.file('baseballstats'
                                           , package = "pkgnet"
                                           , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
                  )
    )

    b$calculate_default_measures()

    b$.__enclos_env__$private$set_plot_node_color_scheme(
        field = "coverageRatio"
        , palette = c("red", "green")
    )

    viz <- b$graph_viz
    expect_is(viz, "visNetwork")
    expect_is(viz, "htmlwidget")
})
