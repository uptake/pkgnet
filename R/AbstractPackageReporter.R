#' @title Abstract Package Reporter Class
#' @name AbstractPackageReporter
#' @family AbstractReporters
#' @description Defines the Abstract Class for all PackageReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @importFrom R6 R6Class
#' @importFrom tools file_path_as_absolute
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(pkg_name, pkg_path = NULL)}}{
#'         \itemize{
#'             \item{Set the package that all operations in the object are done for.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{pkg_name}}: A string with the name of the package you are
#'                   analyzing.}
#'                 \item{\bold{\code{pkg_path}}: Optional directory path to source
#'                   code of the package. It is used for calculating test coverage.
#'                   It can be an absolute or relative path.}
#'                  }
#'              }
#'          }
#'     }
#'     \item{\code{get_summary_view()}}{
#'         \itemize{
#'             \item{Returns a particular reporters summary report on the package for use in a high level view}
#'       }
#'     }
#' }
#' @export
AbstractPackageReporter <- R6::R6Class(
    classname = "AbstractPackageReporter",
    
    public = list(
        
        set_package = function(pkg_name, pkg_path = NULL) {
            
            private$private_pkg_name <- pkg_name
            
            if (exists("pkg_path") && !is.null(pkg_path)) {
                if (dir.exists(pkg_path)) {
                    private$pkg_path <- tools::file_path_as_absolute(pkg_path)
                } else {
                    log_fatal(paste0("Package directory does not exist: ", pkg_path))
                }
            }
            
            # Reset cached variables to NULL
            private$reset_cache()
            
            return(invisible(NULL))
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
        
        # Reset cached variables
        reset_cache = function() {
            # If cache is NULL, we're setting it to default for the first time
            # then no need to print a log message
            if (!is.null(private$cache)) {
                log_info("Resetting cached network information...")
                for (item in names(private$cache)){
                    private$cache[[item]] <- NULL
                }
            }
            return(invisible(NULL))
        }
    )
)
