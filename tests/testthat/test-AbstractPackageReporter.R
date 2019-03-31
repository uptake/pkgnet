context("AbstractPackageReporter Tests")
rm(list = ls())

##### TESTS #####

test_that('AbstractPackageReporter public interface is as expected', {

    publicInterfaceExpected <- c(
        # R6 Special Methods
        ".__enclos_env__"
        , "clone"

        # Package Reporter fields and active bindings
        , "pkg_name"

        # Package Reporter methods
        , "set_package"
        , "get_summary_view"
        , "report_markdown_path"
    )

    reporter <- pkgnet:::AbstractPackageReporter$new()
    expect_setequal(object = names(reporter)
                    , expected = publicInterfaceExpected)
})


test_that("AbstractPackageReporter does not let you set_package twice", {
    expect_error({
        x <- pkgnet:::AbstractPackageReporter$new()
        x$set_package("baseballstats")
        x$set_package("baseballstats")
    }, regexp = "A package has already been set for this reporter")
})

test_that("AbstractPackageReporter rejects bad packages with an informative error", {
    expect_error({
        x <- pkgnet:::AbstractPackageReporter$new()
        x$set_package("w0uldNEverB33aPackageName")
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
})

test_that("AbstractPackageReporter rejects bad pkg_path with an informative error", {
    expect_error({
        x <- pkgnet:::AbstractPackageReporter$new()
        x$set_package(pkg_name = "baseballstats", pkg_path = "hopefully/not/a/real/path")
    }, regexp = "Package directory does not exist: hopefully/not/a/real/path")
})

test_that("AbstractPackageReporter errors on unimplemented methods", {
    expect_error({
        x <- pkgnet:::AbstractPackageReporter$new()
        x$get_summary_view()
    }, regexp = "get_summary_view has not been implemented")

    expect_error({
        x <- pkgnet:::AbstractPackageReporter$new()
        x$report_markdown_path
    }, regexp = "this reporter does not have a report markdown path")
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS TO BE TESTED BY CHILD OBJECTS

### UTIL FUNCTIONS ###

test_that(".is.PackageReporter correctly identifies package reporters", {
    expect_true(pkgnet:::.is.PackageReporter(DependencyReporter$new()))
    expect_true(pkgnet:::.is.PackageReporter(FunctionReporter$new()))
    expect_true(pkgnet:::.is.PackageReporter(InheritanceReporter$new()))
    expect_true(pkgnet:::.is.PackageReporter(SummaryReporter$new()))

    DependencyTabloid <- R6::R6Class(
        classname = "DependencyTabloid"
    )
    expect_true(!pkgnet:::.is.PackageReporter(DependencyTabloid$new()))
})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
