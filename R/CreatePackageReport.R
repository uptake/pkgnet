#' @title Creates a 
#' @name CreatePackageReport
#' @description Obtain Ratio of Coverage For Each Function Within A Package
#' @author B. Burns
#' @param packageName name of a package
#' @param packageReporters a list of package reporters
#' @importFrom assertthat assert_that is.string
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
#' @importFrom methods is
#' @export
CreatePackageReport <- function(packageName, packageReporters = DefaultReporters()) {
    
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
    plots <- list()
    for (reporter in packageReporters){
        reporter$set_package(packageName)
        
        # TODO: make plotting act on active bindings so you can just call plot()
        # directly without other method calls
        reporter$calculate_metrics()
        plots <- c(plots, reporter$plot_network())
    }
    
    return(plots)
}
