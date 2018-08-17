
# record original libpaths in order to reset later.  
# This should be unnecessary since tests are conducted within a seperate enviornment. 
# It's done out of an abundance of caution. 
origLibPaths <- .libPaths()

# Set the pkgnet library for testing to a temp directory
Sys.setenv(PKGNET_TEST_LIB = tempdir())

# Set the libpaths for testing. 
# This has no effect to global libpaths since testing tests are conducted within a seperate enviornment. 
.libPaths(new = c(Sys.getenv('PKGNET_TEST_LIB')
                  , origLibPaths)
          )

# Install Fake Packages - For local testing if not already installed
pkgnet:::.BuildTestLib(currentLibPaths = origLibPaths
                       , targetLibPath = Sys.getenv('PKGNET_TEST_LIB')
                       )

