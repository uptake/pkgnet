# Check if the setup in testthat.R was already run
# [DEBUG] write("setup_setTestEnv.R triggered", file = "~/thing.txt", append = TRUE)

# record original libpaths in order to reset later.
# This should be unnecessary since tests are conducted within a seperate enviornment.
# It's done out of an abundance of caution.
origLibPaths <- .libPaths()

# Set the pkgnet library for testing to a temp directory
Sys.setenv(PKGNET_TEST_LIB = tempdir())

# Set the libpaths for testing.
# This has no effect to global libpaths since testing tests are conducted within a seperate enviornment.
.libPaths(new = c(
    Sys.getenv('PKGNET_TEST_LIB')
    , origLibPaths
))

# Install Fake Packages - For local testing if not already installed
pkgnet:::.BuildTestLib(
    targetLibPath = Sys.getenv('PKGNET_TEST_LIB')
)

# [DEBUG] write(paste0("PKGNET_TEST_LIB: ", Sys.getenv('PKGNET_TEST_LIB')), file = "~/thing.txt", append = TRUE)
# [DEBUG] write(list.files(Sys.getenv('PKGNET_TEST_LIB'), recursive = TRUE), file = "~/thing.txt", append = TRUE)

