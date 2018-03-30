context("Package Dependency Reporter Tests")

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### TESTS #####

## Structure Available ##

test_that('DependencyReporter structure is as expected', {
  
  expect_named(object = DependencyReporter$public_methods
               , expected = c(
                 "get_summary_view",
                 "initialize",
                 "clone"
               )
               , info = "Available public methods for DependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = DependencyReporter$public_fields
               , expected = NULL
               , info = "Available public fields for DependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('DependencyReporter Methods Work', {
  testObj <- DependencyReporter$new()
  
  # inherited set_package
  expect_silent({
      testObj$set_package(
          pkg_name = "baseballstats"
          , pkg_path = system.file('baseballstats', package="pkgnet")
      ) 
  })
  
  # "extract_network"
  expect_silent({
      testObj$.__enclos_env__$private$extract_network()
  })
  
  expect_named(
      object = testObj$edges
      , expected = c("SOURCE", "TARGET")
      , info = "more than edges created by extract_network"
      , ignore.order = FALSE # enforcing this convention
      , ignore.case = FALSE
  )
  
  expect_true(object = all(testObj$edges[,unique(c(SOURCE, TARGET))] %in% c("base",
                                                                            "methods",
                                                                            "utils",
                                                                            "stats",
                                                                            "grDevices",
                                                                            "graphics", 
                                                                            "baseballstats"))
              , info = "unexpected package dependencies derived for baseballstats"
  )
  
  # TODO: Need to test that nodes were properly extracted
  testNodeDT <- testObj$nodes
  
    expect_silent({
        testObj$pkg_graph
    })
  
    expect_true({
        igraph::is_igraph(testObj$pkg_graph)
    }, info = "Graph object not an igraph formatted object")
    
    expect_true({
        all(igraph::get.vertex.attribute(testObj$pkg_graph)[[1]] %in% testNodeDT$node)
    }, info = "Graph nodes not as expected")
    
    expect_true({
        all(igraph::get.vertex.attribute(testObj$pkg_graph)[[1]] %in% igraph::get.vertex.attribute(testObj$pkg_graph)[[1]])
    }, info = "$pkg_graph field nodes not as expected")
    
    expect_identical(
        igraph::get.edgelist(testObj$pkg_graph)
        , expected = igraph::get.edgelist(testObj$pkg_graph)
        , info = "$pkg_graph field edges not as expected"
    )
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
