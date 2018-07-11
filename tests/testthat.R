# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

testLibPath <- tempdir()
#testEnv <- new.env()

# testthat::with_mock(`.GetLibPaths` = function() {return(testLibPath)}
#                     , .env = testEnv)



# library(pkgnet)
# `pkgnet::.GetLibPaths` <- function() {returns(testLibPath)}

# Install Fake Packages - For local testing if not already installed
utils::install.packages(pkgs = system.file('baseballstats'
                                           , package = "pkgnet"
                                           )
                        , lib = testLibPath
                        , repos = NULL
                        , type = "source"
                        )

utils::install.packages(pkgs = system.file('sartre'
                                           , package = "pkgnet"
                                           )
                        , lib = testLibPath
                        , repos = NULL
                        , type = "source"
)

utils::install.packages(pkgs = find.package(package = 'pkgnet'
                                            , lib.loc = .libPaths()
                                            )
, lib = testLibPath
, repos = NULL
, type = "source"
, INSTALL_opts = c('--install-tests')
)

tmp <- tempfile()
strCommand <- sprintf(paste0("library('pkgnet', lib.loc = '%s');"
                             , "`pkgnet::.GetLibPaths` <- function(){return('%s')};"
                             , "`.GetLibPaths` <- function(){return('%s')};"
                             )
                      , testLibPath
                      , testLibPath
                      , testLibPath)
writeLines(strCommand, tmp)
testEnv <- attach(NULL, name = "testEnv")
source(file = tmp
       , local = testEnv)



testthat::test_dir(path = file.path(find.package(package = "pkgnet"
                                                 , lib.loc = testLibPath)
                                    , "tests"
                                    , "testthat")
                   , env = testEnv)


# 
# testthat::with_mock(`pkgnet::.GetLibPaths` = function() {return(c(testLibPath))}
#                     , `.GetLibPaths` = function() {return(c(testLibPath))}
#                     , {
#                         # library('pkgnet'
#                         #         , lib.loc = .GetLibPaths()
#                         #         )
#                         log_info(paste0(".GetLibPaths: ", .GetLibPaths()))
#                         testthat::test_check('pkgnet')
#                     }
#                     )

# Uninstall Fake Packages - For local testing 
utils::remove.packages(pkgs = c('baseballstats'
                                , 'sartre'
                                , 'pkgnet')
                       , lib = testLibPath
                       )
