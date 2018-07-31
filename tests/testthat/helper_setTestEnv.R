

# Get test library path
testLibPath <- Sys.getenv('PKGNET_TEST_LIB')

# Get current library paths
origLibPaths <- .libPaths()

# Create new library paths for TESTING
.libPaths(new = c(testLibPath, origLibPaths))

log_info(paste0("Running test with these libpaths: "
                , paste(.libPaths(), collapse = ",")
                )
         )

# Since this is within load_all within devtools::test, 
# it should not effect default .libpaths in the global enviornment


