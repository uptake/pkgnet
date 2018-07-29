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
#' @importFrom data.table data.table melt as.data.table data.table setnames setcolorder
#' @importFrom mvbutils foodweb
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

            log_info(sprintf('Extracting edges from %s...', self$pkg_name))
            private$cache$edges <- private$extract_edges()
            log_info('Done extracting edges.')

            log_info(sprintf('Extracting nodes from %s...', self$pkg_name))
            private$cache$nodes <- private$extract_nodes()
            log_info('Done extracting nodes.')

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
            nodes <- data.table::data.table(node = as.character(
                unlist(
                    utils::lsf.str(pos = asNamespace(self$pkg_name)
                                   )
                    )
                )
            )
            return(nodes)
        },

        extract_edges = function(){
            if (is.null(self$pkg_name)) {
                log_fatal('Must set_package() before extracting edges.')
            }

            log_info(sprintf('Loading %s...', self$pkg_name))
            suppressPackageStartupMessages({
                require(self$pkg_name
                        , lib.loc = .GetLibPaths()
                        , character.only = TRUE)
            })
            log_info(sprintf('Done loading %s', self$pkg_name))

            # Avoid mvbutils::foodweb bug on one function packages
            numFuncs <- as.character(unlist(utils::lsf.str(asNamespace(self$pkg_name)))) # list of functions within Package
            if (length(numFuncs) == 1) {
                log_info("Only one function. Edge list is empty")
                return(data.table::data.table(SOURCE = character(), TARGET = character()))
            }

            log_info(sprintf('Constructing network representation...'))

            # foodweb will output a warning for "In par(oldpar) : calling par(new=TRUE) with no plot" all the time.
            # does not seem to be an issue
            funcMap <- suppressWarnings({
                mvbutils::foodweb(
                    where = paste("package"
                                  , self$pkg_name
                                  , sep = ":")
                    ,
                    plotting = FALSE
                )
            })

            log_info("Done constructing network representation")

            # Function Connections: Edges
            edges <- data.table::melt(
                data.table::as.data.table(funcMap$funmat, keep.rownames = TRUE)
                , id.vars = "rn"
            )[value != 0]

            # Formatting
            edges[, value := NULL]
            edges[, SOURCE := as.character(variable)]
            edges[, TARGET := as.character(rn)]
            edges[, variable := NULL]
            edges[, rn := NULL]
            data.table::setcolorder(edges, c('SOURCE', 'TARGET'))

            # If no edges, return empty data.table
            if (nrow(edges) == 0) {
                return(data.table::data.table(SOURCE = character(), TARGET = character()))
            }

            return(edges)
        }
    )
)
