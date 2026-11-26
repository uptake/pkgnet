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

test_that('.scaleNodeSizes maps values to area-proportional radii', {
    sizes <- pkgnet:::.scaleNodeSizes(c(0, 5, 10, NA, Inf), minSize = 10, maxSize = 50)
    expect_equal(sizes[1], 10)
    expect_equal(sizes[3], 50)
    expect_equal(sizes[2]^2, (10^2 + 50^2) / 2)
    expect_true(all(is.na(sizes[4:5])))

    # No spread or no finite values means default sizing
    expect_true(all(is.na(pkgnet:::.scaleNodeSizes(c(3, 3, 3)))))
    expect_true(all(is.na(pkgnet:::.scaleNodeSizes(c(NA_real_, NA_real_)))))
    expect_length(pkgnet:::.scaleNodeSizes(numeric(0)), 0)
})

test_that('graph_viz includes node size selector for numeric node columns', {
    b <- FunctionReporter$new()
    b$set_package('baseballstats'
                  , pkg_path = system.file('baseballstats'
                                           , package = "pkgnet"
                                           , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
                  )
    )
    b$calculate_default_measures()

    viz <- b$graph_viz
    renderHooks <- viz$jsHooks[['render']]
    expect_length(renderHooks, 1)

    hookData <- renderHooks[[1]][['data']]
    numericCols <- names(b$nodes)[vapply(b$nodes, is.numeric, logical(1))]
    expect_identical(names(hookData$sizes), numericCols)
    expect_true("outDegree" %in% names(hookData$sizes))
    expect_identical(hookData$ids, viz$x$nodes$id)
    for (metric in names(hookData$sizes)) {
        expect_length(hookData$sizes[[metric]], length(hookData$ids))
    }

    # Nodes keep their default uniform size until a metric is chosen
    expect_false("size" %in% names(viz$x$nodes))
})
