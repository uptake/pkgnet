##### TESTS #####

test_that("SimpleLogger class works", {

    # Create a new logger instance
    logger <- SimpleLogger$new()

    # Test default threshold is INFO (4)
    expect_equal(logger$get_threshold(), 4)

    # Test setting threshold
    logger$set_threshold(6)
    expect_equal(logger$get_threshold(), 6)

    # Test info logging (should be silent when threshold = 6)
    expect_message(
        logger$info("info message"),
        regexp = NA
    )

    # Test warn logging (should be silent when threshold = 6)
    expect_message(
        logger$warn("warn message"),
        regexp = NA
    )

    # Test fatal logging (should work when threshold = 6)
    expect_message(
        logger$fatal("fatal message"),
        regexp = "FATAL.*fatal message"
    )

    # Set threshold to INFO (4)
    logger$set_threshold(4)

    # Test info logging (should work when threshold = 4)
    expect_message(
        logger$info("info message"),
        regexp = "INFO.*info message"
    )

    # Test silencing (threshold = 0)
    logger$set_threshold(0)
    expect_message(
        logger$info("should not appear"),
        regexp = NA
    )
    expect_message(
        logger$warn("should not appear"),
        regexp = NA
    )
    expect_message(
        logger$fatal("should not appear"),
        regexp = NA
    )
})

test_that("logging wrapper functions work", {

    # Save original threshold
    orig_thresh <- .get_logger()$get_threshold()

    # Reset threshold to INFO
    unsilence_logger()

    expect_message({
        log_info("the stuff")
    }, regexp = "INFO.*the stuff")

    expect_warning({
        expect_message(
            log_warn("some stuff"),
            regexp = "WARN.*some stuff"
        )
    }, regexp = "some stuff")

    expect_error({
        expect_message(
            log_fatal("other stuff"),
            regexp = "FATAL.*other stuff"
        )
    }, regexp = "other stuff")

    # Restore original threshold
    .get_logger()$set_threshold(orig_thresh)
})

test_that("silence_logger and unsilence_logger work", {

    # Unsilence first to ensure consistent state
    unsilence_logger()

    # Should log when not silenced
    expect_message(
        log_info("visible message"),
        regexp = "INFO.*visible message"
    )

    # Silence the logger
    silence_logger()

    # Should not log when silenced
    expect_message(
        log_info("invisible message"),
        regexp = NA
    )

    # Unsilence the logger
    unsilence_logger()

    # Should log again
    expect_message(
        log_info("visible again"),
        regexp = "INFO.*visible again"
    )
})
