context("Abstract Graph Reporter Tests")

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

##### TESTS #####

## Structure Available ##

test_that('AbstractGraphReporter structure is as expected', {
    
    expect_named(
        object = AbstractGraphReporter$public_methods
        , expected = c("clone")
        , info = "Available public methods for AbstractGraphReporter not as expected."
        , ignore.order = TRUE
        , ignore.case = FALSE
    )
    
    expect_named(
        object = AbstractGraphReporter$public_fields
        , expected = NULL
        , info = "Available public fields for AbstractGraphReporter not as expected."
        , ignore.order = TRUE
        , ignore.case = FALSE
    )
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS TO BE TESTED BY CHILD OBJECTS

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()