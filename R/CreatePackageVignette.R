#' @title pkgnet Report as Vignette
#' @name CreatePackageVignette
#' @description Create pkgnet package report as an R Markdown vignette. This
#'    vignette can be rendered into a standard HTML vignette with the
#'    \code{\link[knitr:vignette_engines]{knitr::rmarkdown}} vignette engine
#'    into HTML vignettes upon package building. It is also compatible with
#'    #'    \code{\link[pkgdown:build_articles]{pkgdown}} sites. See the vignette
#'    \href{https://uptakeopensource.github.io/pkgnet/articles/publishing-reports.html}{
#'    "Publishing Your pkgnet Package Report"} for details about how to use this
#'    function, as well as
#'    \href{https://uptakeopensource.github.io/pkgnet-gallery/exhibits/pkgnet-vignette/pkgnet-vignette.html}{
#'    our example for pkgnet}.
#' @param pkg (string) path to root directory of package of interest
#' @param pkg_reporters (list) a list of initialized package reporters
#' @param vignette_path (string) The location of a file to store the output
#'    vignette file at. Must be an .Rmd file. By default, this will be
#'    '<pkg>/vignettes/pkgnet-report.Rmd' relative to the input to pkg
#' @importFrom rlang enexpr
#' @importFrom assertthat assert_that is.string is.readable
#' @importFrom tools file_ext
#' @importFrom R6 is.R6Class
#' @importFrom glue glue
#' @export
CreatePackageVignette <- function(pkg = "."
                                  , pkg_reporters = list(
                                      DependencyReporter$new()
                                      , FunctionReporter$new()
                                  )
                                  , vignette_path = file.path(pkg
                                                              , "vignettes"
                                                              , "pkgnet-report.Rmd")
                                 ) {

    # Capture pkg_reporters expression for later injection into Rmd
    pkg_reporters_expr <- rlang::enexpr(pkg_reporters)

    ## pkg input checks ##
    assertthat::assert_that(
        assertthat::is.string(pkg)
        , pkg != ""
        , dir.exists(pkg)
    )
    if (!file.exists(file.path(pkg, "DESCRIPTION"))) {
        log_fatal(paste(
            "We can't find your DESCRIPTION file."
            , "pkg must point to a package root directory."
        ))
    }

    # Get pkg_name from DESCRIPTION file
    pkg_name <- read.dcf(file.path(pkg, "DESCRIPTION"))[1,][["Package"]]

    ## pkg_reporter input checks ##
    assertthat::assert_that(
        is.list(pkg_reporters)
    )
    # Check if generators were passed in by accident
    if (any(vapply(pkg_reporters, FUN = R6::is.R6Class, FUN.VALUE = logical(1)))) {
        log_fatal(paste(
            "At least one of pkg_reporters is an R6 class generator. This"
            , "function expects initialized reporter objects."
        ))
    }
    # Confirm that all reporters are actually valid initialized reporters
    assertthat::assert_that(
        all(vapply(pkg_reporters
                   , FUN = .is.PackageReporter
                   , FUN.VALUE = logical(1)
            ))
        , msg = "All members of pkg_reporters must be initialized package reporters."
    )

    ## vignette_path input checks ##
    assertthat::assert_that(
        assertthat::is.string(vignette_path)
        , vignette_path != ""
        , identical(tolower(tools::file_ext(vignette_path)), "rmd")
    )

    # Confirm directory exists
    if (!dir.exists(dirname(vignette_path))) {
        log_fatal(sprintf(paste("Directory %s does not exist, please create it",
                                "before running CreatePackageVignette")
                          , dirname(vignette_path)))
    }

    # Check if vignette_path matches the right package
    # if the path is to a file in a directory named vignettes
    vignetteDirAbsPath <- normalizePath(dirname(vignette_path))
    # If path is a vignettes directory
    if (grepl('/vignettes$', vignetteDirAbsPath)) {
        # Get path for expected DESCRIPTION file for package
        expectedDescriptionPath <- gsub(
            pattern = "vignettes$"
            , replacement = "DESCRIPTION"
            , x = vignetteDirAbsPath
            )

        # If DESCRIPTION file exists check the name
        if (file.exists(expectedDescriptionPath)) {
            foundPkgName <- read.dcf(expectedDescriptionPath)[1,][["Package"]]

            # If it doesn't match pkg_name, give warning
            if (!identical(foundPkgName, pkg_name)) {
                log_warn(glue::glue(
                    "You are writing a report for {pkg_name} to the vignettes "
                    , "directory for {foundPkgName}"
                    , pkg_name = pkg_name
                    , foundPkgName = foundPkgName))
            }

        # Otherwise, warn that we're writing to a vignettes folder inside
        # a directory that is not a package root
        } else {
            log_warn(paste(
                "You specified a path to a vignettes directory"
                , vignetteDirAbsPath
                , "that is not inside a package root directory."
            ))
        }
    }

    log_info(sprintf(
        "Creating pkgnet package report as vignette for %s..."
        , pkg_name
    ))

    # Read pkgnet vignette template
    templatePath <- system.file(file.path("package_report"
                                          , "package_vignette_template.Rmd")
                                , package = "pkgnet")

    # Inject code into the template
    vignette_rmd <- glue::glue(
        paste(readLines(templatePath), collapse = "\n")
        , pkg_name = pkg_name
        , pkg_reporters = deparse(pkg_reporters_expr)
        , .open = "{{"
        , .close = "}}"
    )

    # Write vignette Rmd to file
    rmd_conn <- file(description = vignette_path, open = 'w')
    on.exit(close(rmd_conn))
    writeLines(vignette_rmd, con = rmd_conn)

    log_info(sprintf(
        "...successfully wrote vignette R Markdown file to %s"
        , normalizePath(vignette_path)
    ))

    return(invisible(normalizePath(vignette_path)))
}
