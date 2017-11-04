# context("Network feature generation")
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
# if (dir.exists('../../inst/baseballstats')){
#     devtools::install('../../inst/baseballstats', force = FALSE)
# }
# 
# # Find the path to the "baseballstats" package we use to test pkgnet
# # (can get a weird path if you're in development mode)
# TEST_PKG_PATH <- file.path(.libPaths()[1], 'pkgnet', 'baseballstats')
# 
# # Create a network out of the baseball stats package
# baseballGraph <- ExtractFunctionNetwork(pkgName = 'baseballstats', pkgPath = TEST_PKG_PATH)
# 
# ##### RUN TESTS #####
# 
# #--- 1. MakeGraphObject
# 
#     # MakeGraphObject runs end-to-end without errors
#     test_that("CalcNetworkFeatures runs end-to-end on a partially-connected package", {
#         result <- CalcNetworkFeatures(baseballGraph)
#         TRUE
#     })
# 
#     # MakeGraphObject had the expected outputs
#     test_that("CalcNetworkFeatures runs end-to-end on a partially-connected package", {
#         result <- CalcNetworkFeatures(baseballGraph)
#         
#         expect_named(result, c('networkMeasures', 'nodeMeasures')
#                      , ignore.order = TRUE, ignore.case = FALSE)
#         expect_true('list' %in% class(result))
#         expect_true('list' %in% class(result[["networkMeasures"]]))
#         expect_named(result[["networkMeasures"]], c('centralization.OutDegree', 'centralization.betweenness', 'centralization.closeness'))
#         expect_true('data.table' %in% class(result[["nodeMeasures"]]))
#         expect_true('node' %in% names(result[["nodeMeasures"]]))
#         expect_true("numeric" %in% class(result[["nodeMeasures"]][["outDegree"]]))
#         expect_true("numeric" %in% class(result[["nodeMeasures"]][["pageRank"]]))
#         expect_identical(nrow(result[["nodeMeasures"]]), length(ls("package:baseballstats")))
#     })
# 
# #### TEST EMPTY PACKAGE ####
#     
# if (dir.exists('../../inst/sartre')){
#   devtools::install('../../inst/sartre', force = FALSE)
# }
#     
# NOTHING_PKG_PATH <- file.path(.libPaths()[1], 'pkgnet', 'sartre')
# 
# # TESTS
# 
# test_that('Extract Network Handles No Network Edge Case', {
#   expect_warning(ExtractFunctionNetwork("sartre")
#                , regexp = "No Network Available\\.  Only one function in"
#                )
#   testNW <- suppressWarnings(ExtractFunctionNetwork("sartre"))
#   expect_named(testNW
#                , expected = c('nodes', 'edges', 'networkMeasures')
#                , ignore.order = TRUE
#                , info = "Has standard three elements"
#                )
#   
#   expect_named(testNW[['nodes']]
#                , expected = c('nodes', 'level', 'horizontal')
#                , ignore.order = TRUE
#                , info = "Has standard node columns"
#   )
#   
#   expect_equal(nrow(testNW[['nodes']]), 1, info = "One row for One Node")
#   
# })
# 
# test_that('Extract Dependency Network Handles No Network Edge Case', {
#   expect_warning(ExtractDependencyNetwork("sartre")
#                , regexp = "Could not resolve dependencies for package"
#   )
#   testNW <- suppressWarnings(ExtractDependencyNetwork("sartre"))
#   expect_named(testNW
#                , expected = c('nodes', 'edges', 'networkMeasures')
#                , ignore.order = TRUE
#                , info = "Has standard three elements"
#   )
#   
#   expect_named(testNW[['nodes']]
#                , expected = c('nodes', 'level', 'horizontal')
#                , ignore.order = TRUE
#                , info = "Has standard node columns"
#   )
#   
#   expect_equal(nrow(testNW[['nodes']]), 1, info = "One row for One Node")
# })
# 
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()