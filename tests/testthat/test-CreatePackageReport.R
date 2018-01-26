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
    #TODO: Change when generating reports
    pdf("test_plots.pdf") #PDF doesn't actually work
    reporters <- CreatePackageReport(packageName = "baseballstats")
    dev.off()
    testthat::expect_true(all(unlist(lapply(reporters,function(x) "AbstractPackageReporter" %in% class(x)))))
    testthat::expect_true(file.exists("test_plots.pdf") && file.size("test_plots.pdf") > 0)
    file.remove("test_plots.pdf")
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()