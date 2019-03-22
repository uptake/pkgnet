#' @title pkgnet Analysis Report for an R package
#' @name CreatePackageReport
#' @description Create a standalone HTML report about a package and its networks.
#' @param pkg_name (string) name of a package
#' @param pkg_path (string) The path to the package repository. If given, coverage
#'                 will be calculated for each function. \code{pkg_path} can be an
#'                 absolute or relative path.
#' @param pkg_reporters (list) a list of package reporters
#' @param report_path (string) The path and filename of the output report.  Default
#'                   report will be produced in the temporary directory.
#' @importFrom assertthat assert_that is.readable is.string is.writeable
#' @importFrom methods is
#' @importFrom tools file_ext
#' @importFrom utils browseURL
#' @importFrom rmarkdown render
#' @return A list of instantiated pkg_reporters fitted to \code{pkg_name}
#' @export
CreatePackageReport <- function(pkg_name
                                , pkg_reporters = DefaultReporters()
                                , pkg_path = NULL
                                , report_path = tempfile(pattern = pkg_name, fileext = ".html")
                                ) {
    # Input checks
    assertthat::assert_that(
        assertthat::is.string(pkg_name)
        , pkg_name != ""
        , is.list(pkg_reporters)
        , is.null(pkg_path) || assertthat::is.readable(pkg_path)
        , assertthat::is.string(report_path)
        , report_path != ""
    )

    # Confirm that the report_path looks correct
    if (! identical(tolower(tools::file_ext(report_path)), "html")){
        log_fatal(sprintf("report_path must be a .html file path. You gave '%s'.", report_path))
    }

    # Confirm that all reporters are actually reporters
    checks <- sapply(pkg_reporters, function(x){methods::is(x, "AbstractPackageReporter")})
    if (!all(checks)){
        msg <- paste0("At least one of the reporters in the pkg_reporters parameter ",
                      "is not a PackageReporter. See ?AbstractPackageReporter for details.")
        log_fatal(msg)
    }

    log_info(paste0("Creating package report for package "
                    , pkg_name
                    , " with reporters:\n\n"
                    , paste(unlist(lapply(pkg_reporters, function(x) class(x)[1]))
                            , collapse = "\n")))

    builtReporters <- .BuildPackageReporters(
      pkg_name
      , pkg_reporters
      , pkg_path
    )

    .RenderPackageReport(
      report_path = report_path
      , pkg_reporters = builtReporters
      , pkg_name = pkg_name
    )

    # If suppress flag is unset, then env variable will be emptry string ""
    if (identical(Sys.getenv("PKGNET_SUPPRESS_BROWSER"), "")) {
        utils::browseURL(report_path)
    }

    return(invisible(builtReporters))
}

### Imports from package_report.Rmd
#' @importFrom knitr opts_chunk knit_child
NULL

# [title] Package Report Renderer
# [name] RenderPackageReport
# [description] Renders an html report based on the initialized reporters provided
# [author] P. Boueri
# [param] report_path a file.path to where the report should be rendered
# [param] pkg_reporters a list of package reporters that have already been initialized and have calculated
# [param] pkg_name (string) The name of the package.
# [return] Nothing
#' @importFrom rmarkdown render
.RenderPackageReport <- function(report_path
                                , pkg_reporters
                                , pkg_name) {

    log_info("Rendering package report...")

    silence_logger()
    rmarkdown::render(
        system.file(file.path("package_report", "package_report.Rmd"), package = "pkgnet")
        , output_dir = dirname(report_path)
        , output_file = basename(report_path)
        , quiet = TRUE
        , params = list(
            reporters = pkg_reporters
            , pkg_name = pkg_name
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
.BuildPackageReporters <- function(pkg_name
                                   , pkg_reporters
                                   , pkg_path){

      pkg_reporters <- sapply(
          X = pkg_reporters
          , FUN = function(reporter){
              reporter$set_package(pkg_name, pkg_path)
              return(reporter)
          }
      )
      names(pkg_reporters) <- sapply(pkg_reporters, function(x) class(x)[1])

      return(pkg_reporters)
}
