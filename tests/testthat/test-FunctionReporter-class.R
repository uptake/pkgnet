context("FunctionReporter Class Tests")
rm(list = ls())

##### TESTS #####

## PUBLIC INTERFACE ##

test_that('FunctionReporter public interface is as expected', {

    publicInterfaceExpected <- c(
        # R6 Special Methods
        ".__enclos_env__"
        , "clone"

        # Graph Reporter fields and active bindings
        , "pkg_name"
        , "nodes"
        , "edges"
        , "pkg_graph"
        , "network_measures"
        , "graph_viz"
        , "layout_type"

        # Graph Reporter methods
        , "set_package"
        , "calculate_default_measures"
        , "get_summary_view"
        , "report_markdown_path"

        # FunctionReporter-specific
        # none
    )

    reporter <- pkgnet::FunctionReporter$new()
    expect_setequal(object = names(reporter)
                    , expected = publicInterfaceExpected)
})


### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('FunctionReporter works end-to-end for typical use', {

    testObj <- FunctionReporter$new()

    # inherited set_package works, with pkg_path
    expect_silent({
        testObj$set_package(
            pkg_name = "baseballstats"
            # Covr only works on source code. find.package path will not work
            # covr also requires an absolute path, which is provided by system.file
            , pkg_path = system.file("baseballstats"
                                     , package = "pkgnet"
                                     , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
            )
        )
    })

    # pkg_name works
    expect_equal(object = testObj$pkg_name
                 , expected = "baseballstats"
                 , info = "$pkg_name did not return expected package name")

    ## Node and Edge extraction work ##
    expect_silent({
        testObj$nodes
        testObj$edges
    })

    expect_true(data.table::is.data.table(testObj$nodes))
    expect_true(object = is.element("node", names(testObj$nodes))
                , info = "Node column created")

    expect_true(data.table::is.data.table(testObj$edges))
    expect_true(object = all(c("TARGET", "SOURCE") %in% names(testObj$edges))
                , info = "TARGET and SOURCE fields in edge table at minimum")


    ## pkg_graph works ##

    expect_silent({testObj$pkg_graph})
    expect_true({"AbstractGraph" %in% class(testObj$pkg_graph)})
    expect_true({"DirectedGraph" %in% class(testObj$pkg_graph)})
    expect_true({igraph::is_igraph(testObj$pkg_graph$igraph)})
    expect_setequal(
        object = igraph::get.vertex.attribute(testObj$pkg_graph$igraph)[['name']]
        , expected = testObj$nodes[, node]
    )
    expect_setequal(
        object = igraph::get.edgelist(testObj$pkg_graph$igraph)[,1]
        , expected = testObj$edges[, SOURCE]
    )
    expect_setequal(
        object = igraph::get.edgelist(testObj$pkg_graph$igraph)[,2]
        , expected = testObj$edges[, TARGET]
    )

    ## calculate_default_measures works ##

    expect_true({
        testObj$calculate_default_measures()
        TRUE
    })
    # Default node measures were generated
    expect_true({
        all(testObj$pkg_graph$default_node_measures %in% names(testObj$nodes))
    })
    # Default graph measures were generated
    expect_true({
        all(testObj$pkg_graph$default_graph_measures %in% names(testObj$network_measures))
    })

    # Coverage measures were generated
    expect_true(object = all( c("coverageRatio"
                                , "meanCoveragePerLine"
                                , "totalLines"
                                , "coveredLines"
                                , "filename")
                              %in% names(testObj$nodes))
        , info = "Not all expected function coverage measures are in nodes table"
    )

    ## graph_viz works ##
    expect_silent({testObj$graph_viz})
    expect_true(object = is.element("visNetwork", attributes(testObj$graph_viz)))
    expect_equivalent(
        object = as.data.table(testObj$graph_viz$x$nodes)[, .(id)]
        , expected = testObj$nodes[, .(id = node)]
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )
    expect_equivalent(
        object = as.data.table(testObj$graph_viz$x$edges)[, .(from, to)]
        , expected = testObj$edges[, .(from = SOURCE, to = TARGET)]
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )
})

test_that('FunctionReporter can directly generate pkg_graph', {
    testObj <- FunctionReporter$new()$set_package("baseballstats")
    expect_silent(testObj$pkg_graph)
    expect_true("AbstractGraph" %in% class(testObj$pkg_graph))
    expect_true(object = igraph::is_igraph(testObj$pkg_graph$igraph)
                , info = "Package graph did not successfuly generate igraph object")
})

test_that('FunctionReporter can directly generate graph_viz', {
    testObj <- FunctionReporter$new()$set_package("baseballstats")
    expect_silent({testObj$graph_viz})
    expect_true(object = is.element("visNetwork", attributes(testObj$graph_viz)))
})

test_that("FunctionReporter does not let you set_package twice", {
    expect_error({
        x <- FunctionReporter$new()
        x$set_package("baseballstats")
        x$set_package("baseballstats")
    }, regexp = "A package has already been set for this reporter")
})

test_that("FunctionReporter rejects bad packages with an informative error", {
    expect_error({
        testObj <- FunctionReporter$new()
        testObj$set_package(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find an installed package named 'w0uldNEverB33aPackageName'. Please install the package first.")
})

test_that("FunctionReporter rejects bad pkg_path with an informative error", {
    expect_error({
        x <- FunctionReporter$new()
        x$set_package(pkg_name = "baseballstats", pkg_path = "hopefully/not/a/real/path")
    }, regexp = "Package directory does not exist: hopefully/not/a/real/path")
})

test_that("set_package works with relative pkg_path",{
    # set_package works
    expect_silent({
        testObj <- FunctionReporter$new()

        # testing set_package with a pkg_path that is relative to the current directory
        entry_wd <- getwd()
        baseball_dir <- system.file(
            'baseballstats'
            , package='pkgnet'
            , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
        )
        parent_dir <- dirname(baseball_dir)
        setwd(parent_dir)

        testObj$set_package(
            pkg_name = "baseballstats"
            , pkg_path = 'baseballstats'
        )
        setwd(entry_wd)
    })

    # Sometimes with R CMD CHECK the temp dir begins /private/vars. Other times, just /vars.
    # Also, sometimes there are double slashes.
    fmtPath <- function(path){
        out <- gsub('^/private', '', path)
        out <- gsub('//', '/', out)
        out <- tools::file_path_as_absolute(out)
        return(out)
    }

    # Correct path
    expect_identical(
        object = fmtPath(testObj$.__enclos_env__$private$pkg_path)
        , expected = fmtPath(baseball_dir)
        , info = "set_package did not use the absolute path of the directory"
    )
})

test_that('FunctionReporter$report_markdown_path returns path to real file', {
    reporter <- FunctionReporter$new()
    expect_true(is.character(reporter$report_markdown_path))
    expect_true(file.exists(reporter$report_markdown_path))
})


### NETWORK EXTRACTION HELPER FUNCTIONS ###

test_that(".parse_function correctly parses expressions for symbols", {
    # Correctly parses body of function and finds all function symbols
    expect_true({
        myfunc <- function() {
            x <- innerfunc1()
            y <- innerfunc2()
            z <- innerfunc3(innerfunc4())
            2+2
        }
        result <- pkgnet:::.parse_function(body(myfunc))
        all(c("innerfunc1", "innerfunc2", "innerfunc3", "innerfunc4") %in% result)
    })
})

test_that(".parse_function correctly ignores right side of list extraction", {
    # Correctly keeps left side of $ but drops right side of $
    expect_true({
        result <- pkgnet:::.parse_function(quote(myfunc()$listitem))
        "myfunc" %in% result & !("listitem" %in% result)
    })
})

test_that(".parse_R6_expression correctly parses expressions for symbols", {
    # Correctly parses body of function and finds all function symbols
    expect_true({
        myr6method <- function() {
            x <- regularfunc1()
            z <- regularfunc2(regularfunc3())
            self$public_method()
            self$active_binding <- "new_value"
            private$private_method
            2+2
        }
        result <- pkgnet:::.parse_R6_expression(body(myr6method))
        all(c("regularfunc1", "regularfunc2", "regularfunc3", "self$public_method"
            , "self$active_binding", "private$private_method"
        ) %in% result)
    })
})

test_that(".parse_R6_expression correctly ignores right side of list extraction", {
    # Correctly keeps left side of $ but drops right side of $ for non-keywords
    expect_true({
        result <- pkgnet:::.parse_function(quote(myfunc()$listitem))
        "myfunc" %in% result & !("listitem" %in% result)
    })
})


##### TEST TEAR DOWN #####
rm(list = ls())
closeAllConnections()
