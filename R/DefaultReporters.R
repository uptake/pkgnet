#' @title Default Reporters
#' @name DefaultReporters
#' @description Instantiates a list of default reporters to feed into
#'    \code{\link{CreatePackageReport}}.
#' @return list of instantiated reporter objects
#' @export
DefaultReporters <- function() {
    return(list(
          SummaryReporter$new()
        , DependencyReporter$new()
        , FunctionReporter$new()
    ))
}
