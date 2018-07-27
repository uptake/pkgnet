# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

testLibPath <- tempdir()
#testEnv <- new.env()



# Install Fake Packages - For local testing if not already installed
utils::install.packages(pkgs = system.file('baseballstats'
                                           , package = "pkgnet"
                                           )
                        , lib = testLibPath
                        , repos = NULL
                        , type = "source"
                        , INSTALL_opts = c('--install-tests')
                        )

utils::install.packages(pkgs = system.file('sartre'
                                           , package = "pkgnet"
                                           )
                        , lib = testLibPath
                        , repos = NULL
                        , type = "source"
                        , INSTALL_opts = c('--install-tests')
)

utils::install.packages(pkgs = find.package(package = 'pkgnet'
                                            , lib.loc = .libPaths()
                                            )
, lib = testLibPath
, repos = NULL
, type = "source"
, INSTALL_opts = c('--install-tests')
)

# 
# depList <- devtools::dev_package_deps(pkg = find.package(package = 'pkgnet'
#                                               , lib.loc = .libPaths()
#                                               )
#                                       , dependencies = TRUE
#                                       , repos = NULL
#                            )
# 
# depListPaths <- sapply(depList[['package']]
#                        , find.package
#                        )
# 
# utils::install.packages(pkgs = depListPaths
#                         , lib = testLibPath
#                         , repos = NULL
#                         , type = 'source'
# )  


withr::with_libpaths(new = c(testLibPath, .libPaths())
                     #, code = test_check('pkgnet')
                     , code = testthat::test_dir(path = file.path(find.package(package = "pkgnet"
                                                                               , lib.loc = testLibPath)
                                                                  , "tests"
                                                                  , "testthat")
                                                 )
                     )


# Uninstall Fake Packages - For local testing 
utils::remove.packages(pkgs = c('baseballstats'
                                , 'sartre'
                                , 'pkgnet'
                                )
                       , lib = testLibPath
                       )
