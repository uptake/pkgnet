context("InheritanceReporter Expected Network Tests")

##### TESTS #####

test_that('InheritanceReporter extracts expected network for milne', {

    testObj <- InheritanceReporter$new()$set_package('milne')

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
})
