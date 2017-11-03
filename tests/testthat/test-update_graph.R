# context("Graph updating methods")
# 
# # Configure logger (suppress all logs in testing)
# loggerOptions <- futile.logger::logger.options()
# if (!identical(loggerOptions, list())){
#     origLogThreshold <- loggerOptions[[1]][['threshold']]    
# } else {
#     origLogThreshold <- futile.logger::INFO
# }
# futile.logger::flog.threshold(0)
# 
# ##### TEST SETUP #####
# 
# # Need to manually install the dummy package we use for testing `pkgnet`.
# # This if block is to protect against some craziness that happens when
# # covr runs tests. TL;DR covr runs your tests in a temp file so the package
# # source isn't available to you.
# if (dir.exists('../inst/baseballstats')){
#     devtools::install('../inst/baseballstats', force = FALSE)
# }
# 
# # Find the path to the "baseballstats" package we use to test pkgnet
# # (can get a weird path if you're in development mode)
# TEST_PKG_PATH <- file.path(.libPaths()[1], 'pkgnet', 'baseballstats')
# 
# 
# # Create a valid input
# 
# 
# ##### RUN TESTS #####
# 
# #--- 1. .UpdateNodes
# 
#     # Should run end-to-end for working inputs
#     test_that(".UpdateNodes should run end-to-end without error", {expect_true({
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         pkgnet:::.UpdateNodes(baseballGraph, data.table::data.table(node = c('batting_avg', 'slugging_avg')
#                                                                     , some_stat = rnorm(2)))
#         TRUE
#         })
#     })
# 
#     # Should do what we expect
#     test_that(".UpdateNodes should run work as expected", {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph <- pkgnet:::.UpdateNodes(baseballGraph
#                                                , data.table::data.table(node = c('batting_avg', 'slugging_avg')
#                                                                         , some_stat = rnorm(2)))
#         
#         expect_true('some_stat' %in% names(baseballGraph[["nodes"]]))
#         expect_true('list' %in% class(baseballGraph))
#         expect_named(baseballGraph, c('nodes', 'edges', 'networkMeasures'),
#                      ignore.case = FALSE, ignore.order = TRUE)
#     })
# 
#     # Should break with an informative error if the thing has no "nodes"
#     test_that('.UpdateNodes should break with an informative error for a pkgGraph missing nodes', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph[["nodes"]] <- NULL
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNodes(baseballGraph
#                                                    , data.table::data.table(node = c('batting_avg', 'slugging_avg')
#                                                                             , some_stat = rnorm(2)))
#             }
#             , regexp = "Did you generate pkgGraph with ExtractFunctionNetwork")
#     })
#     
#     # Should break with an informative error if "nodes" isn't a data.table
#     test_that('.UpdateNodes should break with an informative error for a pkgGraph missing nodes', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph[["nodes"]] <- list(thing1 = 5, thing2 = 7.0)
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNodes(baseballGraph
#                                                    , data.table::data.table(node = c('batting_avg', 'slugging_avg')
#                                                                             , some_stat = rnorm(2)))
#         }
#         , regexp = "element of pkgGraph should be a data\\.table")
#     })
#     
#     # Should break with an informative error if "nodes" isn't a data.table
#     test_that('.UpdateNodes should break with an informative error if metadataDT is not a data.table', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNodes(baseballGraph
#                                                    , list(node = c('batting_avg', 'slugging_avg')
#                                                           , some_stat = rnorm(2)))
#         }
#         , regexp = "the object passed to metadataDT should be a data\\.table")
#     })
#     
#     # Should break with an informative error if metadataDT has no "node" columns
#     test_that('.UpdateNodes should break with an informative error if metadataDT is not a data.table', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNodes(baseballGraph
#                                                    , data.table::data.table(item = c('batting_avg', 'slugging_avg')
#                                                                             , some_stat = rnorm(2)))
#         }
#         , regexp = "metadataDT should have a column called 'node'")
#     })
# 
# #--- 2. .UpdateNetworkMeasures
# 
#     # Should run end-to-end for working inputs
#     test_that(".UpdateNetworkMeasures should run end-to-end without error", {expect_true({
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         result <- pkgnet:::.UpdateNetworkMeasures(baseballGraph, list(awesomeness = 11))
#         TRUE
#         })
#     })
#     
#     # Should do what we expect
#     test_that(".UpdateNetworkMeasures should work as expected", {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph
#                                                         , list(thing = 21, stuff = 11.9))
#         
#         expect_true('list' %in% class(baseballGraph))
#         expect_named(baseballGraph, c('nodes', 'edges', 'networkMeasures'),
#                      ignore.case = FALSE, ignore.order = TRUE)
#         expect_true(baseballGraph[['networkMeasures']][['thing']] == 21)
#         expect_true(baseballGraph[['networkMeasures']][['stuff']] == 11.9)
#     })
#     
#     # Should replace a value if we update a thing
#     test_that(".UpdateNetworkMeasures should update a metric if it exists already", {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph
#                                                          , list(thing = 21, stuff = 11.9))
#         baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph
#                                                          , list(thing = -50))
#         
#         expect_true('list' %in% class(baseballGraph))
#         expect_named(baseballGraph, c('nodes', 'edges', 'networkMeasures'),
#                      ignore.case = FALSE, ignore.order = TRUE)
#         expect_true(baseballGraph[['networkMeasures']][['thing']] == -50)
#         expect_true(baseballGraph[['networkMeasures']][['stuff']] == 11.9)
#     })
#     
#     # Should break with an informative error if the thing has no "nodes"
#     test_that('.UpdateNetworkMeasures should break with an informative error for a pkgGraph missing nodes', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph[["nodes"]] <- NULL
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph
#                                                             , list(thing = 21, stuff = 11.9))
#         }
#         , regexp = "Did you generate pkgGraph with ExtractFunctionNetwork")
#     })
#     
#     # Should break with an informative error if "nodes" isn't a data.table
#     test_that('.UpdateNetworkMeasures should break with an informative error for a pkgGraph that is not a data.table', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         baseballGraph[["nodes"]] <- list(thing1 = 5, thing2 = 7.0)
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph
#                                                    , data.table::data.table(node = c('batting_avg', 'slugging_avg')
#                                                                             , some_stat = rnorm(2)))
#         }
#         , regexp = "element of pkgGraph should be a data\\.table")
#     })
#     
#     # Should break with an informative error if "nodes" isn't a data.table
#     test_that('.UpdateNetworkMeasures should break with an informative error if networkMeasureList is not a list', {
#         baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
#         expect_error({
#             baseballGraph <- pkgnet:::.UpdateNetworkMeasures(baseballGraph, c(awesomeness = 10))
#         }
#         , regexp = "the object passed to networkMeasureList should be a list")
#     })
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()