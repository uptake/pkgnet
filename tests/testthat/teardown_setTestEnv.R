

# Uninstall Fake Packages - For local testing
utils::remove.packages(pkgs = c('baseballstats'
                                , 'sartre'
                                , 'pkgnet'
)
, lib = Sys.getenv('PKGNET_TEST_LIB')
)

.libPaths(origLibPaths)
Sys.unsetenv('PKGNET_TEST_LIB')