context("Creation of graph of package functions")

# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
    origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
    origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### TEST SETUP #####

# Need to manually install the dummy package we use for testing `pkgnet`.
# This if block is to protect against some craziness that happens when
# covr runs tests. TL;DR covr runs your tests in a temp file so the package
# source isn't available to you.
if (dir.exists('../../inst/baseballstats')){
    devtools::install('../../inst/baseballstats', force = FALSE)
}

if (dir.exists('../../inst/sartre')){
  devtools::install('../../inst/sartre', force = FALSE)
}

# Find the path to the "baseballstats" package we use to test pkgnet
# (can get a weird path if you're in development mode)
TEST_PKG_PATH_BBALL <- file.path(.libPaths()[1], 'pkgnet', 'baseballstats')
TEST_PKG_PATH_SARTRE <- file.path(.libPaths()[1], 'pkgnet', 'sartre')

##### RUN TESTS #####


  test_that('PackageFunctionReporter returns graph of functions', {
        t <- PackageFunctionReporter$new()
        t$set_package(packageName = "baseballstats")
        t$calculate_metrics()
        
        # Nodes
        expect_equivalent(object = t$get_raw_data()$nodes$node
                          , expected = as.character(unlist(utils::lsf.str(asNamespace(t$get_package()))))
                          , info = "All functions are nodes, even ones without connections.")
        
        expect_true(object = is.element("node", names(t$get_raw_data()$nodes))
                    , info = "Node column created")
        
        expect_s3_class(object = t$get_raw_data()$nodes
                        , class =  "data.table")
        
        # Edges
        expect_s3_class(object = t$get_raw_data()$edges
                        , class =  "data.table")
        
        expect_true(object = all(c("TARGET", "SOURCE") %in% names(t$get_raw_data()$edges))
                    , info = "TARGET and SCORE fields in edge table at minimum")

        # Plots
        expect_silent(object = t$plot_network())
        
  })

  test_that('PackageFunctionReporter works on edge case one function', {
    t2 <- PackageFunctionReporter$new()
    t2$set_package('sartre')
    t2$calculate_metrics()
    
    expect_true(object = (nrow(t2$get_raw_data()$nodes) == 1)
                , info = "One row in nodes table."
                )
    
    expect_true(object = is.null(t2$get_raw_data()$edges)
                , info = "Edges table is null since there are no edges."
                )
    
    expect_silent(object = t2$plot_network())
    
  })


##### TEST TEAR DOWN #####
futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
