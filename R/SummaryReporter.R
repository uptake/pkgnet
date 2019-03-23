#' @title Package Summary Reporter
#' @name SummaryReporter
#' @family Package Reporters
#' @description This reporter provides a high-level overview of a package via
#'    its package DESCRIPTION file.
#' @section Class Constructor:
#' \preformatted{SummaryReporter$new()}
#' @inheritSection PackageReporters Class Constructor
#' @inheritSection PackageReporters Public Methods
#' @inheritSection PackageReporters Public Fields
#' @inheritSection PackageReporters Special Methods
NULL


#' @importFrom R6 R6Class
#' @importFrom utils packageDescription
#' @importFrom data.table data.table
#' @importFrom DT datatable
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
