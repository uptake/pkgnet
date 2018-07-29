
testLibPath <- Sys.getenv('PKGNET_TEST_LIB')

# Uninstall Fake Packages - For local testing 
utils::remove.packages(pkgs = c('baseballstats'
                                , 'sartre'
                                , 'pkgnet'
)
, lib = testLibPath
)

.libPaths(origLibPaths)
Sys.unsetenv('PKGNET_TEST_LIB')