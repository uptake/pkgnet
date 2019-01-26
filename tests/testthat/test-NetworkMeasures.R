context("Correctness of Network Measures")

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

expectedNodeLevelMeasures <- c("outDegree"
                             , "outBetweeness"
                             , "outCloseness"
                             , "outSubgraphSize"
                             , "inSubgraphSize"
                             , "hubScore"
                             , "pageRank"
                             , "inDegree")

extDepNetwork <- t$DependencyReporter$network_measures
intFuncNetwork <- t$FunctionReporter$network_measures
inheritenceNetwork <- t2$InheritanceReporter$network_measures

expectedNetworkLevelMeasures <- c("centralization.OutDegree"
                                  , "centralization.betweenness"
                                  , "centralization.closeness"
                                  )

# note, does not test order
test_that('All expected Node Level Network Measures are calculated', {
    
    # External Package Dependencies
    expect_true(object = all(expectedNodeLevelMeasures %in% names(extDepNodes))
                , info = 'Network Measures for external package dependencies'
                )
    
    # Internal Function Dependencies
    expect_true(object = all(expectedNodeLevelMeasures %in% names(intFuncNodes))
                , info = 'Network Measures for internal function dependencies'
    )
    
    # Object Inheritance Network
    expect_true(object = all(expectedNodeLevelMeasures %in% names(inheritenceNodes))
                , info = 'Network Measures for internal function dependencies'
    )
})

test_that('All expected Network Level Network Measures are calculated', {
    
    # External Package Dependencies
    expect_true(object = all(expectedNetworkLevelMeasures %in% names(extDepNetwork))
                , info = 'Network Measures for external package dependencies'
    )
    
    # Internal Function Dependencies
    expect_true(object = all(expectedNetworkLevelMeasures %in% names(intFuncNetwork))
                , info = 'Network Measures for internal function dependencies'
    )
    
    # Object Inheritance Network
    expect_true(object = all(expectedNetworkLevelMeasures %in% names(inheritenceNetwork))
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




##################################
##### Network Level Measures ##### 
##################################

test_that('External Package Dependencies Network Level Measures', {
    
    # centralization.OutDegree
    expect_equal(object = round(extDepNetwork[['centralization.OutDegree']], 7)
                 , 0.2857143)
    
    # centralization.betweenness
    expect_equal(object = round(extDepNetwork[['centralization.betweenness']], 7)
                 , 0.1166667)
    
    # outCloseness
    expect_equal(object = round(extDepNetwork[['centralization.closeness']], 7)
                 , 0.4136785)
    
})

####  Internal Function Dependencies ####

test_that('Internal Function Dependencies Network Level Measures', {
    
    # centralization.OutDegree
    expect_equal(object = round(intFuncNetwork[['centralization.OutDegree']], 7)
                 , 0.3)
    
    # centralization.betweenness
    expect_equal(object = round(intFuncNetwork[['centralization.betweenness']], 7)
                 , 0.03125)
    
    # outCloseness
    expect_equal(object = round(intFuncNetwork[['centralization.closeness']], 7)
                 , 0.2743056)
    
})

#### Object Inheritance Network ####

test_that('Object Inheritance Network Level Measures', {
    
    # centralization.OutDegree
    expect_equal(object = round(inheritenceNetwork[['centralization.OutDegree']], 7)
                 , 0.0934066)
    
    # centralization.betweenness
    expect_equal(object = round(inheritenceNetwork[['centralization.betweenness']], 7)
                 , 0.0305720)
    
    # outCloseness
    expect_equal(object = round(inheritenceNetwork[['centralization.closeness']], 7)
                 , 0.0245179)
    
})

##### TEST TEAR DOWN #####

futile.logger::flog.threshold(origLogThreshold)
rm(list = ls())
closeAllConnections()
