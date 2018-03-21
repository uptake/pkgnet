#' @title Surface the internal and external dependencies of an R package.
#' @name CreatePackageReport
#' @description Surface the internal and external dependencies of an R package. 
#' @author B. Burns
#' @seealso GetPackageGraphs
#' @param package_name (string) name of a package
#' @param package_reporters (list) a list of package reporters
#' @param package_path (string) The path to the package repository.  
#'                     If given, coverage will be calculated for each function.
#' @param report_path (string) The path and filename of the output report.  Default
#'                   report will be produced in working directory.
#' @importFrom assertthat assert_that is.string
#' @importFrom methods is
#' @return A list of instantiated package_reporters fitted to \code{package_name}
#' @export
CreatePackageReport <- function(package_name
                                , package_reporters = DefaultReporters()
                                , package_path = NULL
                                , report_path = file.path(getwd(), paste0(package_name, "_report.html"))
                                ) {
    # Input checks
    assertthat::assert_that(
        assertthat::is.string(package_name)
        , is.list(package_reporters)
    )
    
    # Confirm that all reporters are actually reporters
    checks <- sapply(package_reporters, function(x){methods::is(x, "AbstractPackageReporter")})
    if (!all(checks)){
        msg <- paste0("At least one of the reporters in the package_reporters parameter ",
                      "is not a PackageReporter. See ?AbstractPackageReporter for details.")
        log_fatal(msg)
    }
    
    log_info(paste0("Creating package report for package "
                    , package_name
                    , " with reporters:\n\n"
                    , paste(unlist(lapply(package_reporters, function(x) class(x)[1]))
                            , collapse = "\n")))
    
    builtReporters <- .BuildPackageReporters(
      package_name
      , package_reporters
      , package_path
    )
    
    .RenderPackageReport(
      report_path = report_path
      , package_reporters = builtReporters
      , package_name = package_name
    )
    
    return(invisible(builtReporters))
}


# [title] Package Report Renderer
# [name] RenderPackageReport
# [description] Renders an html report based on the initialized reporters provided
# [author] P. Boueri
# [param] report_path a file.path to where the report should be rendered
# [param] package_reporters a list of package reporters that have already been initialized and have calculated 
# [param] package_name (string) The name of the package.
# [return] Nothing
#' @importFrom rmarkdown render
.RenderPackageReport <- function(report_path 
                                , package_reporters
                                , package_name) {
    
    log_info("Rendering package report...")
    
    silence_logger
    rmarkdown::render(
        system.file(file.path("package_report", "package_report.Rmd"), package = "pkgnet")
        , output_file = report_path
        , quiet = TRUE
        , params = list(
            reporters = package_reporters
            , package_name = package_name
        )
    )
    unsilence_logger()

    log_info(sprintf("Done creating package report! It is available at %s", report_path))
    return(invisible(NULL))
}


# [Title] Build The Package Reporters
# [Author] B. Burns
# [Desc] This function creates an instance of each package reporter
#        and enriches its content.   
#
# [seealso] For param descriptions, see CreatePackageReport
.Buildpackage_reporters <- function(package_name
                                   , package_reporters
                                   , package_path){
      
      package_reporters <- sapply(
          X = package_reporters
          , FUN = function(reporter){
              reporter$set_package(package_name, package_path)
              return(reporter)
          }
      )
      names(package_reporters) <- sapply(package_reporters, function(x) class(x)[1])
      
      return(package_reporters)
}
