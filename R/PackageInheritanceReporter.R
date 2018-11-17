#' @title Package Class Inheritance Reporter Class
#' @name InheritanceReporter
#' @family PackageReporters
#' @export
InheritanceReporter <- R6::R6Class(
    "InheritanceReporter",
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
        nodes = function(){
            if (is.null(private$cache$nodes)){
                log_info("Extracting classes as nodes...")
                
                pkg_env <- private$get_pkg_env()
                
                nodeList <- list(data.table::data.table(
                    node = character(0), classType = character(0)
                ))
                
                for (item in names(pkg_env)) {
                    
                    # Reference classes
                    if (is(get(item, pkg_env), "refObjectGenerator")) {
                        nodeList <- c(nodeList, list(data.table::data.table(
                            node = get(item, pkg_env)$className
                            , classType = "Reference"
                        )))
                        
                    # R6 classes
                    } else if (R6::is.R6Class(get(item, pkg_env))) {
                        nodeList <- c(nodeList, list(data.table::data.table(
                            node = get(item, pkg_env)$classname
                            , classType = "R6"
                        )))
                    }
                    
                }
                
                nodeDT <- data.table::rbindlist(nodeList)
                private$cache$nodes <- nodeDT
            }
            return(private$cache$nodes)
        }, 
        edges = function(){
            if (is.null(private$cache$edges)){
                log_info("Extracting class inheritance as edges...")
                
                nodeDT <- self$nodes
                pkg_env <- private$get_pkg_env()
                edgeList <- list(data.table::data.table(
                    SOURCE = character(0)
                    , TARGET = character(0)
                ))
                for (thisNode in nodeDT[, node]) {
                    
                    # Reference Class
                    if (nodeDT[node == thisNode, classType == "Reference"]) {
                        classDef <- getClass(thisNode, where = pkg_env)
                        parents <- setdiff(
                            selectSuperClasses(classDef, direct = TRUE, namesOnly = TRUE)
                            , "envRefClass"
                        )
                        if (length(parents) > 0) {
                            edgeList <- c(
                                edgeList
                                , list(data.table::data.table(
                                    SOURCE = parents
                                    , TARGET = thisNode
                                ))
                            )
                        }
                        
                    # R6 Class
                    } else if (nodeDT[node == thisNode, classType == "R6"]) {
                        classDef <- get(thisNode, pkg_env)
                        parent <- classDef$get_inherit()$classname
                        if (!is.null(parent)) {
                            edgeList <- c(
                                edgeList
                                , list(data.table::data.table(
                                    SOURCE = parent
                                    , TARGET = thisNode
                                ))
                            )
                        }
                    }
                }
                
                edgeDT <- data.table::rbindlist(edgeList)
                private$cache$edges <- edgeDT
                
            }
            return(private$cache$edges)
        },
        
        report_markdown_path = function(){
            system.file(file.path("package_report", "package_inheritance_reporter.Rmd"), package = "pkgnet")
        }
    ),
    
    private = list(
        get_pkg_env = function() {
            if (is.null(private$cache$pkg_env)) {
                # create a custom environment w/ this package's contents
                private$cache$pkg_env <- loadNamespace(self$pkg_name)
            }
            return(private$cache$pkg_env)
        }
    )
    
)