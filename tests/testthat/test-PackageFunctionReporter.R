context("Package Function Reporter Tests")

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
# expect_silents only work with this logger turned off; only alerts with warnings
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### TESTS #####

## Structure Available ##

test_that('PackageFunctionReporter structure is as expected', {
  
  expect_named(object = PackageFunctionReporter$public_methods
               , expected = c(
                 "calculate_metrics", 
                 "extract_network", 
                 "clone"
               )
               , info = "Available public methods for PackageFunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageFunctionReporter$public_fields
               , expected = NULL
               , info = "Available public fields for PackageFunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageFunctionReporter$private_methods
               , expected = c("package_test_coverage")
               , info = "Available private methods for PackageFunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = PackageFunctionReporter$private_fields
               , expected = NULL
               , info = "Available private fields for PackageFunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('PackageFunctionReporter Methods Work', {
  testObj <- PackageFunctionReporter$new()
  
  # inherited set_package
  expect_silent(object = testObj$set_package(packageName = "baseballstats"
                                             # Covr only works on source code. find.package path will not work
                                             , packagePath = system.file("baseballstats",package="pkgnet")
                                             ) 
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
  
  expect_silent(object = edgeNetwork <- testObj$extract_network())
  
  expect_named(object = edgeNetwork
               , expected = c("SOURCE", "TARGET")
               , info = "more than SOURCE and TARGET fields created by extract_network"
  )
  
  expect_true(object = all(edgeNetwork[,unique(SOURCE, TARGET)] %in% c("at_bats"
                                                                       , "batting_avg"
                                                                       , "slugging_avg")
                           )
              , info = "unexpected function dependencies derived for baseballstats"
  )
  
  # nodes
  testNodeDT <- data.table::data.table(node = as.character(unlist(utils::lsf.str(asNamespace(testObj$get_package())))))
  
  
  
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
  
  # Nodes table with coverage and metrics too

  expect_identical(object = sort(testObj$get_raw_data()$nodes$node)
                   , expected = sort(testNodeDT$node)
                   , info = "Different nodes than expected")
  
  # network measures
  expect_true(object = all( c("outDegree",
                            "outBetweeness",
                            "outCloseness",
                            "numDescendants",
                            "hubScore",
                            "pageRank",
                            "inDegree") %in% names(testObj$get_raw_data()$nodes))
              , info = "Not all expected network measures are in nodes table"
  )
  
  # coverage
  #TODO this will need to be updated after PR #40
  expect_true(object = all( c("coverage") %in% names(testObj$get_raw_data()$nodes))
              , info = "Not all expected function coverages measures are in nodes table"
  )
  
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