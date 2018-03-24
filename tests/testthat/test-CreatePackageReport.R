context("CreatePackageReport")

# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

test_that("Test that CreatePackageReport Runs", {
    
    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )
    
    reporters <- CreatePackageReport(
        pkg_name = "baseballstats"
        , report_path = testReportPath
    )
    
    testthat::expect_true(all(unlist(lapply(reporters, function(x) "AbstractPackageReporter" %in% class(x)))))
    testthat::expect_true(file.exists(testReportPath) && file.size(testReportPath) > 0)
    testthat::expect_named(object = reporters
                           , expected = sapply(DefaultReporters(), function(x){class(x)[1]})
                           , info = "Ensure Named List")
    file.remove(testReportPath)
})

test_that("CreatePackageReport rejects bad inputs to reporters", {
    
    expect_error({
        CreatePackageReport(
            pkg_name = "baseballstats"
            , pkg_reporters = list(a = rnorm(100))
        )
    }, regexp = "At least one of the reporters in the pkg_reporters parameter is not a PackageReporter")
    
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()