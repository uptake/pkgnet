#' @title Default Reporters
#' @name DefaultReporters
#' @concept Reporters
#' @description Instantiates a list of default reporters to feed into
#'    \code{\link{CreatePackageReport}}.
#' @details
#' Default reporters are:
#' \itemize{
#'   \item \code{\link{SummaryReporter}}
#'   \item \code{\link{DependencyReporter}}
#'   \item \code{\link{FunctionReporter}}
#' }
#' 
#' Note, \code{\link{InheritanceReporter}} is not included in the default list.
#' 
#' If desired, append a new instance of \code{\link{InheritanceReporter}} to the \code{DefaultReporters} list.
#' 
#' ex: 
#' \code{c(DefaultReporters(), InheritanceReporter$new())}
#' @return list of instantiated reporter objects
#' @export
DefaultReporters <- function() {
    return(list(
          SummaryReporter$new()
        , DependencyReporter$new()
        , FunctionReporter$new()
    ))
}
