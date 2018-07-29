


testLibPath <- Sys.getenv('PKGNET_TEST_LIB')
origLibPaths <- .libPaths()
.libPaths(new = c(testLibPath, origLibPaths))

print(.libPaths())

# # This should overwrite .GetLibPaths()
# .GetLibPaths <- function(){
#     return(c(testLibPath
#              , .libPaths()))
# }
