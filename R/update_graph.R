
# [title] Add metadata to nodes in a package graph
# [name] .UpdateNodes
# [description] Given a pkgGraph object created by \code{\link[pkgnet]{ExtractNetwork}}
#              and a data.table of metadata, this function will append those metadata to
#              the internal object used to manage node properties
# [param] pkgGraph An object created by \code{\link[pkgnet]{ExtractNetwork}}
# [param] metadataDT A data.table with node metadata. This table must have a 'node'
#                   column with the names of nodes (e.g. function names) to be updated.
# [examples]
#
# library(pkgnet)
# nw <- ExtractNetwork("ggplot2")
# 
# # Add random stuff
# coverageDT <- data.table(node = c('log.warn', 'GetAPIInfo'), coverage = c(95, 100))
# newNW <- pkgnet:::.UpdateNodes(nw, coverageDT)
#' @importFrom futile.logger flog.fatal
.UpdateNodes <- function(pkgGraph, metadataDT){
   
    # Input checks
    if (!'nodes' %in% names(pkgGraph)){
        msg <- paste0("Did you generate pkgGraph with ExtractNetwork? ",
                      "It should be a list with a 'nodes' element.")
        futile.logger::flog.fatal(msg)
        stop(msg)    
    }
    if (!'data.table' %in% class(pkgGraph[['nodes']])){
        msg <- "the object in the 'nodes' element of pkgGraph should be a data.table!"
        futile.logger::flog.fatal(msg)
        stop(msg)
    }
    if (!'data.table' %in% class(metadataDT)){
        msg <- "the object passed to metadataDT should be a data.table!"
        futile.logger::flog.fatal()
        stop(msg)
    }
    if (!'node' %in% names(metadataDT)){
        msg <- "metadataDT should have a column called 'node'"
        futile.logger::flog.fatal(msg)
        stop(msg)
    }
    
    # Append metadata
    pkgGraph[['nodes']] <- merge(pkgGraph[['nodes']]
                                     , metadataDT
                                     , all.x = TRUE
                                     , all.y = FALSE
                                     , by = 'node')
    
    return(pkgGraph)
    
}

# [title] Add network measures in a package graph
# [name] .UpdateNetworkMeasures
# [description] Given a pkgGraph object created by \code{\link[pkgnet]{ExtractNetwork}}
#              and a list of network measures, this function will append the network measures to
#              the internal network measures object if it is a new measure.  Otherwise, it will 
#              replace an existing network measure with a new value.
#  [param] pkgGraph An object created by \code{\link[pkgnet]{ExtractNetwork}}
# [param] networkMeasureList A list with network measures.
# [examples]
#
# library(pkgnet)
# nw <- ExtractNetwork("ggplot2")
# 
# # Add random stuff
# newNetworkMeasure <- list(awesomness = 11)
# newNW <- pkgnet:::.UpdateNetworkMeasures(nw, newNetworkMeasure)
#' @importFrom futile.logger flog.fatal
.UpdateNetworkMeasures <- function(pkgGraph, networkMeasureList){
  
  # Input checks
  if (!'nodes' %in% names(pkgGraph)){
    msg <- paste0("Did you generate pkgGraph with ExtractNetwork? ",
                  "It should be a list with a 'nodes' element.")
    futile.logger::flog.fatal(msg)
    stop(msg)    
  }
  if (!'data.table' %in% class(pkgGraph[['nodes']])){
    msg <- "the object in the 'nodes' element of pkgGraph should be a data.table!"
    futile.logger::flog.fatal(msg)
    stop(msg)
  }
  if (!'list' %in% class(networkMeasureList)){
    msg <- "the object passed to networkMeasureList should be a list!"
    futile.logger::flog.fatal(msg)
    stop(msg)
  }

  # replace Value is exists already. otherwise append
  currentNames <- names(pkgGraph[['networkMeasures']])
  newNames <- names(networkMeasureList)
  existingIX <- match(x = newNames, table = currentNames)
  r <- 0
  for(i in existingIX){
    r <- r + 1
    if(is.na(i)) {
      #append
      pkgGraph[['networkMeasures']] <- c(pkgGraph[['networkMeasures']], networkMeasureList[r])
    } else {
      #replace
      pkgGraph[['networkMeasures']][i] <- networkMeasureList[r]
    }
  }
  
  return(pkgGraph)
  
}
