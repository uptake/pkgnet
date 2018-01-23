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
                 "get_package",
                 "get_package_path",
                 "get_report",
                 "get_summary_view",
                 "get_raw_data",
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
  
  expect_named(object = AbstractPackageReporter$private_methods
               , expected = c("reset_cache")
               , info = "Available private methods for AbstractPackageReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
  expect_named(object = AbstractPackageReporter$private_fields
               , expected = c(
                 "packageName", 
                 "packagePath"
                 )
               , info = "Available private fields for AbstractPackageReporter not as expected."
               , ignore.order = TRUE
               , ignore.case = FALSE
  )
  
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS TO BE TESTED BY CHILD OBJECTS

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()