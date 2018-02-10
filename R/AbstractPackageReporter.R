#' @title Abstract Package Reporter Class
#' @name AbstractPackageReporter
#' @family AbstractReporters
#' @description Defines the Abstract Class for all PackageReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @importFrom R6 R6Class
#' @section Public:
#' \describe{
#'     \item{\code{get_package()}}{
#'         \itemize{
#'             \item{Returns a string with the name of the package used to construct
#'                 this object}
#'       }
#'     }
#'     \item{\code{set_package(packageName)}}{
#'         \itemize{
#'             \item{Set the package that all operations in the object are done for.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{packageName}}: a string with the name of the package you are
#'                   analyzing.}
#'                   \item{\bold{\code{packagePath}}: directory path to source code of package}
#'                  }
#'              }
#'          }
#'     }
#'     \item{\code{get_report()}}{
#'         \itemize{
#'             \item{Returns a particular reporter's report on the package}
#'       }
#'     }
#'     \item{\code{get_report_markdown_path()}}{
#'         \itemize{
#'             \item{Returns the path to the markdown report associated with this reporter}
#'       }
#'     }
#'     \item{\code{get_summary_view()}}{
#'         \itemize{
#'             \item{Returns a particular reporters summary report on the package for use in a high level view}
#'       }
#'     }
#'     \item{\code{calculate_package_metrics()}}{
#'         \itemize{
#'             \item{Calculates all the relevant metrics for a set package and updates the reporter}
#'       }
#'     }
#'     \item{\code{get_raw_data()}}{
#'         \itemize{
#'             \item{Returns a particular reporter's raw data.}
#'       }
#'     }
#' }
#' @section Abstract Methods:
#' \describe{
#'    \item{\code{getPackageMetrics}}{Accepts a package name as a string and calculates the PackageMetrics required for that reporter}
#'    \item{\code{generateReport}}{Generates a a child report for an overall knit package report}
#'    \item{\code{getSummaryView}}{Returns a summarized view of the package metrics as a data.table}
#'    \item{\code{getRawData}}{Returns the internal data of the packageReporter as a list}
#' }
#' @export
AbstractPackageReporter <- R6::R6Class(
    classname = "AbstractPackageReporter",
    
    public = list(
        
        set_package = function(packageName, packagePath = NULL) {
            
            private$packageName <- packageName
            
            if (exists("packagePath") && !is.null(packagePath)) {
                if (dir.exists(packagePath)) {
                    private$packagePath <- packagePath
                } else {
                    log_fatal(paste0("Package directory does not exist: ", packagePath))
                }
            }
            
            # Reset cached variables to NULL
            private$reset_cache()
            
            return(invisible(NULL))
        },
        
        get_package = function(){
            return(private$packageName)
        },
   
        get_report =  function(output_file = NULL) {
            rmarkdown::render(self$get_report_markdown_path()
                              , output_format = "html_document"
                              , output_file = output_file
                              , quiet = TRUE
                              , envir = new.env()
                              , params = list(reporter = self))
        },
        

        get_package_path = function(){
            return(private$packagePath)
        },
        
        get_report_markdown_path =  function() {
            stop("get_report_markdown_path has not been implemented.")
        },
        
        get_summary_view  = function(){
            stop("get_summary_view has not been implemented.")
        },

        get_raw_data = function(){
            return(as.list(private))
        }
    ),
    
    private = list(
        packageName = NULL,
        packagePath = NULL,
        
        cache = NULL,
        defaultCache = NULL,
        
        # Reset cached variables
        reset_cache = function() {
            # If cache is NULL, we're setting it to default for the first time
            # then no need to print a log message
            if (!is.null(private$cache)) {
                log_info("Resetting cached network information...")
            }
            # Set cache to default cache
            private$cache <- private$defaultCache
            
            return(invisible(NULL))
        }
    )
)
