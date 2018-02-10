context("Abstract Graph Reporter Tests")

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

test_that('AbstractGraphReporter structure is as expected', {
    
    expect_named(object = AbstractGraphReporter$public_methods
                 , expected = c(
                     "make_graph_object",
                     "calculate_network_measures",
                     "plot_network",
                     "set_plot_node_color_scheme",
                     "get_plot_node_color_scheme",
                     "clone"
                 )
                 , info = "Available public methods for AbstractGraphReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )
    
    expect_named(object = AbstractGraphReporter$public_fields
                 , expected = NULL
                 , info = "Available public fields for AbstractGraphReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )
    
    expect_named(object = AbstractGraphReporter$private_methods
                 , expected = c('calculate_graph_layout'
                                , 'identify_orphan_nodes'
                                , 'parse_extract_args'
                                , 'reset_graph_viz'
                                , 'update_nodes'
                                )
                 , info = "Available private methods for AbstractGraphReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )
    
    expect_named(object = AbstractGraphReporter$private_fields
                 , expected = c('cache'
                                , 'defaultCache'
                                , 'graph_layout_functions'
                                , 'plotNodeColorScheme'
                                , 'reporterCache'
                                )
                 , info = "Available private fields for AbstractGraphReporter not as expected."
                 , ignore.order = TRUE
                 , ignore.case = FALSE
    )
    
})

### USAGE OF PUBLIC AND PRIVATE METHODS AND FIELDS TO BE TESTED BY CHILD OBJECTS

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()