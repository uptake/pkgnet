context("Network Measures on Baseballstats")

##### TEST SET UP #####

rm(list = ls())
# Configure logger (suppress all logs in testing)
# expect_silents only work with this logger turned off; only alerts with warnings
loggerOptions <- futile.logger::logger.options()
if (!identical(loggerOptions, list())){
    origLogThreshold <- loggerOptions[[1]][['threshold']]
} else {
    origLogThreshold <- futile.logger::INFO
}
futile.logger::flog.threshold(0)

##### TESTS #####

###############################
##### Node Level Measures ##### 
###############################

# Get Networks
t <- CreatePackageReport("baseballstats")
extDepNodes <- t$DependencyReporter$nodes
intFuncNodes <- t$FunctionReporter$nodes

t2 <- CreatePackageReport("milne"
                          , pkg_reporters = c(DefaultReporters(), InheritanceReporter$new()
                                              )
                          )
inheritenceNodes <- t2$InheritanceReporter$nodes

expectedNetworkMeasures <- c("outDegree"
                             , "outBetweeness"
                             , "outCloseness"
                             , "outSubgraphSize"
                             , "inSubgraphSize"
                             , "hubScore"
                             , "pageRank"
                             , "inDegree")

# note, does not test order
test_that('All expected Network Measures are calculated', {
    
    # External Package Dependencies
    expect_true(object = all(expectedNetworkMeasures %in% names(extDepNodes))
                , info = 'Network Measures for external package dependencies'
                )
    
    # Internal Function Dependencies
    expect_true(object = all(expectedNetworkMeasures %in% names(intFuncNodes))
                , info = 'Network Measures for internal function dependencies'
    )
    
    # Object Inheritance Network
    expect_true(object = all(expectedNetworkMeasures %in% names(inheritenceNodes))
                , info = 'Network Measures for internal function dependencies'
    )
})


###### External Package Dependencies ######

test_that('External Package Dependencies Network Measures (stat package)', {
    
    measureValues <- extDepNodes[node == 'stats']
    
    # outDegree
    expect_equal(object = measureValues[['outDegree']], 3)
    
    # outBetweeness
    expect_equal(object = measureValues[['outBetweeness']], 4)
    
    # outCloseness
    expect_equal(object = measureValues[['outCloseness']], 0.25)
    
    # outSubgraphSize
    expect_equal(object = measureValues[['outSubgraphSize']], 4)
    
    # inSubgraphSize
    expect_equal(object = measureValues[['inSubgraphSize']], 3)
    
    # hubScore
    expect_equal(object = measureValues[['hubScore']], 1)
    
    # pageRank
    expect_equal(object = round(measureValues[['pageRank']], 7) , 0.1346578)
    
    # inDegree
    expect_equal(object = measureValues[['inDegree']], 1)
    
})

####  Internal Function Dependencies ####

test_that('Internal Function Dependencies Network Measures (stat package)', {
    
    measureValues <- intFuncNodes[node == 'slugging_avg']
    
    # outDegree
    expect_equal(object = measureValues[['outDegree']], 1)
    
    # outBetweeness
    expect_equal(object = measureValues[['outBetweeness']], 0.5)
    
    # outCloseness
    expect_equal(object = measureValues[['outCloseness']], 0.25)
    
    # outSubgraphSize
    expect_equal(object = measureValues[['outSubgraphSize']], 2)
    
    # inSubgraphSize
    expect_equal(object = measureValues[['inSubgraphSize']], 2)
    
    # hubScore
    expect_equal(object = measureValues[['hubScore']], 1)
    
    # pageRank
    expect_equal(object = round(measureValues[['pageRank']], 7) , 0.1722575)
    
    # inDegree
    expect_equal(object = measureValues[['inDegree']], 1)
    
})

#### Object Inheritance Network ####

test_that('Object Inheritance Network Measures (stat package)', {
    
    measureValues <- inheritenceNodes[node == 'KingOfTheEarth']
    
    # outDegree
    expect_equal(object = measureValues[['outDegree']], 2)
    
    # outBetweeness
    expect_equal(object = measureValues[['outBetweeness']], 2)
    
    # outCloseness
    expect_equal(object = round(measureValues[['outCloseness']], 8), 0.08333333)
    
    # outSubgraphSize
    expect_equal(object = measureValues[['outSubgraphSize']], 3)
    
    # inSubgraphSize
    expect_equal(object = measureValues[['inSubgraphSize']], 2)
    
    # hubScore
    expect_equal(object = measureValues[['hubScore']], 0)
    
    # pageRank
    expect_equal(object = round(measureValues[['pageRank']], 8), 0.06470207)
    
    # inDegree
    expect_equal(object = measureValues[['inDegree']], 1)
    
})


##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
