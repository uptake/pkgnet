context("Installation of Test Packages")
rm(list = ls())

# Test packages are installed in a temporary directory before testing and
# uninstalled after. Many pkgnet tests depend on these packages installing
# correctly and being available.

test_that('Test packages installed correctly',{
    testPkgNames <- c("baseballstats", "sartre", "milne")
    for (thisTestPkg in testPkgNames) {
        expect_true(
            object = require(thisTestPkg
                             , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
                             , character.only = TRUE)
            , info = sprintf("Test package %s is not installed.", thisTestPkg)
        )
    }
})
