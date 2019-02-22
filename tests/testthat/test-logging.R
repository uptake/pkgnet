context("Test logger functions.")
rm(list = ls())

##### TESTS #####

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

rm(list = ls())
closeAllConnections()
