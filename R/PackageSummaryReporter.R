#' @title Package Summary Reporter Class
#' @name PackageSummaryReporter
#' @family PackageReporters
#' @description Defines a concrete implementation of \link{AbstractPackageReporter} for a high level overview
#'              of a particular package. It will summarize things like Lines of code, whether it's on CRAN, etc.
#' @inheritSection AbstractPackageReporter Public
#' @importFrom R6 R6Class
#' @export
PackageSummaryReporter <- R6::R6Class(
    classname = "PackageSummaryReporter",
    inherit = AbstractPackageReporter,
    public = list(
        get_report_markdown_path = function(){
            system.file(file.path("package_report","package_summary_reporter.Rmd"),package = "pkgnet")
        },
        get_description = function(){
            obj <- private$packageDescription
            dt <- data.table::data.table(Field = names(obj)
                                         , Values = unlist(obj)
                                         )
            return(dt)
        },
        get_objects = function(){
            return(private$packageObjects)
        },
        calculate_all_metrics = function(){
            private$get_package_description()
            private$get_num_objects()
        }, 
        plot_network = function(){
          # No network in summary reporter
          return(NULL)
        }
    ),
    
    private = list(
        packageMetrics = list()
        , packageDescription = list()
        , packageObjects = list()
        , get_package_description = function() {
            private$packageDescription <- utils::packageDescription(private$packageName)
        }
        , get_num_objects = function() {
            private$packageObjects[["exported"]] <- length(base::getNamespaceExports(private$packageName))
            private$packageObjects[["all"]] <- length(ls(base::getNamespace(private$packageName)))
        }
    )
)
