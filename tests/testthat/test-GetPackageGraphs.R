context("GetPackageGraphs")

# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

test_that("Test that GetPackageGraphs Runs", {
    
    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )
    
    graphList <- GetPackageGraphs(
        packageName = "baseballstats"
    )
    
    testthat::expect_true(all(unlist(lapply(graphList, igraph::is.igraph))))
})

test_that("GetPackageGraphs rejects bad inputs to reporters", {
    
    expect_error({
       GetPackageGraphs(
            packageName = "baseballstats"
            , packageReporters = list(a = rnorm(100))
        )
    }, regexp = "At least one of the reporters in the packageReporters parameter is not a PackageReporter")
    
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()