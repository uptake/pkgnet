# context("Coverage functions")
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
# 
# # Find the path to the "baseballstats" package we use to test pkgnet
# # (can get a weird path if you're in development mode)
# TEST_PKG_PATH <- file.path(.libPaths()[1], 'pkgnet', 'baseballstats')
# 
# 
# ##### RUN TESTS #####
# 
# #--- 1. GetCoverageByFunction
# 
#     # GetCoverageByFunction should run end-to-end without errors
#     test_that('GetCoverageByFunction runs end-to-end', expect_true({
#         result <- GetCoverageByFunction(pkgPath = TEST_PKG_PATH)
#         TRUE
#     }))
#     
#     # GetCoverageByFunction should have the expected output values for a
#     # partially-connected package
#     test_that('GetCoverageByFunction works as expected', {
#         resultDT <- GetCoverageByFunction(pkgPath = TEST_PKG_PATH)
#         
#         expect_true('data.table' %in% class(resultDT))
#         expect_true(all(grepl('R.*\\.R$', resultDT$filename)))
#         expect_true(sum(resultDT$test_coverage) == 100)
#         expect_named(resultDT, c('filename', 'node', 'test_coverage'))
#     })
# 
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()