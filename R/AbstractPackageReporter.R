#' @title Abstract Package Reporter Class
#' @name AbstractPackageReporter
#' @family AbstractReporters
#' @description Defines the Abstract Class for all PackageReporters defined in pkgnet.
#'              The class is not meant to be instantiated, but inherited from and its methods
#'              overloaded such that each Metric implements certain functionality.
#' @importFrom R6 R6Class
#' @section Public Methods:
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
#'                  }
#'              }
#'          }
#'     }
#'     \item{\code{get_report()}}{
#'         \itemize{
#'             \item{Returns a particular reporter's report on the package}
#'       }
#'     }
#'     \item{\code{get_summary_view()}}{
#'         \itemize{
#'             \item{Returns a particular reporters summary report on the package}
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
    "AbstractPackageReporter",
    
    public = list(

        get_package = function(){
            return(private$packageName)
        },
        
        set_package = function(packageName) {
            stop("set_package has not been implemented.")
        },
        
        get_report =  function() {
            stop("get_report has not been implemented.")
        },
        
        get_summary_view  = function(){
            stop("get_summary_view has not been implemented.")
        },
        
        get_raw_data = function(){
            return(as.list(private))
        }
    ),
    
    private = list(
        packageName = NULL
    )
)
