context("FunctionReporter Expected Network Tests")
rm(list = ls())

##### RUN TESTS #####

for (testPkg in c('baseballstats', 'sartre', 'milne')) {
    test_that(sprintf('FunctionReporter extracts expected network for %s', testPkg), {

        testObj <- FunctionReporter$new()$set_package(testPkg)

        # Test nodes
        expect_equivalent(
            object = testObj$nodes
            , expected = data.table::fread(file.path(
                'testdata'
                , sprintf('%s_function_nodes.csv', testPkg)
                ))
            , ignore.col.order = TRUE
            , ignore.row.order = TRUE
        )

        # Test edges
        expect_equivalent(
            object = testObj$edges
            , expected = data.table::fread(
                file.path(
                    'testdata'
                    , sprintf('%s_function_edges.csv', testPkg)
                )
                , colClasses = c(SOURCE = "character", TARGET = "character")
            )
            , ignore.col.order = TRUE
            , ignore.row.order = TRUE
        )
    })
}

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
