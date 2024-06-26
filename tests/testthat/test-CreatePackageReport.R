##### TEST SET UP #####

# Set flag to suppress browser opening
Sys.setenv(PKGNET_SUPPRESS_BROWSER = TRUE)

##### TESTS #####

test_that("Test that CreatePackageReport runs", {

    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )

    createdReport <- CreatePackageReport(
        pkg_name = "baseballstats"
        , report_path = testReportPath
    )

    testthat::expect_true({
        reporters <- grep("Reporter$", names(createdReport), value = TRUE)
        all(vapply(
            X = reporters
            , FUN = function(x) {
                is.null(createdReport[[x]]) | inherits(createdReport[[x]], "AbstractPackageReporter")
            }
            , FUN.VALUE = logical(1)
        ))
    })
    testthat::expect_true(file.exists(testReportPath) && file.size(testReportPath) > 0)
    testthat::expect_true(inherits(createdReport, "PackageReport"))
    testthat::expect_true(
        all(
            vapply(DefaultReporters(), function(x){class(x)[1]}, FUN.VALUE = character(1))
                %in% names(createdReport)
        )
        , info = "Returned report object doesn't have reporters accessible")
    file.remove(testReportPath)
})

test_that("CreatePackageReports generates the expected tables", {

    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )

    createdReport <- CreatePackageReport(
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
    }, regexp = "All members of pkg_reporters must be initialized package reporters")

})

test_that("CreatePackageReport rejects bad packages with an informative error", {
    expect_error({
        CreatePackageReport(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
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

test_that("Test that CreatePackageReport runs with control statements", {

    testReportPath <- tempfile(
        pattern = "control"
        , fileext = ".html"
    )

    createdReport <- CreatePackageReport(
        pkg_name = "control"
        , report_path = testReportPath
    )

    testthat::expect_true({
        reporters <- grep("Reporter$", names(createdReport), value = TRUE)
        all(vapply(
            X = reporters
            , FUN = function(x) {
                is.null(createdReport[[x]]) | inherits(createdReport[[x]], "AbstractPackageReporter")
            }
            , FUN.VALUE = logical(1)
        ))
    })
    testthat::expect_true(file.exists(testReportPath) && file.size(testReportPath) > 0)
    testthat::expect_true(inherits(createdReport, "PackageReport"))
    testthat::expect_true(
        all(
            vapply(DefaultReporters(), function(x){class(x)[1]}, FUN.VALUE = character(1))
                %in% names(createdReport)
        )
        , info = "Returned report object doesn't have reporters accessible")
    file.remove(testReportPath)
})


##### TEST TEAR DOWN #####

Sys.unsetenv("PKGNET_SUPPRESS_BROWSER")
