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
    expect_true(object = require("baseballstats")
                , info = "Fake test package baseballstats is not installed.")
    
    expect_true(object =  require("sartre")
                , info = "Fake test package sartre is not installed")
  })

  test_that('PackageFunctionReporter returns graph of functions', {
        t <- PackageFunctionReporter$new()
        t$set_package(packageName = "baseballstats")
        t$calculate_all_metrics()
        
        # Nodes
        expect_equivalent(object = sort(t$nodes$node)
                          , expected = sort(as.character(unlist(utils::lsf.str(asNamespace(t$get_package())))))
                          , info = "All functions are nodes, even ones without connections.")
        
        expect_true(object = is.element("node", names(t$nodes))
                    , info = "Node column created")
        
        expect_s3_class(object = t$nodes
                        , class =  "data.table")
        
        # Edges
        expect_s3_class(object = t$edges
                        , class =  "data.table")
        
        expect_true(object = all(c("TARGET", "SOURCE") %in% names(t$edges))
                    , info = "TARGET and SCORE fields in edge table at minimum")

        # Plots
        expect_true(object = is.element("visNetwork", attributes(t$graphViz)))
        
  })

  test_that('PackageFunctionReporter works on edge case one function', {
    t2 <- PackageFunctionReporter$new()
    t2$set_package('sartre')
    t2$calculate_all_metrics()
    
    expect_true(object = (nrow(t2$nodes) == 1)
                , info = "One row in nodes table."
                )
    
    expect_true(object = (nrow(t2$edges) == 0)
                , info = "Edges table is empty since there are no edges."
                )
    
    expect_true(object = is.element("visNetwork", attributes(t2$graphViz)))
    
  })


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
