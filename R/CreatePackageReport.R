#' @title Surface the internal and external dependecies of an R package.
#' @name CreatePackageReport
#' @description Surface the internal and external dependecies of an R package. 
#' @author B. Burns
#' @param packageName name of a package
#' @param packageReporters a list of package reporters
#' @param packagePath (optional) the path to the package repository.  
#' If given, coverage will be calculated for each function.
#' @importFrom assertthat assert_that is.string
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
#' @importFrom methods is
#' @return A list of instantiated packageReporters the user can then interact with
#' @export
CreatePackageReport <- function(packageName
                                , packageReporters = DefaultReporters()
                                , packagePath = NULL) {
    
    # Input checks
    assertthat::assert_that(assertthat::is.string(packageName)
                            , is.list(packageReporters))
    
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
        log_info("Running Package Reporter",class(reporter)[1])
        reporter$set_package(packageName, packagePath)
        
        reporter$calculate_metrics()
        # TODO: replace plot_network() with render_report() which is then rendered into a parent report.
        reporter$plot_network()
        log_info("Done Package Reporter",class(reporter)[1])
    }
    
    
    return(packageReporters)
}
