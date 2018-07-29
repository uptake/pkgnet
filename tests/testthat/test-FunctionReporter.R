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

test_that('FunctionReporter structure is as expected', {
  
  expect_named(object = FunctionReporter$public_methods
               , expected = c(
                 "get_summary_view",
                 "clone"
               )
               , info = "Available public methods for FunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = FunctionReporter$public_fields
               , expected = NULL
               , info = "Available public fields for FunctionReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('FunctionReporter Methods Work', {
  testObj <- FunctionReporter$new()
  
  # inherited set_package
  expect_silent({
      testObj$set_package(
        pkg_name = "baseballstats"
        # Covr only works on source code. find.package path will not work
        # covr also requires an absolute path, which is provided by system.file
        , pkg_path = system.file("baseballstats"
                                 , package = "pkgnet"
                                 , lib.loc = testLibPath
                                 )
      )
  })
  
  # inherited get_package
  expect_equal(object = testObj$pkg_name
               , expected = "baseballstats"
               , info = "get_package did not return expected package name")
  
  # "extract_network"
  testObj$.__enclos_env__$private$extract_network()
  
  expect_named(object = testObj$edges
               , expected = c("SOURCE", "TARGET")
               , info = "more than SOURCE and TARGET fields created by extract_network"
  )
  
  expect_true(object = all(testObj$edges[,unique(SOURCE, TARGET)] %in% c("at_bats"
                                                                       , "batting_avg"
                                                                       , "slugging_avg")
                           )
              , info = "unexpected function dependencies derived for baseballstats"
  )
  
  # TODO: Need to test that nodes were properly extracted
  testNodeDT <- testObj$nodes
 
  # inherited make_graph_object
  expect_silent(object = testPkgGraph <- testObj$pkg_graph)
  
  expect_true(object = igraph::is_igraph(testPkgGraph)
              , info = "Graph object not and igraph formatted object")
  
  expect_true(object = all(igraph::get.vertex.attribute(testPkgGraph)[[1]] %in% testNodeDT$node)
              , info = "Graph nodes not as expected")

  # Nodes table with coverage and metrics too
  # TODO: Test that calculate_all_measures and other calculates attach metadata correctly
  # expect_identical(object = sort(testObj$get_raw_data()$nodes$node)
  #                  , expected = sort(testNodeDT$node)
  #                  , info = "Different nodes than expected")
  
  
  # network measures
  expect_true({
      suppressWarnings({
          all( c("centralization.OutDegree",
                 "centralization.betweenness",
                 "centralization.closeness"
          ) %in% names(testObj$network_measures))
      })
  } , info = "Not all expected network measures are in network_measures list")
  expect_true(object = all( c("outDegree",
                              "outBetweeness",
                              "outCloseness",
                              "numDescendants",
                              "hubScore",
                              "pageRank",
                              "inDegree") %in% names(testObj$nodes))
              , info = "Not all expected network measures are in nodes data.table"
  )
  
  # coverage
  expect_true(object = all( c("coverageRatio"
                              , "meanCoveragePerLine"
                              , "totalLines"
                              , "coveredLines"
                              , "filename") %in% names(testObj$nodes)
                            )
              , info = "Not all expected function coverage measures are in nodes table"
  )
  
  expect_true(object = all(igraph::get.vertex.attribute(testObj$pkg_graph)[[1]] %in% igraph::get.vertex.attribute(testPkgGraph)[[1]])
              , info = "pkgGraph field nodes not as expected")
  
  expect_identical(object = igraph::get.edgelist(testObj$pkg_graph)
                   , expected = igraph::get.edgelist(testPkgGraph)
                   , info = "pkgGraph field edges not as expected")
})


test_that("FunctionReporter rejects bad packages with an informative error", {
    expect_error({
        testObj <- FunctionReporter$new()
        testObj$set_package(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find a package called 'w0uldNEverB33aPackageName'")
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
