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



##### RUN TESTS #####

# Note: Packages 'baseballstats' and 'sartre' are installed by Travis CI before testing
#       and uninstalled after testing.  If running these tests locallaly. 

  test_that('test packages installed alright',{
    context(.GetLibPaths())
    log_info(paste0(".GetLibPaths: ", .GetLibPaths()))
    expect_true(object = require("baseballstats"
                                 , lib.loc = .GetLibPaths()
                                 )
                , info = "Fake test package baseballstats is not installed.")
    
    expect_true(object =  require("sartre"
                                  , lib.loc = .GetLibPaths()
                                  )
                , info = "Fake test package sartre is not installed")
  })

  test_that('FunctionReporter returns graph of functions', {
        reporter <- FunctionReporter$new()
        reporter$set_package(pkg_name = "baseballstats")

        # Nodes
        expect_equivalent(object = sort(reporter$nodes$node)
                          , expected = sort(as.character(unlist(utils::lsf.str(asNamespace(reporter$pkg_name)))))
                          , info = "All functions are nodes, even ones without connections.")
        
        expect_true(object = is.element("node", names(reporter$nodes))
                    , info = "Node column created")
        
        expect_s3_class(object = reporter$nodes
                        , class =  "data.table")
        
        # Edges
        expect_s3_class(object = reporter$edges
                        , class =  "data.table")
        
        expect_true(object = all(c("TARGET", "SOURCE") %in% names(reporter$edges))
                    , info = "TARGET and SCORE fields in edge table at minimum")

        # Plots
        expect_true(object = is.element("visNetwork", attributes(reporter$graph_viz)))
        
  })

  test_that('FunctionReporter works on edge case one function', {
    t2 <- FunctionReporter$new()
    t2$set_package('sartre')
    
    expect_true(
        object = (nrow(t2$nodes) == 1)
        , info = "One row in nodes table."
    )
    
    expect_true(
        object = (nrow(t2$edges) == 0)
        , info = "Edges table is empty since there are no edges."
    )
    
    expect_true(object = is.element("visNetwork", attributes(t2$graph_viz)))
    
  })


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
