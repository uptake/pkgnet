context("CreatePackageReport")

# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

# Set flag to suppress browser opening
Sys.setenv(PKGNET_SUPPRESS_BROWSER = TRUE)

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

test_that("CreatePackageReports generates the expected tables", {

    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )

    reporters <- CreatePackageReport(
        pkg_name = "baseballstats"
        , report_path = testReportPath
    )

    report_html <- readLines(testReportPath)

    num_tables <-  sum(grepl('datatables html-widget', report_html))

    # One table per reporter
    expect_true(num_tables == length(DefaultReporters()))

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

test_that("CreatePackageReport rejects bad packages with an informative error", {
    expect_error({
        CreatePackageReport(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find a package called 'w0uldNEverB33aPackageName'")
})

test_that("CreatePackageReport rejects bad pkg_path arguments", {
    expect_error({
        CreatePackageReport(
            pkg_name = "baseballstats"
            , pkg_path = "over_there"
        )
    })
})


test_that("CreatePackageReport rejects bad report_path arguments", {

    expect_error({
        CreatePackageReport(
            pkg_name = "base"
            , report_path = "~"
        )
    }, regexp = "report_path must be a \\.html file")

    expect_error({
        CreatePackageReport(
            pkg_name = "base"
            , report_path = "blegh.pdf"
        )
    }, regexp = "report_path must be a \\.html file")

    expect_error({
        CreatePackageReport(
            pkg_name = "base"
            , report_path = list("blegh.html")
        )
    }, regexp = "report_path is not a string")
})


test_that("CreatePackageReport respects report_path when explicitly given", {

    testing_file <- tempfile(pattern = "output", fileext = ".html")

    CreatePackageReport(
        pkg_name = "baseballstats"
        , report_path = testing_file
    )

    # file should exist (would catch bug that prevents writing or writes to wrong loc)
    expect_true(file.exists(testing_file))

    # file should have pkgnet stuff in it (would catch bug where file is created but never written to)
    raw_html <- readLines(testing_file)
    expect_true(sum(nchar(raw_html)) > 0)
    expect_true(any(grepl("Dependency Network", readLines(testing_file))))
})

##### TEST TEAR DOWN #####

Sys.unsetenv("PKGNET_SUPPRESS_BROWSER")

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
