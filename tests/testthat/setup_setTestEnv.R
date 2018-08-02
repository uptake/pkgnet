
origLibPaths <- .libPaths()
Sys.setenv(PKGNET_TEST_LIB = tempdir())

# Set libpaths for testing
.libPaths(new = c(Sys.getenv('PKGNET_TEST_LIB')
                  , origLibPaths)
          )

# Install Fake Packages - For local testing if not already installed
pkgnet:::.BuildTestLib(currentLibPath = origLibPaths[1]
                       , targetLibPath = Sys.getenv('PKGNET_TEST_LIB')
                       )

