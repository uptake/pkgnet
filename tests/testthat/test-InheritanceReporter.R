context("Package Class Inheritance Reporter Tests")

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
    origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
    origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### TESTS #####

## Structure Available ##

test_that('InheritanceReporter structure is as expected', {

    expect_named(object = InheritanceReporter$public_methods
                 , expected = c(
                     "get_summary_view",
                     "clone"
                 )
                 , info = "Available public methods for InheritanceReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )

    expect_named(object = InheritanceReporter$public_fields
                 , expected = NULL
                 , info = "Available public fields for InheritanceReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )

})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS

test_that('InheritanceReporter Methods Work', {
    testObj <- InheritanceReporter$new()

    # inherited set_package
    expect_silent({

        # testing set_package with a pkg_path that is relative to the current directory
        entry_wd <- getwd()
        milne_dir <- system.file(
            'milne'
            , package='pkgnet'
            , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
        )
        parent_dir <- dirname(milne_dir)
        setwd(parent_dir)

        testObj$set_package(
            pkg_name = "milne"
            , pkg_path = 'milne'
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

    expect_identical(
        object = fmtPath(testObj$.__enclos_env__$private$pkg_path)
        , expected = fmtPath(milne_dir)
        , info = "set_package did not use the absolute path of the directory"
    )

    # Network extraction
    expect_silent({
        testObj$pkg_graph
    })

    expect_named(
        object = testObj$edges
        , expected = c("SOURCE", "TARGET")
        , info = "more than edges created by extract_network"
        , ignore.order = FALSE # enforcing this convention
        , ignore.case = FALSE
    )

    # Test nodes
    expect_equivalent(
        object = testObj$nodes
        , expected = data.table::fread(file.path('testdata', 'milne_inheritance_nodes.csv'))
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )

    # Test edges
    expect_equivalent(
        object = testObj$edges
        , expected = data.table::fread(file.path('testdata', 'milne_inheritance_edges.csv'))
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )

    expect_silent({
        testObj$pkg_graph
    })

    expect_true({
        igraph::is_igraph(testObj$pkg_graph)
    }, info = "Graph object not an igraph formatted object")

    expect_true({
        all(igraph::get.vertex.attribute(testObj$pkg_graph)[[1]] %in% testObj$nodes[, node])
    }, info = "Graph nodes not as expected")

    expect_true({
        all(igraph::get.vertex.attribute(testObj$pkg_graph)[[1]] %in% igraph::get.vertex.attribute(testObj$pkg_graph)[[1]])
    }, info = "$pkg_graph field nodes not as expected")

    expect_identical(
        igraph::get.edgelist(testObj$pkg_graph)
        , expected = igraph::get.edgelist(testObj$pkg_graph)
        , info = "$pkg_graph field edges not as expected"
    )
})


test_that("InheritanceReporter rejects bad packages with an informative error", {
    expect_error({
        reporter <- InheritanceReporter$new()
        reporter$set_package(
            pkg_name = "w0uldNEverB33aPackageName"
        )
    }, regexp = "pkgnet could not find a package called 'w0uldNEverB33aPackageName'")
})


test_that("InheritanceReporter should give warning for packages with no classes", {
    expect_warning({
        reporter <- InheritanceReporter$new()
        reporter$set_package("baseballstats")
        reporter$edges
    }, regexp = "No S4, Reference, or R6 class definitions found")
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
