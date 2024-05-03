#' Abstract Package Reporter
#' 
#' @description 
#' pkgnet defines several package reporter R6 classes that analyze 
#' some particular aspect of a package. These reporters share common
#' functionality and interfaces defined by a base reporter class
#' \code{AbstractPackageReporter}.
#'
#' @keywords internal
#' @concept Reporters
#' @importFrom R6 R6Class
#' @importFrom assertthat assert_that is.string
#' @importFrom tools file_path_as_absolute
AbstractPackageReporter <- R6::R6Class(
    classname = "AbstractPackageReporter",

    public = list(

        #' @description
        #' Set the package that the reporter will analyze. This can 
        #' only be done once for a given instance of a reporter. 
        #' Instantiate a new copy of the reporter if you need to analyze a different package.
        #' @param pkg_name (character string) name of package
        #' @param pkg_path (character string) optional directory path to source code of the package. 
        #' It is used for calculating test coverage. It can be an absolute or relative path.
        #' @return Self, invisibly.
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
            .validate_pkg_name(pkg_name)

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

        #' @description Returns an htmlwidget object that summarizes the analysis of the reporter. 
        #' Used when creating a \link[=CreatePackageReport]{package report}.
        #' @return Self, invisibly.
        get_summary_view  = function(){
            stop("get_summary_view has not been implemented.")
        }
    ),

    active = list(

        #' @field pkg_name (character string) name of set package. Read-only.
        pkg_name = function(){
            return(private$private_pkg_name)
        },

        #' @field report_markdown_path (character string) path to R Markdown template for this reporter. Read-only.
        report_markdown_path = function(){
            log_fatal("this reporter does not have a report markdown path")
        }
    ),

    private = list(
        private_pkg_name = NULL,
        pkg_path = NULL,
        cache = NULL
    )
)

# given a string with a package name, check whether
# it exists
#' @importFrom utils installed.packages
.validate_pkg_name <- function(pkg_name){
    installed_packages <- row.names(utils::installed.packages())
    if (! pkg_name %in% installed_packages){
        msg <- paste(
            sprintf(
                "pkgnet could not find an installed package named '%s'."
                , pkg_name
            )
            , "Please install the package first."
        )
        log_fatal(msg)
    }
    return(invisible(NULL))
}

# Check if an object is a pkgnet Package Reporter
#' @importFrom R6 is.R6
.is.PackageReporter <- function(x) {
    return(R6::is.R6(x) & inherits(x, "AbstractPackageReporter"))
}
