context("Plotting")


test_that('node coloring by discrete and continuous', {
  b <- PackageFunctionReporter$new()
  b$set_package('baseballstats', packagePath = system.file('baseballstats',package="pkgnet"))
  b$calculate_metrics()
  b$get_raw_data()
  b$set_plot_node_color_scheme(field = "coverageRatio"
                               , pallete = c("red", "green")
  )
  
  expect_silent(object = b$plot_network())
                #, regexp = "Done creating plot"
               #, info = "Plot with continuous coloring has issues")
  
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
                # , regexp = "Done creating plot"
                # , info = "Plot with continuous coloring has issues")
  
})
