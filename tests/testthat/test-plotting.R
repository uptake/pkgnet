context("Plotting Tests")

##### TEST SET UP #####

rm(list = ls())

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

    expect_silent({

        b$.__enclos_env__$private$set_plot_node_color_scheme(
            field = "filename"
            , palette = c(
                "#E41A1C"
                , "#377EB8"
                , "#4DAF4A"
                , "#984EA3"
                , "#FF7F00"
                , "#FFFF33"
                , "#A65628"
                , "#F781BF"
                , "#999999"
            )
        )
    })

    viz <- b$graph_viz
    expect_is(viz, "visNetwork")
    expect_is(viz, "htmlwidget")
})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
