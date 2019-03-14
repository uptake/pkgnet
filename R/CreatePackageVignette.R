#' @title pkgnet Report as Vignette
#' @name CreatePackageVignette
#' @description Create pkgnet package report as an Rmarkdown vignette. This
#'    vignette is able to be rendered with the
#'    \code{\link[knitr:vignette_engines]{knitr::rmarkdown}} vignette engine
#'    into HTML vignettes upon package building. It is also compatible with
#'    \code{\link[pkgdown:build_articles]{pkgdown}} sites.
#' @param pkg_name (string) name of a package
#' @param pkg_path (string) The path to the package repository. If given, coverage
#'                 will be calculated for each function. \code{pkg_path} can be an
#'                 absolute or relative path.
#' @param pkg_reporters (list) a list of initialized package reporters
#' @param vignette_path (string) The path and filename of the output vignette
#'    file. The default assumes your working directory is the package root.
#' @importFrom rlang enexpr
#' @importFrom assertthat assert_that is.string is.readable
#' @importFrom tools file_ext
#' @importFrom R6 is.R6Class
#' @importFrom glue glue
#' @export
CreatePackageVignette <- function(pkg_name
                                  , pkg_path = NULL
                                  , pkg_reporters = list(
                                      DependencyReporter$new()
                                      , FunctionReporter$new()
                                  )
                                  , vignette_path = file.path("vignettes"
                                                              , "pkgnet_report.Rmd")
                                 ) {

    # Capture pkg_reporters expression for later injection into Rmd
    pkg_reporters_expr <- rlang::enexpr(pkg_reporters)

    ## pkg_name input checks ##
    assertthat::assert_that(
        assertthat::is.string(pkg_name)
        , pkg_name != ""
    )

    ## pkg_path input checks ##
    assertthat::assert_that(
        is.null(pkg_path) || assertthat::is.readable(pkg_path)
    )

    ## vignette_path input checks ##
    assertthat::assert_that(
        assertthat::is.string(vignette_path)
        , vignette_path != ""
        , identical(tolower(tools::file_ext(vignette_path)), "rmd")
    )
    # Confirm directory exists
    if (!file.exists(dirname(vignette_path))) {
        log_fatal(sprintf("Directory %s does not exist, please create first"
                  , dirname(vignette_path)))
    }

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
    )

    # If pkg_path supplied, add quotes, otherwise, set to NULL as a string
    if (!is.null(pkg_path)) {
        pkg_path <- paste0("\"", pkg_path, "\"")
    } else {
        pkg_path <- "NULL"
    }

    # Check if vignette_path matches the right package
    # if a vignettes directory is specified
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
            log_warn(paste("You specified a path to a vignettes directory"
                           , vignetteDirAbsPath
                           , "that is not inside a package root directory."))
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
        , pkg_path = pkg_path
        , pkg_reporters = deparse(pkg_reporters_expr)
        , .open = "{{"
        , .close = "}}"
    )

    # Write vignette Rmd to file
    rmd_conn <- file(description = vignette_path, open = 'w')
    on.exit(close(rmd_conn))
    writeLines(vignette_rmd, con = rmd_conn)

    log_info(sprintf("...successfully wrote vignette rmarkdown file to %s"
                     , normalizePath(vignette_path)))

    return(invisible(normalizePath(vignette_path)))
}
