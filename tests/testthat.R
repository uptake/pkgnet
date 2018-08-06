# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

# Check if setup and helper funs have been run
Sys.setenv(PKGNET_REBUID = identical(Sys.getenv('PKGNET_TEST_LIB'), ''))

# If not yet run, rebuild
print(getwd())

if(Sys.getenv('PKGNET_REBUID')){
    library(pkgnet)
    source('./testthat/setup_setTestEnv.R')
    source('./testthat/helper_setTestEnv.R')
}

print(Sys.getenv('PKGNET_TEST_LIB'))
print(list.files(path = file.path(Sys.getenv('PKGNET_TEST_LIB'), 'pkgnet')
                 , pattern = 'test'
                 , full.names = TRUE
                 , recursive = TRUE
                 )
      )

testthat::test_dir(path = file.path(find.package(package = "pkgnet"
                                                 , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
                                                 )
                                    , "tests"
                                    , "testthat"
                                    )
                   )

#testthat::test_check('pkgnet')

# burn it down
if(Sys.getenv('PKGNET_REBUID')){
    source('./testthat/teardown_setTestEnv.R')
}
