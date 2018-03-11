#' @title Surface the internal and external dependencies of an R package.
#' @name CreatePackageReport
#' @description Surface the internal and external dependencies of an R package. 
#' @author B. Burns
#' @seealso GetPackageGraphs
#' @param packageName (string) name of a package
#' @param packageReporters (list) a list of package reporters
#' @param packagePath (string) The path to the package repository.  
#' If given, coverage will be calculated for each function.
#' @param reportPath (string) The path and filename of the output report.  Default
#' report will be produced in working directory.
#' @importFrom assertthat assert_that is.string
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
#' @importFrom methods is
#' @return A list of instantiated packageReporters fitted to \code{packageName}
#' @export
CreatePackageReport <- function(packageName
                                , packageReporters = DefaultReporters()
                                , packagePath = NULL
                                , reportPath = file.path(getwd(),paste0(packageName,"_report.html"))
                                ) {
    
    # Build the package reporters
    packgeReporters <- .BuildPackageReporters(packageName
                                              , packageReporters
                                              , packagePath)
    
    # Create the Report
    .RenderPackageReport(
      reportPath = reportPath
      , packageReporters = reporters
      , packageName = packageName
    )
    
    return(invisible(packageReporters))
}


# [title] Package Report Renderer
# [name] RenderPackageReport
# [description] Renders an html report based on the initialized reporters provided
# [author] P. Boueri
# [param] reportPath a file.path to where the report should be rendered
# [param] packageReporters a list of package reporters that have already been initialized and have calculated 
# [param] packageName (string) The name of the package.
# [return] Nothing
.RenderPackageReport <- function(reportPath 
                                , packageReporters
                                , packageName) {
    
    log_info("Rendering package report...")
    
    silence_logger
    rmarkdown::render(
        system.file(file.path("package_report","package_report.Rmd"), package = "pkgnet")
        , output_file = reportPath
        , quiet = TRUE
        , params = list(
            reporters = packageReporters
            , packageName = packageName
        )
    )
    unsilence_logger()

    log_info(sprintf("Done creating package report! It is available at %s", reportPath))
    return(invisible(NULL))
}



# [Title] Build The Package Reporters
# [Author] B. Burns
# [Desc] This function creates an instance of each package reporter
#        and enriches its content.   
#
#  For param descriptions, see CreatePackageReport

.BuildPackageReporters <- function(packageName
                                   , packageReporters
                                   , packagePath){
      # Input checks
      assertthat::assert_that(
        assertthat::is.string(packageName)
        , is.list(packageReporters)
      )
      
      # Confirm that all reporters are actually reporters
      checks <- sapply(packageReporters, function(x){methods::is(x, "AbstractPackageReporter")})
      if (!all(checks)){
        msg <- paste0("At least one of the reporters in the packageReporters parameter ",
                      "is not a PackageReporter. See ?AbstractPackageReporter for details.")
        log_fatal(msg)
      }
      
      log_info(paste0("Creating package report for package "
                      , packageName
                      , " with reporters:\n\n"
                      , paste(unlist(lapply(packageReporters, function(x) class(x)[1]))
                              , collapse = "\n")))
      
      
      # Make them plots
      for (reporter in packageReporters){
        log_info(paste("Running Package Reporter", class(reporter)[1]))
        reporter$set_package(packageName, packagePath)
        
        reporter$calculate_all_metrics()
        
        reporter$plot_network()
        
        log_info(paste("Done Package Reporter",class(reporter)[1]))
      }
      
      return(packageReporters)
  
}
