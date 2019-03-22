context("DependencyReporter Expected Network Tests")

##### TESTS #####

test_that('DependencyReporter extracts expected network for baseballstats', {

    testObj <- DependencyReporter$new()$set_package('baseballstats')

    # Test nodes
    expect_equivalent(
        object = testObj$nodes
        , expected = data.table::fread(file.path('testdata', 'baseballstats_dependency_nodes.csv'))
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )

    # Test edges
    expect_equivalent(
        object = testObj$edges
        , expected = data.table::fread(file.path('testdata', 'baseballstats_dependency_edges.csv'))
        , ignore.col.order = TRUE
        , ignore.row.order = TRUE
    )
})

