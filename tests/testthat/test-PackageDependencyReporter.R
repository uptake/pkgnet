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
                 "calculate_metrics", 
                 "extract_network", 
                 "clone"
               )
               , info = "Available public methods for PackageDependencyReporter not as expected."
  )
  
  expect_named(object = PackageDependencyReporter$public_fields
               , expected = NULL
               , info = "Available public fields for PackageDependencyReporter not as expected."
  )
  
  expect_named(object = PackageDependencyReporter$private_methods
               , expected = NULL
               , info = "Available private methods for PackageDependencyReporter not as expected."
  )
  
  expect_named(object = PackageDependencyReporter$private_fields
               , expected = NULL
               , info = "Available private fields for PackageDependencyReporter not as expected."
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('PackageDependencyReporter Methods Work', {
  testObj <- PackageDependencyReporter$new()
  
  # inherited set_package
  expect_silent(object = testObj$set_package(packageName = "baseballstats"
                                             , packagePath = find.package("baseballstats")) 
  )
  
  expect_equal(object = testObj$get_raw_data()$packageName
               , expected = "baseballstats"
               , info = "set_package did not set expected package name")
  
  expect_equal(object = testObj$get_raw_data()$packagePath
               , expected = find.package("baseballstats")
               , info = "set_package did not set expected package path")
  
  
  # inherited get_package
  
  expect_equal(object = testObj$get_package()
               , expected = "baseballstats"
               , info = "get_package did not return expected package name")
  
  expect_equal(object = testObj$get_package_path()
               , expected = find.package("baseballstats")
               , info = "get_package did not return expected package path")
  
  # "extract_network"
  
  expect_silent(object = edgeNetwork <- testObj$extract_network())
  
  expect_named(object = edgeNetwork
               , expected = c("SOURCE", "TARGET")
               , info = "more than edges created by extract_network"
  )
  
  expect_true(object = all(edgeNetwork[,unique(SOURCE, TARGET)] %in% c("baseballstats",
                                                                       "methods",
                                                                       "methods",
                                                                       "stats",
                                                                       "stats",
                                                                       "stats",
                                                                       "graphics"))
              , info = "unexpected package dependencies derived for baseballstats"
  )
  
  # nodes
  testNodeDT <- data.table::data.table(node = unique(c(edgeNetwork[, SOURCE], edgeNetwork[, TARGET])))
  
  
  # inherited make_graph_object
  
  expect_silent(object = testPkgGraph <- AbstractGraphReporter$private_methods$make_graph_object(edges = edgeNetwork
                                                                                                 , nodes = testNodeDT)
  )
  
  expect_true(object = igraph::is_igraph(testPkgGraph)
              , info = "Graph object not and igraph formatted object")
  
  expect_true(object = all(igraph::get.vertex.attribute(testPkgGraph)[[1]] %in% testNodeDT$node)
              , info = "Graph nodes not as expected")
  
  expect_identical(object = igraph::get.edgelist(testPkgGraph)
                   , expected = matrix(unlist(edgeNetwork), ncol = 2, dimnames = NULL)
                   , info = "Graph edges not as expected")
  
  
  # "calculate_metrics"
  expect_null(object = testObj$get_raw_data()$nodes
              , info = "Nodes table created before calculate_metrics")
  expect_null(object = testObj$get_raw_data()$edges
              , info = "Edges table created before calculate_metrics")
  expect_null(object = testObj$get_raw_data()$pkgGraph
              , info = "pkgGraph created before calculate_metrics")
  
  expect_silent(object = testObj$calculate_metrics())
  
  expect_identical(object = testObj$get_raw_data()$edges
                   , expected = edgeNetwork
                   , info = "Edge data.table not created as expected")
  
  expect_identical(object = testObj$get_raw_data()$nodes
                   , expected = testNodeDT
                   , info = "Nodes data.table not created as expected")
  
  expect_true(object = all(igraph::get.vertex.attribute(testObj$get_raw_data()$pkgGraph)[[1]] %in% igraph::get.vertex.attribute(testPkgGraph)[[1]])
              , info = "pkgGraph field nodes not as expected")
  
  expect_identical(object = igraph::get.edgelist(testObj$get_raw_data()$pkgGraph)
                   , expected = igraph::get.edgelist(testPkgGraph)
                   , info = "pkgGraph field edges not as expected")
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()