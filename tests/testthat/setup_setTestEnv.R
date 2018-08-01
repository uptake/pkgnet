

Sys.setenv(PKGNET_TEST_LIB = tempdir())

# Install Fake Packages - For local testing if not already installed
pkgnet:::.BuildTestLib(currentLibPath = origLibPaths[1]
                       , targetLibPath = Sys.getenv('PKGNET_TEST_LIB')
                       )

