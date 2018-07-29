

Sys.setenv(PKGNET_TEST_LIB = tempdir())
testLibPath <- Sys.getenv('PKGNET_TEST_LIB')

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
                                            , lib.loc = origLibPaths[1]
)
, lib = testLibPath
, repos = NULL
, type = "source"
, INSTALL_opts = c('--install-tests')
)

