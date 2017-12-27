context("Plotting")


test_that('node coloring by discrete and continuous', {
  b <- PackageFunctionReporter$new()
  b$set_package('baseballstats', packagePath = system.file('baseballstats',package="pkgnet"))
  b$calculate_metrics()
  b$get_raw_data()
  b$set_plot_node_color_scheme(field = "coverageRatio"
                               , pallete = c("red", "green")
  )
  
  expect_output(object = plotObj <- b$plot_network()
                , regexp = "Done creating plot"
                , info = "Plot with continuous coloring has issues")
  
  b$set_plot_node_color_scheme(field = "filename"
                               , pallete = RColorBrewer::brewer.pal(9,"Set1")
  )
  
  expect_output(object = plotObj <- b$plot_network()
                , regexp = "Done creating plot"
                , info = "Plot with continuous coloring has issues")
  
})
