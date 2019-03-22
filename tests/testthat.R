# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory to pkgnet
# and then run devtools::test()

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")


#######  TESTING ON vs. OFF CRAN #############
# Due to complications on CRAN with handling of temporary packages during testing, TRAVIS
# and local testing will remain the main test processes for pkgnet.
# See https://github.com/UptakeOpenSource/pkgnet/issues/160 for details on this decision.

cat("testthat.R | NOT_CRAN =", Sys.getenv("NOT_CRAN"), "\n")
if(identical(Sys.getenv("NOT_CRAN"), "true")){
    ######## TRAVIS and LOCAL TEST PROCEDURE #############

    # Check if setup and helper funs have been run.
    # If in R CMD CHECK, they may not have been run yet.
    Sys.setenv(PKGNET_REBUILD = identical(Sys.getenv('PKGNET_TEST_LIB'), ''))

    # If not yet run, rebuild
    if (Sys.getenv('PKGNET_REBUILD')){
        library(pkgnet)
        ## ******************************************************************************************
        ## THIS IS THIS SAME CONTENT as setup_setTestEnv.R but neccessary to paste here due to
        ## travis checks.
        ## ******************************************************************************************

        # [DEBUG] write("PKGNET_REBUILD triggered", file = "~/thing.txt", append = TRUE)

        # record original libpaths in order to reset later.
        # This should be unnecessary since tests are conducted within a seperate enviornment.
        # It's done out of an abundance of caution.
        origLibPaths <- .libPaths()

        # Set the pkgnet library for testing to a temp directory
        Sys.setenv(PKGNET_TEST_LIB = tempdir())

        # Set the libpaths for testing.
        # This has no effect to global libpaths since testing tests are conducted within a
        # seperate enviornment.
        .libPaths(
            new = c(Sys.getenv('PKGNET_TEST_LIB'), origLibPaths)
        )

        # Install Fake Packages - For local testing if not already installed
        pkgnet:::.BuildTestLib(
            targetLibPath = Sys.getenv('PKGNET_TEST_LIB')
        )

        # [DEBUG] write(paste0("PKGNET_TEST_LIB: ", Sys.getenv('PKGNET_TEST_LIB')), file = "~/thing.txt", append = TRUE)
        # [DEBUG] write(list.files(Sys.getenv('PKGNET_TEST_LIB'), recursive = TRUE), file = "~/thing.txt", append = TRUE)


    }

    # This withr statement should be redundant.
    # This is within a test environment in which .libpaths() has been altered to include PKGNET_TEST_LIB.
    # Yet, it appears to be necessary.
    withr::with_libpaths(
        new =  .libPaths()
        , code = {testthat::test_check('pkgnet')}
    )

    # Tear down temporary test enviorment
    if (Sys.getenv('PKGNET_REBUILD')){

        ## ******************************************************************************************
        ## THIS IS THIS SAME CONTENT as teardown_setTestEnv.R but neccessary to paste here due to
        ## travis checks.
        ## ******************************************************************************************

        # [DEBUG] write("PKGNET_REBUILD tear-down triggered", file = "~/thing.txt", append = TRUE)

        # Uninstall Fake Packages From Test Library if Not Already Uninstalled
        try(
            utils::remove.packages(
                pkgs = c('baseballstats', 'sartre', 'milne', 'pkgnet')
                , lib = Sys.getenv('PKGNET_TEST_LIB')
            )
        )

        # Reset libpaths.
        # This should be unnecessary since tests are conducted within a seperate enviornment.
        # It's done out of an abundance of caution.
        .libPaths(origLibPaths)

        # Remove test libary path eviornment variable.
        Sys.unsetenv('PKGNET_TEST_LIB')
    }
} else {
    ######## ON CRAN TEST PROCEDURE #############
    testthat::test_check(package = "pkgnet"
                         , filter = "cran-true"
                         , load_helpers = FALSE
    )

}


