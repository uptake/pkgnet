#' @title Default Reporters
#' @name DefaultReporters
#' @description Instantiates a list of default reporters to feed into \link{CreatePackageReport}
#' @export
DefaultReporters <- function() {
    return(list(
          SummaryReporter$new()
        , DependencyReporter$new()
        , FunctionReporter$new()
    ))
}
