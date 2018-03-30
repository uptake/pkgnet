#' @title Package Summary Reporter Class
#' @name SummaryReporter
#' @family PackageReporters
#' @description Defines a concrete implementation of \link{AbstractPackageReporter} 
#'              for a high level overview of a particular package. It will summarize
#'              things like lines of code, whether it's on CRAN, etc.
#' @inheritSection AbstractPackageReporter Public Methods
#' @importFrom R6 R6Class
#' @export
SummaryReporter <- R6::R6Class(
    classname = "SummaryReporter",
    inherit = AbstractPackageReporter,
    public = list(
        get_summary_view = function(){
          
          # Read DESCRIPTION file into a table
          desc <- utils::packageDescription(self$pkg_name)
          descDT <- data.table::data.table(
              Field = names(desc)
              , Values = unlist(desc)
          )
          
          # Render DT table
          tableObj <- DT::datatable(
            data = descDT
            , rownames = FALSE
            , options = list(
              searching = FALSE
              , pageLength = 50
              , lengthChange = FALSE
            )
          )
          return(tableObj)
        }
    ),
    
    active = list(
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_summary_reporter.Rmd"), package = "pkgnet")
        }
    )
)
