

Sys.setenv(PKGNET_TEST_LIB = tempdir())
testLibPath <- Sys.getenv('PKGNET_TEST_LIB')

# Install Fake Packages - For local testing if not already installed
pkgnet:::.BuildTestLib(currentLibPath = .libPaths()[1]
                       , targetLibPath = testLibPath
                       )

