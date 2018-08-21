# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

# Check if setup and helper funs have been run.  
# If in R CMD CHECK, they may not have been run yet.   
Sys.setenv(PKGNET_REBUILD = identical(Sys.getenv('PKGNET_TEST_LIB'), ''))

# If not yet run, rebuild

if(Sys.getenv('PKGNET_REBUILD')){
    library(pkgnet)
    ## ******************************************************************************************
    ## THIS IS THIS SAME CONTENT as setup_setTestEnv.R but neccessary to paste here due to 
    ## travis checks.
    ## ******************************************************************************************
    
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
    
}

# This withr statement should be redundant.
# This is within a test enviornment in which .libpaths() has been altered to include PKGNET_TEST_LIB. 
# Yet, it appears to be necessary. 
withr::with_libpaths(new =  .libPaths()
                     , code = {
                         testthat::test_check('pkgnet')
                     })

# Tear down temporary test enviorment
if(Sys.getenv('PKGNET_REBUILD')){
    ## ******************************************************************************************
    ## THIS IS THIS SAME CONTENT as teardown_setTestEnv.R but neccessary to paste here due to 
    ## travis checks.
    ## ******************************************************************************************
    
    
    # Uninstall Fake Packages From Test Library if Not Already Uninstalled
    try(
        utils::remove.packages(pkgs = c('baseballstats'
                                        , 'sartre'
                                        , 'pkgnet'
        )
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
