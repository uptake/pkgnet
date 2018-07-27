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
  b <- FunctionReporter$new()
  b$set_package('baseballstats'
                , pkg_path = system.file('baseballstats'
                                         , package = "pkgnet"
                                         , lib.loc = .libPaths()
                                         )
                )
  b$.__enclos_env__$private$set_plot_node_color_scheme(
      field = "coverageRatio"
      , pallete = c("red", "green")
  )
  
  expect_silent({
      
    b$.__enclos_env__$private$set_plot_node_color_scheme(
      field = "filename"
      , pallete = c(
          "#E41A1C"
          , "#377EB8"
          , "#4DAF4A"
          , "#984EA3"
          , "#FF7F00"
          , "#FFFF33"
          , "#A65628"
          , "#F781BF"
          , "#999999"
        )
    )
  })
  
  viz <- b$graph_viz
  expect_is(viz, "visNetwork")
  expect_is(viz, "htmlwidget")
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
