context("Abstract Package Reporter Tests")

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

test_that('AbstractPackageReporter structure is as expected', {
  
  expect_named(object = AbstractPackageReporter$public_methods
               , expected = c(
                 "set_package",
                 "get_summary_view",
                 "clone"
               )
               , info = "Available public methods for AbstractPackageReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = AbstractPackageReporter$public_fields
               , expected = NULL
               , info = "Available public fields for AbstractPackageReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})


test_that("AbstractPackageReporter rejects bad packages with an informative error", {
    expect_error({
        x <- AbstractPackageReporter$new()
        x$set_package("w0uldNEverB33aPackageName")
    }, regexp = "pkgnet could not find a package called 'w0uldNEverB33aPackageName'")
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS TO BE TESTED BY CHILD OBJECTS

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()