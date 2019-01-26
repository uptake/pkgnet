
print(Sys.getenv("NOT_CRAN"))
if(identical(Sys.getenv("NOT_CRAN"), "true")){
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

