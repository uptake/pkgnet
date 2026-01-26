## Reset logger threshold ##
origLogThreshold <- as.numeric(Sys.getenv("PKGNET_TEST_ORIG_LOG_THRESHOLD"))
pkgnet:::.get_logger()$set_threshold(origLogThreshold)
Sys.unsetenv("PKGNET_TEST_ORIG_LOG_THRESHOLD")
