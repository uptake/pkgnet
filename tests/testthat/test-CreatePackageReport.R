context("CreatePackageReport")

# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

test_that("Test that CreatingPackageReport Runs", {
    reporters <- CreatePackageReport(packageName = "baseballstats",reportPath = 'baseballstats.html')
    testthat::expect_true(all(unlist(lapply(reporters,function(x) "AbstractPackageReporter" %in% class(x)))))
    testthat::expect_true(file.exists("baseballstats.html") && file.size("baseballstats.html") > 0)
    file.remove('baseballstats.html')
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()