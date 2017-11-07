#' @title Package Dependency Reporter Class
#' @name PackageDependencyReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other package dependencies, determining which package it relies on is most central,
#'              allowing for a developer to determine how to vett its dependency tree
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(packageName, ...)}}{
#'         \itemize{
#'             \item{Set the package that all operations in the object are done for.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{packageName}}: a string with the name of the package you are
#'                   analyzing.}
#'                 \item{\bold{\code{...}}: other arguments passed through to \code{ExtractDependencyNetwork}}
#'                  }
#'              }
#'          }
#'     }
#' }
#' @importFrom data.table data.table
#' @importFrom R6 R6Class
#' @export
PackageDependencyReporter <- R6::R6Class(
    "PackageDependencyReporter",
    inherit = AbstractGraphReporter,
    
    #TODO [patrick.boueri@uptake.com]: Add more robust error checks and logging
    #TODO [patrick.boueri@uptake.com]: Add version information to dependency structure

    public = list(
        set_package = function(packageName, ...) {
            private$edges <- ExtractDependencyNetwork(packageName, ...)
            private$nodes <- data.table::data.table(node = unique(c(private$edges[, SOURCE], private$edges[,TARGET])))
            private$packageName <- packageName
            private$pkgGraph <- MakeGraphObject(private$edges,private$nodes)
        }
    )
)
