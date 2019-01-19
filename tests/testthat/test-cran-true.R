context("always true for cran")
# Due to complications on CRAN with handling of temporary packages during testing, TRAVIS 
# and local testing will remain the main test processes for pkgnet. 
# See https://github.com/UptakeOpenSource/pkgnet/issues/160 for details on this decision.

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
    origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
    origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### THE TEST #####

test_that("always true", {
    expect_true(TRUE, info = "always true")
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
