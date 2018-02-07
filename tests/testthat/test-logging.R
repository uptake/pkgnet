context("logging")

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

test_that("logging works", {
    
    expect_true({
        log_info("the stuff")
        TRUE
    })
    
    expect_warning({
        log_warn("some stuff")
    }, regexp = "some stuff")
    
    expect_error({
        log_fatal("other stuff")
    }, regexp = "other stuff")
    
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
