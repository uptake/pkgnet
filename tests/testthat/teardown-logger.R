## Reset logger threshold ##
origLogThreshold <- as.numeric(Sys.getenv("PKGNET_TEST_ORIG_LOG_THRESHOLD"))
futile.logger::flog.threshold(
    threshold = origLogThreshold
    , name = futile.logger::flog.namespace()
)
Sys.unsetenv("PKGNET_TEST_ORIG_LOG_THRESHOLD")
