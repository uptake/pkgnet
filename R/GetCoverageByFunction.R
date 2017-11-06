# [title] Obtain Ratio of Coverage For Each Function Within A Package
# [name] GetCoverageByFunction
# [description] Obtain Ratio of Coverage For Each Function Within A Package
# [param] pkgPath path to the package you want to examine
#' @importFrom covr package_coverage tally_coverage
#' @importFrom data.table as.data.table setnames
GetCoverageByFunction <- function(pkgPath) {
    
    # Grab Test Coverage
    coverage <- covr::package_coverage(pkgPath)
    
    # Aggregation on coverage by function
    res <- data.table::as.data.table(covr::tally_coverage(coverage))
    outDT <- res[, list(test_coverage = 100*sum(value > 0) / length(value))
                 , by = list(filename, functions)]
    
    # Rename for compatibility
    data.table::setnames(outDT, old = 'functions', new = 'node')
  
    return(outDT)
}
