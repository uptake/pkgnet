# context("Graph-creation functions")
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
# ##### RUN TESTS #####
# 
# #--- 1. ExtractNetwork
# 
#     # ExtractNetwork should run end-to-end
#     test_that('ExtractNetwork runs end-to-end', expect_true({
#                 x <- ExtractNetwork(pkgName = 'baseballstats'
#                                     , pkgPath = TEST_PKG_PATH)
#                 TRUE
#     }))
# 
# #--- 2. PlotNetwork
# 
#     # PlotNetwork should run end-to-end
#     test_that('PlotNetwork runs end-to-end', expect_true({
#         baseballGraph <- ExtractNetwork(pkgName = 'baseballstats'
#                                         , pkgPath = TEST_PKG_PATH)
#         plotObject <- PlotNetwork(baseballGraph, colorFieldName = 'test_coverage')
#         TRUE
#     }))
#     
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()
