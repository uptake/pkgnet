# Packages we get the entire namespace of
#' @import data.table

# Annoying stuff to trick R CMD check
globalVariables(c('.'
                  ,'.N'
                  ,'edgesALL'
                  ,'filename'
                  ,'from'
                  ,'functions'
                  ,'horizontal'
                  ,'id'
                  ,'label'
                  ,'level'
                  ,'node'
                  ,'numDescendants'
                  ,'outDegree'
                  ,'SOURCE'
                  ,'TARGET'
                  ,'test_coverage'
                  ,'to'
                  ,'value'
                  ,'x'
                  ,'xend'
                  ,'y'
                  ,'yend'
                  , 'CLASS_NAME'
                  , 'MATCH'
                  , 'METHOD_NAME'
                  , 'METHOD_TYPE'
                  , 'PARENT_IN_PKG'
                  , 'PARENT_NAME'
                  , 'SYMBOL'
                  ))

# NULL object for common parameter documentation
#' @param pkg_name (string) name of a package
#' @param pkg_path (string) The path to the package repository. If given, coverage
#'                 will be calculated for each function. \code{pkg_path} can be an
#'                 absolute or relative path.
#' @name doc_shared
#' @title NULL Object For Common Documentation
#' @description This is a NULL object with documentation so that later functions can call
#' inheritParams
NULL

