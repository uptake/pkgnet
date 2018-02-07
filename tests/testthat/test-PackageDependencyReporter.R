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

test_that('PackageDependencyReporter structure is as expected', {
  
  expect_named(object = PackageDependencyReporter$public_methods
               , expected = c(
                 "calculate_all_metrics", 
                 "get_report_markdown_path",
                 "extract_network", 
                 "get_summary_view",
                 "clone"
               )
               , info = "Available public methods for PackageDependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageDependencyReporter$public_fields
               , expected = NULL
               , info = "Available public fields for PackageDependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageDependencyReporter$private_methods
               , expected = c(
                   "recursive_dependencies"
               )
               , info = "Available private methods for PackageDependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageDependencyReporter$private_fields
               , expected = NULL
               , info = "Available private fields for PackageDependencyReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('PackageDependencyReporter Methods Work', {
  testObj <- PackageDependencyReporter$new()
  
  # inherited set_package
  expect_silent(object = testObj$set_package(packageName = "baseballstats"
                                             , packagePath = system.file('baseballstats',package="pkgnet")) 
  )
  
  expect_equal(object = testObj$get_raw_data()$packageName
               , expected = "baseballstats"
               , info = "set_package did not set expected package name")
  
  expect_equal(object = testObj$get_raw_data()$packagePath
               , expected = system.file('baseballstats',package="pkgnet")
               , info = "set_package did not set expected package path")
  
  
  # inherited get_package
  
  expect_equal(object = testObj$get_package()
               , expected = "baseballstats"
               , info = "get_package did not return expected package name")
  
  expect_equal(object = testObj$get_package_path()
               , expected = system.file('baseballstats',package="pkgnet")
               , info = "get_package did not return expected package path")
  
  # "extract_network"
  
  expect_silent(object = networkDTList <- testObj$extract_network())
  
  expect_named(object = networkDTList
               , expected = c("edges", "nodes")
               , info = "extract_network did not return edges and nodes as expected"
               , ignore.order = TRUE
               , ignore.case = FALSE
               )
  
  expect_named(object = networkDTList$edges
               , expected = c("SOURCE", "TARGET")
               , info = "more than edges created by extract_network"
               , ignore.order = FALSE # enforcing this convention
               , ignore.case = FALSE
  )
  
  expect_true(object = all(networkDTList$edges[,unique(c(SOURCE, TARGET))] %in% c("base",
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
  
  # inherited make_graph_object
  
  expect_silent(object = testPkgGraph <- testObj$make_graph_object()
  )
  
  expect_true(object = igraph::is_igraph(testPkgGraph)
              , info = "Graph object not an igraph formatted object")
  
  expect_true(object = all(igraph::get.vertex.attribute(testPkgGraph)[[1]] %in% testNodeDT$node)
              , info = "Graph nodes not as expected")
  
  expect_identical(object = igraph::get.edgelist(testPkgGraph)
                   , expected = matrix(unlist(networkDTList$edges), ncol = 2, dimnames = NULL)
                   , info = "Graph edges not as expected")
  
  expect_true(object = all(igraph::get.vertex.attribute(testObj$pkgGraph)[[1]] %in% igraph::get.vertex.attribute(testPkgGraph)[[1]])
              , info = "pkgGraph field nodes not as expected")
  
  expect_identical(object = igraph::get.edgelist(testObj$pkgGraph)
                   , expected = igraph::get.edgelist(testPkgGraph)
                   , info = "pkgGraph field edges not as expected")
  
  # "calculate_all_metrics"
  # TODO: Need test for this

  expect_silent(object = testObj$calculate_all_metrics())

})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()