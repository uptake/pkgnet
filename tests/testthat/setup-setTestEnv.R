# Setup temp test library with pkgnet test packages
# This should only run if NOT_CRAN env var is set to "true"
# devtools::test() will set it this way

cat("setup-setTestEnv.R | NOT_CRAN =", Sys.getenv("NOT_CRAN"), "\n")
if(identical(Sys.getenv("NOT_CRAN"), "true")){
    ######## TRAVIS and LOCAL TEST PROCEDURE #############

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

}

