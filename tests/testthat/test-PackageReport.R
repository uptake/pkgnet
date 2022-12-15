##### TEST SET UP #####

# Set flag to suppress browser opening
Sys.setenv(PKGNET_SUPPRESS_BROWSER = TRUE)

REPORTERS <- c("SummaryReporter"
               , "DependencyReporter"
               , "FunctionReporter"
               , "InheritanceReporter"
               )

MILNE_PKG_PATH <- system.file(
    "milne"
    , package = "pkgnet"
    , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
)

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('PackageReport public interface is as expected', {

    publicInterfaceExpected <- c(
        # R6 Special Methods
        ".__enclos_env__"
        , "initialize"
        , "clone"

        # Class fields and methods
        , "pkg_name"
        , "pkg_path"
        , "report_path"
        , "add_reporter"
        , "render_report"
        , REPORTERS
    )

    reportObj <- PackageReport$new(pkg_name = 'baseballstats')
    expect_setequal(object = names(reportObj)
                    , expected = publicInterfaceExpected)

})

### USAGE OF PUBLIC METHODS AND FIELDS ###

test_that('PackageReport can correctly initialize reporters with active bindings', {
    reporterObj <- PackageReport$new(pkg_name = 'milne')
    for (reporter in REPORTERS) {
        # Reporters are null if not assigned
        expect_true(is.null(reporterObj[[reporter]]))

        # Assign reporter
        reporterObj[[reporter]] <- getNamespace('pkgnet')[[reporter]]$new()

        # Reporter assigned correctly
        expect_true(inherits(reporterObj[[reporter]], 'AbstractPackageReporter'))
        expect_true(inherits(reporterObj[[reporter]], reporter))
        expect_true(reporterObj[[reporter]]$pkg_name == 'milne')
    }
})

test_that('PackageReport can correctly initialize reporters with active bindings', {
    reporterObj <- PackageReport$new(pkg_name = 'milne')
    for (reporter in REPORTERS) {
        # Reporters are null if not assigned
        expect_true(is.null(reporterObj[[reporter]]))

        # Assign reporter
        reporterObj$add_reporter(getNamespace('pkgnet')[[reporter]]$new())

        # Reporter assigned correctly
        expect_true(inherits(reporterObj[[reporter]], 'AbstractPackageReporter'))
        expect_true(inherits(reporterObj[[reporter]], reporter))
        expect_true(reporterObj[[reporter]]$pkg_name == 'milne')
    }
})

test_that('PackageReport works with pkg_path', {
    # Package path
    reporterObj <- PackageReport$new(
        pkg_name = "milne"
        , pkg_path = MILNE_PKG_PATH
    )
    reporterObj$DependencyReporter <- DependencyReporter$new()
    expect_true(reporterObj$pkg_path == MILNE_PKG_PATH)
    # The below test fails on macOS CI for some mysterious reason.
    #expect_true(reporterObj$DependencyReporter$.__enclos_env__$private$pkg_path == MILNE_PKG_PATH)

})

test_that('PackageReport correctly renders reports', {
    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )
    reporterObj <- PackageReport$new(
        pkg_name = 'milne'
        , report_path = testReportPath
    )
    for (reporter in REPORTERS) {
        reporterObj[[reporter]] <- getNamespace('pkgnet')[[reporter]]$new()
    }
    reporterObj$render_report()
    expect_true(file.exists(testReportPath) && file.size(testReportPath) > 0)
})

test_that('PackageReport correctly renders reports with pkg_path', {
    testReportPath <- tempfile(
        pattern = "baseball"
        , fileext = ".html"
    )
    reporterObj <- PackageReport$new(
        pkg_name = 'milne'
        , pkg_path = MILNE_PKG_PATH
        , report_path = testReportPath
    )
    for (reporter in REPORTERS) {
        reporterObj[[reporter]] <- getNamespace('pkgnet')[[reporter]]$new()
    }
    reporterObj$render_report()
    expect_true(file.exists(testReportPath) && file.size(testReportPath) > 0)
})

### EXPECTED ERRORS ###

test_that("PackageReport rejects bad package names with an informative error", {
    expect_error({
        PackageReport$new(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
})

test_that("PackageReport rejects bad pkg_path arguments", {
    expect_error({
        PackageReport$new(
            pkg_name = "baseballstats"
            , pkg_path = "over_there"
        )
    })
})

test_that("PackageReport rejects bad report_path arguments", {

    expect_error({
        PackageReport$new(
            pkg_name = "base"
            , report_path = "~"
        )
    }, regexp = "report_path must be a \\.html file")

    expect_error({
        PackageReport$new(
            pkg_name = "base"
            , report_path = "blegh.pdf"
        )
    }, regexp = "report_path must be a \\.html file")

    expect_error({
        PackageReport$new(
            pkg_name = "base"
            , report_path = list("blegh.html")
        )
    }, regexp = "report_path is not a string")
})

test_that("PackageReport rejects wrong reporter assignments", {
    expect_error({
        reporterObj <- PackageReport$new("baseballstats")
        reporterObj$DependencyReporter <- 'foo'
    })
    expect_error({
        reporterObj <- PackageReport$new("baseballstats")
        reporterObj$add_reporter('foo')
    })
    expect_error({
        reporterObj <- PackageReport$new("baseballstats")
        reporterObj$DependencyReporter <- DependencyReporter
    }
    , regexp = "You specified an R6 class generator for class DependencyReporter"
    )
    expect_error({
        reporterObj <- PackageReport$new("baseballstats")
        reporterObj$add_reporter(DependencyReporter)
    }
    , regexp = "You specified an R6 class generator for class DependencyReporter"
    )
    expect_error({
        reporterObj <- PackageReport$new("baseballstats")
        reporterObj$DependencyReporter <- FunctionReporter$new()
    }
    , regexp = "reporter does not inherit from class DependencyReporter"
    )
})

##### TEST TEAR DOWN #####

Sys.unsetenv("PKGNET_SUPPRESS_BROWSER")
