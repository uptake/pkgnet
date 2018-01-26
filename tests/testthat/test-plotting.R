context("Plotting Tests")

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
# expect_silents only work with this logger turned off; only alerts with warnings
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
  origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
  origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

test_that('node coloring by discrete and continuous', {
  b <- PackageFunctionReporter$new()
  b$set_package('baseballstats', packagePath = system.file('baseballstats',package="pkgnet"))
  b$calculate_all_metrics()
  b$get_raw_data()
  b$set_plot_node_color_scheme(field = "coverageRatio"
                               , pallete = c("red", "green")
  )
  
  expect_silent(object = b$plot_network())
               #  , regexp = "Coloring plot nodes by coverageRatio"
               # , info = "Plot with continuous coloring has issues")
  
  b$set_plot_node_color_scheme(field = "filename"
                               , pallete = c("#E41A1C"
                                             , "#377EB8"
                                             , "#4DAF4A"
                                             , "#984EA3"
                                             , "#FF7F00"
                                             , "#FFFF33"
                                             , "#A65628"
                                             , "#F781BF"
                                             , "#999999")
  )
  
  expect_silent(object = b$plot_network())
                 # , regexp = "Coloring plot nodes by filename"
                 # , info = "Plot by character fields has issues")
  
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
