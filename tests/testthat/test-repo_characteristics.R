# context("Checking repo characteristics")
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
# # R CMD Check stuff. Current upper lims: 0 errors, 0 warnings, 0 notes
# x <- devtools::check(pkg = '../../pkgnet'
#                      , document = TRUE
#                      , args = '--no-tests --ignore-vignettes'
#                      , quiet = FALSE)
# 
# test_that("R CMD check should not return any errors", {
#     expect_true(length(x[["errors"]]) == 0)
# })
# 
# test_that("R CMD check should not return any warnings", {
#     expect_true(length(x[["warnings"]]) == 0)
# })
# 
# test_that("R CMD check should return not return any warnings", {
#     expect_true(length(x[["notes"]]) == 0)
# })
# 
# ##### TEST TEAR DOWN #####
# futile.logger::flog.threshold(origLogThreshold)
# rm(list = ls())
# closeAllConnections()
