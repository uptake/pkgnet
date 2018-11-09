#' @title Package Function Reporter Class
#' @name FunctionReporter
#' @family PackageReporters
#' @description This Reporter takes a package and uncovers the structure from
#'              its other functions, determining useful information such as which function is most
#'              central to the package. Combined with testing information it can be used as a powerful tool
#'              to plan testing efforts.
#' @section Public Methods:
#' \describe{
#'     \item{\code{set_package(pkg_name, pkg_path)}}{
#'         \itemize{
#'             \item{Set properties of this reporter. If pkg_name overrides a
#'                 previously-set package name, any cached data will be removed.}
#'             \item{\bold{Args:}}{
#'                 \itemize{
#'                 \item{\bold{\code{pkg_name}}: String with the name of the package.}
#'                 \item{\bold{\code{pkg_path}}: Optional directory path to source
#'                   code of the package. It is used for calculating test coverage.
#'                   It can be an absolute or relative path.}
#'                }
#'             }
#'         }
#'     }
#' }
#' @importFrom covr package_coverage
#' @importFrom data.table data.table melt as.data.table data.table setnames setcolorder rbindlist
#' @importFrom DT datatable formatRound
#' @importFrom R6 R6Class
#' @importFrom utils lsf.str
#' @export
FunctionReporter <- R6::R6Class(
    "FunctionReporter",
    inherit = AbstractGraphReporter,

    public = list(
        get_summary_view = function(){

            # Calculate network measures if not already done
            # since we want the node measures in summary
            invisible(self$network_measures)

            # Create DT for display
            tableObj <- DT::datatable(
                data = self$nodes
                , rownames = FALSE
                , options = list(
                    searching = FALSE
                    , pageLength = 50
                    , lengthChange = FALSE
                )
            )
            # Round the double columns to three digits for formatting reasons
            numCols <- names(which(unlist(lapply(tableObj$x$data, is.double))))
            tableObj <- DT::formatRound(columns = numCols, table = tableObj
                                        , digits=3)
            return(tableObj)
        }
    ),

    active = list(
        edges = function(){
            if (is.null(private$cache$edges)){
                log_info("Calling extract_network() to extract nodes and edges...")
                private$extract_network()
            }
            return(private$cache$edges)
        },
        nodes = function(){
            if (is.null(private$cache$nodes)){
                log_info("Calling extract_network() to extract nodes and edges...")
                private$extract_network()
            }
            return(private$cache$nodes)
        },
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_function_reporter.Rmd"), package = "pkgnet")
        }
    ),

    private = list(

        # add coverage to nodes table
        calculate_test_coverage = function(){

            log_info(msg = "Calculating package coverage...")

            pkgCov <- covr::package_coverage(
                path = private$pkg_path
                , type = "tests"
                , combine_types = FALSE
            )

            pkgCov <- data.table::as.data.table(pkgCov)
            pkgCov <- pkgCov[, list(coveredLines = sum(value > 0)
                                    , totalLines = .N
                                    , coverageRatio = sum(value > 0)/.N
                                    , meanCoveragePerLine = sum(value)/.N
                                    , filename = filename[1]
            )
            , by = list(node = functions)]

            # Update Node with Coverage Info
            private$update_nodes(metadataDT = pkgCov)

            # Set Graph to Color By Coverage
            private$set_plot_node_color_scheme(
                field = "coverageRatio"
                , pallete = c("red", "green")
            )

            # Calculate network measures since we need outBetweeness
            invisible(self$network_measures)

            meanCoverage <-  pkgCov[, sum(coveredLines, na.rm = TRUE) / sum(totalLines, na.rm = TRUE)]
            private$cache$network_measures[['packageTestCoverage.mean']] <- meanCoverage

            weightVector <- self$nodes$outBetweeness / sum(self$nodes$outBetweeness, na.rm = TRUE)

            betweenness_mean <- weighted.mean(
                x = self$nodes$coverageRatio
                , w = weightVector
                , na.rm = TRUE
            )
            private$cache$network_measures[['packageTestCoverage.betweenessWeightedMean']] <- betweenness_mean

            log_info(msg = "Done calculating package coverage")
            return(invisible(NULL))
        },

        extract_network = function(){
            # Reset cache, because any cached stuff will be outdated with a new network
            private$reset_cache()
            
            log_info(sprintf('Extracting nodes from %s...', self$pkg_name))
            private$cache$nodes <- private$extract_nodes()
            log_info('Done extracting nodes.')
            
            log_info(sprintf('Extracting edges from %s...', self$pkg_name))
            private$cache$edges <- private$extract_edges()
            log_info('Done extracting edges.')

            # TODO (james.lamb@uptake.com):
            # Make this handoff with coverage cleaner
            if (!is.null(private$pkg_path)){
                private$calculate_test_coverage()
            }

            return(invisible(NULL))
        },

        extract_nodes = function(){
            if (is.null(self$pkg_name)) {
                log_fatal('Must set_package() before extracting nodes.')
            }
            
            # create a custom environment w/ this package's contents
            pkg_env <- loadNamespace(self$pkg_name)
            
            # Filter objects to just functions
            # This will now be a character vector full of function names
            funs <- Filter(
                f = function(x, p = pkg_env){is.function(get(x, p))}
                , x = names(pkg_env)
            )
            
            # Create nodes data.table
            nodes <- data.table::data.table(node = funs)
            
            # Figure out which functions are exported
            # We need the package to be loaded first
            suppressPackageStartupMessages({
                require(self$pkg_name
                        , lib.loc = .libPaths()[1]
                        , character.only = TRUE)
            })
            exported_obj_names <- ls(sprintf("package:%s", self$pkg_name))
            nodes[, isExported := node %in% exported_obj_names]

            return(nodes)
        },

        extract_edges = function(){
            if (is.null(self$pkg_name)) {
                log_fatal('Must set_package() before extracting edges.')
            }

            log_info(sprintf('Constructing network representation...'))
            
            # create a custom environment w/ this package's contents
            pkg_env <- loadNamespace(self$pkg_name)
            
            # Get table of edges between functions
            # for each function, check if anything else in the package
            # was called by it
            funs <- self$nodes[, node]
            edgeDT <- data.table::rbindlist(
                lapply(
                    X = funs
                    , FUN = .called_by
                    , all_functions = funs
                    , pkg_env = pkg_env
                )
                , fill = TRUE
            )
            
            # If there are no edges, we still want to return a length-zero 
            # data.table with correct columns
            if (nrow(edgeDT) == 0) {
                log_info("Edge list is empty.")
                edgeDT <- data.table::data.table(
                                SOURCE = character()
                                , TARGET = character()
                            )
            }

            log_info("Done constructing network representation")

            return(edgeDT)
        }
    )
)

# [description] given a function name, return edgelist of
#               all other functions it calls
#' @importFrom assertthat is.string
#' @importFrom data.table data.table
.called_by <- function(fname, all_functions, pkg_env){

    assertthat::assert_that(
        is.environment(pkg_env)
        , is.character(all_functions)
        , assertthat::is.string(fname)
    )

    # get the body of the function
    f <- get(fname, envir = pkg_env)

    # get the literal code of the function
    f_vec <- .parse_function(f)

    # Figure out which ones mix
    matches <- match(
        x = f_vec
        , table = all_functions
        , nomatch = 0
    )
    matches <- matches[matches > 0]

    if (length(matches) == 0){
        return(invisible(NULL))
    }

    edgeDT <- data.table::data.table(
        SOURCE = fname
        , TARGET = unique(all_functions[matches])
    )

    return(edgeDT)
}

# [description] parse out a function's body into a character
#               vector separating the individual symbols
.parse_function <- function (x) {

    listable <- (!is.atomic(x) && !is.symbol(x))

    if (!is.list(x) && listable) {
        x <- as.list(x)
    }

    if (listable){
        out <- unlist(lapply(x, .parse_function), use.names = FALSE)
    } else {
        out <- paste(deparse(x), collapse = "\n")
    }
    return(out)
}
