#' @title Package Reporters
#' @name PackageReporters
#' @keywords internal
#' @description pkgnet defines several package reporter R6 classes that analyze
#'     some particular aspect of a package. These reporters share common
#'     functionality and interfaces defined by a base reporter class
#'     \code{AbstractPackageReporter}.
#' @section Class Constructor:
#' \describe{
#'     \item{\code{}}{
#'         \itemize{
#'             \item{Initialize an instance of the reporter.}
#'             \item{\bold{Returns:}}{
#'                 \itemize{
#'                     \item{Instantiated reporter object. Note that this
#'                        reporter object isn't useful yet until you use the
#'                        \code{set_package} method to set a package.
#'                     }
#'                 }
#'             }
#'         }
#'     }
#' }
#'
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(pkg_name, pkg_path = NULL)}}{
#'         \itemize{
#'             \item{Set the package that the reporter will analyze. This can
#'                 only be done once for a given instance of a reporter.
#'                 Instantiate a new copy of the reporter if you need to analyze
#'                 a different package.
#'             }
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                     \item{\bold{\code{pkg_name}}: character string, name of
#'                      package
#'                  }
#'                     \item{\bold{\code{pkg_path}}: character string, optional
#'                     directory path to source code of the package. It is used
#'                     for calculating test coverage. It can be an absolute or
#'                     relative path.
#'                  }
#'                 }
#'             }
#'             \item{\bold{Returns:}}{
#'                 \itemize{
#'                     \item{Self, invisibly.}
#'                 }
#'             }
#'         }
#'     }
#'     \item{\code{get_summary_view()}}{
#'         \itemize{
#'             \item{Returns an htmlwidget object that summarizes the analysis
#'                 of the reporter. Used when creating a
#'                 \link[=CreatePackageReport]{package report}.
#'             }
#'             \item{\bold{Returns:}}{
#'                 \itemize{
#'                     \item{\link[htmlwidgets:htmlwidgets-package]{htmlwidget}
#'                         object
#'                     }
#'                 }
#'             }
#'         }
#'     }
#' }
#'
#' @section Public Fields:
#' \describe{
#'     \item{\bold{\code{pkg_name}}}{: character string, name of set package.
#'         Read-only.
#'     }
#'     \item{\bold{\code{report_markdown_path}}}{: character string, path to
#'         R Markdown template for this reporter. Read-only.
#'     }
#' }
#'
#' @section Special Methods:
#' \describe{
#'     \item{\code{clone(deep = FALSE)}}{
#'         \itemize{
#'             \item{Method for copying an object. See
#'                 \href{https://adv-r.hadley.nz/r6.html#r6-semantics}{\emph{Advanced R}}
#'                 for the intricacies of R6 reference semantics.
#'             }
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                     \item{\bold{\code{deep}}: logical. Whether to recursively
#'                     clone nested R6 objects.
#'                  }
#'                 }
#'             }
#'             \item{\bold{Returns:}}{
#'                 \itemize{
#'                     \item{Cloned object of this class.}
#'                 }
#'             }
#'         }
#'     }
#' }
NULL

#' @importFrom R6 R6Class
#' @importFrom assertthat assert_that is.string
#' @importFrom tools file_path_as_absolute
#' @importFrom utils installed.packages
AbstractPackageReporter <- R6::R6Class(
    classname = "AbstractPackageReporter",

    public = list(

        set_package = function(pkg_name, pkg_path = NULL) {

            # Packages can only be set once
            if (!is.null(private$private_pkg_name)) {
                log_fatal(paste(
                    "A package has already been set for this reporter."
                    , "Please instantiate a new reporter to set a new package."
                ))
            }

            # check inputs
            assertthat::assert_that(
                assertthat::is.string(pkg_name)
                , pkg_name != ""
            )
            private$validate_pkg_name(pkg_name)

            private$private_pkg_name <- pkg_name

            if (exists("pkg_path") && !is.null(pkg_path)) {
                if (dir.exists(pkg_path)) {
                    private$pkg_path <- tools::file_path_as_absolute(pkg_path)
                } else {
                    log_fatal(paste0("Package directory does not exist: ", pkg_path))
                }
            }

            return(invisible(self))
        },

        get_summary_view  = function(){
            stop("get_summary_view has not been implemented.")
        }
    ),

    active = list(

        pkg_name = function(){
            return(private$private_pkg_name)
        },

        report_markdown_path = function(){
            log_fatal("this reporter does not have a report markdown path")
        }
    ),

    private = list(
        private_pkg_name = NULL,
        pkg_path = NULL,
        cache = NULL,

        # given a string with a package name, check whether
        # it exists
        validate_pkg_name = function(pkg_name){
            log_info("Checking installed packages...")
            installed_packages <- row.names(
                utils::installed.packages()
            )

            if (! pkg_name %in% installed_packages){
              msg <- sprintf("pkgnet could not find an installed package named '%s'. Please install the package first.", pkg_name)
              log_fatal(msg)
            }

            log_info(sprintf("Found '%s' in installed packages.", pkg_name))
            return(invisible(NULL))
        }
    )
)

# Check if an object is a pkgnet Package Reporter
.is.PackageReporter <- function(x) {
    inherits(x, "AbstractPackageReporter")
}
