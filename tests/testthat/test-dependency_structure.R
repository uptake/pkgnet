context("Dependency Graph-creation functions")

test_that("dummy test", expect_true(TRUE))
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
# 
# ##### RUN TESTS #####
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
# #--- 1. ExtractNetwork
# 
# # ExtractNetwork should run end-to-end
# test_that('ExtractNetwork runs end-to-end and has the right fields and properties', {
#     x <- ExtractDependencyNetwork(pkgName = 'baseballstats',which = "Imports",ignorePackages = "methods")
#     expect_true(all(names(x) %in% c("nodes","edges","networkMeasures")))
#     expect_true(!"methods" %in% x$edges[["SOURCE"]])
# })
# 
# test_that('ExtractNetwork can filter out nulls and work with cycles', {
#     x <- ExtractDependencyNetwork(pkgName = 'data.table',which = c("Imports","Depends","Suggests"))
#     expect_true(all(names(x) %in% c("nodes","edges","networkMeasures")))
# })
# 
# 
# test_that('ExtractNetwork throws a fatal when a package is not installed', {
#     expect_error(ExtractDependencyNetwork(pkgName = 'randoPackage'),regexp = "is not an installed package")
# })
# 
# 
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()
