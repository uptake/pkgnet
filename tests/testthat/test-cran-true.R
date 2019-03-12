context("always true for cran")
# Due to complications on CRAN with handling of temporary packages during testing, TRAVIS
# and local testing will remain the main test processes for pkgnet.
# See https://github.com/UptakeOpenSource/pkgnet/issues/160 for details on this decision.

##### THE TEST #####

test_that("always true", {
    expect_true(TRUE, info = "always true")
})

##### TEST TEAR DOWN #####
rm(list = ls())
closeAllConnections()
