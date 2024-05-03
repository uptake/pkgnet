#' R6 Class Representing an R Package Report
#'
#' @description
#' pkgnet compiles one or more package reporters into a package
#' report for a specified package. \code{PackageReport} is an R6 class that
#' holds all of those reporters and has a method \code{render_report()}
#' to generate an HTML report file. You can access each individual reporter
#' and modify it using its methods if you wish.
#'
#' The function \code{\link{CreatePackageReport}()} is a shortcut for both
#' generating a \code{PackageReport} object with instantiated reporters
#' and creating the HTML report in one call.
#' 
#' @concept Reporters
#' @importFrom assertthat assert_that is.readable is.string is.writeable
#' @importFrom tools file_ext
#' @importFrom utils browseURL
#' @importFrom rmarkdown render
#' @export
PackageReport <- R6::R6Class(
    classname = "PackageReport"
    , public = list(

        #' @description 
        #' Initialize an instance of a package report object.
        #' @param pkg_name (character string) name of package
        #' @param pkg_path (character string) optional directory path to source code of the package. 
        #' It is used for calculating test coverage. It can be an absolute or relative path.
        #' @param report_path (character string) The path and filename of the output report. 
        #' Default report will be produced in the temporary directory.
        #' @return Instantiated package report object.
        initialize = function(pkg_name
                              , pkg_path = NULL
                              , report_path = tempfile(
                                    pattern = pkg_name
                                    , fileext = ".html"
                                  )
                              ) {
            # Input validation for pkg_name, pkg_path
            # report_path validated by its active binding
            assertthat::assert_that(
                assertthat::is.string(pkg_name)
                , pkg_name != ""
                , is.null(pkg_path) || assertthat::is.readable(pkg_path)
            )
            .validate_pkg_name(pkg_name)

            private$protected$pkg_name <- pkg_name
            private$protected$pkg_path <- pkg_path
            self$report_path <- report_path

            return(invisible(self))
        }

        #' @description
        #' Add a reporter to the package report.
        #' @param reporter Instantiated package reporter object
        #' @return Self, invisibly
        , add_reporter = function(reporter) {
            private$set_reporter(reporter, class = class(reporter)[1])
            return(invisible(self))
        }

        #' @description
        #' Render html pkgnet package report.
        #' @returns Self, invisibly. 
        , render_report = function() {
            log_info("Rendering package report...")

            rmarkdown::render(
                input = system.file(
                    file.path("package_report", "package_report.Rmd")
                    , package = "pkgnet"
                )
                , output_dir = dirname(self$report_path)
                , output_file = basename(self$report_path)
                , quiet = TRUE
                , params = list(
                    reporters = private$reporters
                    , pkg_name = self$pkg_name
                )
            )

            log_info(paste(
                "Done creating package report!"
                , sprintf("It is available at %s", self$report_path)
            ))

            # If suppress flag is unset, then env variable will be emptry string ""
            if (identical(Sys.getenv("PKGNET_SUPPRESS_BROWSER"), "")) {
                utils::browseURL(self$report_path)
            }

            return(invisible(self))
        }

    ) # / public

    , active = list(
        #' @field pkg_name (character string) name of package. Read-only.
        pkg_name = function() {
            return(private$protected$pkg_name)
        }
        #' @field pkg_path (character string) path to source code of the package. Read-only.
        , pkg_path = function() {
            return(private$protected$pkg_path)
        }
        #' @field report_path (character string) path and filename of output report.
        , report_path = function(report_path) {
            if (!missing(report_path)) {
                assertthat::assert_that(
                    assertthat::is.string(report_path)
                    , report_path != ""
                )
                if (!identical(tolower(tools::file_ext(report_path)), "html")){
                    log_fatal(paste(
                        "report_path must be a .html file path."
                        , sprintf("You gave '%s'.", report_path)
                    ))
                }
                assertthat::assert_that(
                    assertthat::is.writeable(dirname(report_path))
                )

                private$protected$report_path <- report_path
            }
            return(private$protected$report_path)
        }
        #' @field SummaryReporter Instantiated pkgnet \code{\link{SummaryReporter}} object
        , SummaryReporter = function(reporter) {
            if (!missing(reporter)) {
                private$set_reporter(reporter, class = "SummaryReporter")
            }
            return(private$reporters$SummaryReporter)
        }
        #' @field DependencyReporter Instantiated pkgnet \code{\link{DependencyReporter}} object
        , DependencyReporter = function(reporter) {
            if (!missing(reporter)) {
                private$set_reporter(reporter, class = "DependencyReporter")
            }
            return(private$reporters$DependencyReporter)
        }
        #' @field FunctionReporter Instantiated pkgnet \code{\link{FunctionReporter}} object
        , FunctionReporter = function(reporter) {
            if (!missing(reporter)) {
                private$set_reporter(reporter, class = "FunctionReporter")
            }
            return(private$reporters$FunctionReporter)
        }
        #' @field InheritanceReporter Instantiated pkgnet \code{\link{InheritanceReporter}} object
        , InheritanceReporter = function(reporter) {
            if (!missing(reporter)) {
                private$set_reporter(reporter, class = "InheritanceReporter")
            }
            return(private$reporters$InheritanceReporter)
        }
    ) # /active

    , private = list(
        protected = list(
            pkg_name = NULL
            , pkg_path = NULL
            , report_path = NULL

        )
        , reporters = list()

        , set_reporter = function(reporter, class) {

            # If setting to NULL, it means we want to remove the reporter
            if (is.null(reporter)) {
                private$reporters[[class]] <- NULL
                return(invisible(NULL))
            }

            # Validate that it's not an R6 generator
            if (is.R6Class(reporter)) {
                log_fatal(paste(
                    sprintf(
                        "You specified an R6 class generator for class %s."
                        , reporter$classname
                    )
                    , sprintf(
                        "PackageReport is expecting initialized %s object."
                        , class
                    )
                ))
            }
            assertthat::assert_that(
                .is.PackageReporter(reporter)
                , inherits(reporter, class)
            )
            private$reporters[[class]] <- reporter
            private$reporters[[class]]$set_package(
                pkg_name = self$pkg_name
                , pkg_path = self$pkg_path
            )
            return(invisible(NULL))
        }
    ) # /private
)

#' @title pkgnet Analysis Report for an R package
#' @name CreatePackageReport
#' @concept Main Functions
#' @description Create a standalone HTML report about a package and its networks.
#' @param pkg_name (string) name of a package
#' @param pkg_path (string) The path to the package repository. If given, coverage
#'                 will be calculated for each function. \code{pkg_path} can be an
#'                 absolute or relative path.
#' @param pkg_reporters (list) a list of package reporters
#' @param report_path (string) The path and filename of the output report.  Default
#'                   report will be produced in the temporary directory.
#' @return an instantiated \code{\link{PackageReport}} object
#' @export
CreatePackageReport <- function(pkg_name
                                , pkg_reporters = DefaultReporters()
                                , pkg_path = NULL
                                , report_path = tempfile(pattern = pkg_name, fileext = ".html")
                                ) {

    # pkg_name, pkg_path, report_path validated by PackageReport

    ## pkg_reporters input checks ##
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
    # Confirm that all reporters are recognized by PackageReport
    lapply(
        X = pkg_reporters
        , FUN = function(reporter) {
            assertthat::assert_that(
                class(reporter)[1] %in% names(PackageReport$active)
            )
        }
    )

    log_info(paste0("Creating package report for package "
                    , pkg_name
                    , " with reporters: "
                    , paste(unlist(lapply(pkg_reporters, function(x) class(x)[1]))
                            , collapse = ", ")))

    ## Create PackageReport object ##
    createdReport <- PackageReport$new(
        pkg_name = pkg_name,
        pkg_path = pkg_path,
        report_path = report_path
    )
    lapply(
        X = pkg_reporters
        , FUN = function(reporter) {
            class <- class(reporter)[1]
            createdReport[[class]] <- reporter
        }
    )

    createdReport$render_report()

    return(invisible(createdReport))
}

### Imports from package_report.Rmd
#' @importFrom knitr opts_chunk knit_child
NULL
