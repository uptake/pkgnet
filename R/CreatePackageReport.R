#' @title Surface the internal and external dependencies of an R package.
#' @name CreatePackageReport
#' @description Surface the internal and external dependencies of an R package. 
#' @author B. Burns
#' @param packageName (string) name of a package
#' @param packageReporters (list) a list of package reporters
#' @param packagePath (string) The path to the package repository.  
#' If given, coverage will be calculated for each function.
#' @param reportPath (string) The path and filename of the output report.  Default
#' report will be produced in working directory.
#' @param orphanNodeClusteringThreshold (integer) The maximum number of ophan nodes (a.k.a.  unconnected nodes) 
#' allowed in the network graphs.  If the number of orphan nodes exceed this value, they are clustered together into 
#' one "cluster node" in the display. 
#' @importFrom assertthat assert_that is.string
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
#' @importFrom methods is
#' @return A list of instantiated packageReporters the user can then interact with
#' @export
CreatePackageReport <- function(packageName
                                , packageReporters = DefaultReporters()
                                , packagePath = NULL
                                , reportPath = file.path(getwd(),paste0(packageName,"_report.html"))
                                , orphanNodeClusteringThreshold = Inf) {
    
    # Input checks
    assertthat::assert_that(
        assertthat::is.string(packageName)
        , is.list(packageReporters)
    )
    
    # Confirm that all reporters are actually reporters
    checks <- sapply(packageReporters, function(x){methods::is(x, "AbstractPackageReporter")})
    if (!all(checks)){
        msg <- paste0("At least one of the reporters passed to CreatePackageReport ",
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
        
        
        # For AbstractGraphReporter Types Only
        if ("AbstractGraphReporter" %in% class(reporter)) {
          reporter$orphanNodeClusteringThreshold <- orphanNodeClusteringThreshold
          reporter$plot_network()
        }

        log_info(paste("Done Package Reporter",class(reporter)[1]))
    }
    
    RenderPackageReport(reportPath = reportPath,
                        packageReporters = packageReporters,
                        packageName = packageName)
    
    return(invisible(packageReporters))
}



#' @title Package Report Renderer
#' @name RenderPackageReport
#' @description Renders an html report based on the initialized reporters provided
#' @author P. Boueri
#' @param reportPath a file.path to where the report should be rendered
#' @param packageReporters a list of package reporters that have already been initialized and have calculated 
#' @param packageName (string) The name of the package.
#' @return Nothing
RenderPackageReport <- function(reportPath 
                                , packageReporters
                                , packageName) {
    log_info(paste("Outputting Package Report to ",reportPath))
    loggerOptions <- futile.logger::logger.options()
    if (!identical(loggerOptions, list())){
        origLogThreshold <- loggerOptions[[1]][['threshold']]
    }
    futile.logger::flog.threshold(0)
    rmarkdown::render(system.file(file.path("package_report","package_report.Rmd"), package = "pkgnet")
                      , output_format = "html_document"
                      , output_file = reportPath
                      , quiet = TRUE
                      , envir = new.env()
                      , params = list(reporters = packageReporters
                                      , packageName = packageName)
                      )
    futile.logger::flog.threshold(origLogThreshold)
    return(invisible(NULL))                   
}