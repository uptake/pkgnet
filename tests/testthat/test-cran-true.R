context("always true for cran")
# Due to complications on CRAN with handling of temporary packages during testing, CI
# and local testing will remain the main test processes for pkgnet.
# See https://github.com/uptake/pkgnet/issues/160 for details on this decision.

##### THE TEST #####

test_that("always true", {
    expect_true(TRUE, info = "always true")
})
