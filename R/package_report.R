#' @title Creates a 
#' @name CreatePackageReport
#' @description Obtain Ratio of Coverage For Each Function Within A Package
#' @author B. Burns
#' @param pkgPath path to the package you want to examine
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
#' @export
CreatePackageReport <- function(packageName,packageReporters = DefaultReporters()) {
    futile.logger::flog.info(paste("Creating package report for package",packageName
                                   ,"with reporters"
                                   ,paste(unlist(lapply(packageReporters,function(x) class(x)[1])),collapse = ",")))
    # TODO [patrick.bouer@uptake.com]: Type checks
    plots <- list()
    for(reporter in packageReporters){
        reporter$setPackage(packageName)
        plots <- c(plots,reporter$plotNetwork()) # TODO [patrick.bouer@uptake.com]: Figure out how to pass configuration params by class. Probably gonna be constructor fields
    }
    
    return(plots)
        
}
