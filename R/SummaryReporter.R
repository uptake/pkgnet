#' Package Summary Reporter
#' 
#' @description 
#' This reporter provides a high-level overview of a package via its package DESCRIPTION file.
#' @family Package Reporters
#' @concept Reporters
#' @importFrom R6 R6Class
#' @importFrom utils packageDescription
#' @importFrom data.table data.table
#' @importFrom DT datatable
#' @export
SummaryReporter <- R6::R6Class(
    classname = "SummaryReporter",
    inherit = AbstractPackageReporter,
    public = list(
        #' @description Returns an htmlwidget object that summarizes the analysis of the reporter. 
        #' Used when creating a \link[=CreatePackageReport]{package report}.
        #' @return Self, invisibly.
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
        #' @field report_markdown_path (character string) path to R Markdown template for this reporter. Read-only.
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_summary_reporter.Rmd"), package = "pkgnet")
        }
    )
)
