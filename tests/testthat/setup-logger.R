## Configure logger (suppress all logs in testing) ##

# Save original threshold to reset later
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
    origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
    origLogThreshold <- futile.logger::INFO
}
Sys.setenv(PKGNET_TEST_ORIG_LOG_THRESHOLD = origLogThreshold)

# Silence logger
futile.logger::flog.threshold(
    threshold = 0
    , name = futile.logger::flog.namespace()
)
