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
    source(path.expand(file.path('./testthat/setup_setTestEnv.R')))
    source(path.expand(file.path('./testthat/helper_setTestEnv.R')))
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
    source(path.expand(file.path('./testthat/teardown_setTestEnv.R')))
}
