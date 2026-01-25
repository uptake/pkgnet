## Configure logger (suppress all logs in testing) ##

# Save original threshold to reset later
origLogThreshold <- pkgnet:::.get_logger()$get_threshold()
Sys.setenv(PKGNET_TEST_ORIG_LOG_THRESHOLD = origLogThreshold)

# Silence logger
pkgnet:::silence_logger()
