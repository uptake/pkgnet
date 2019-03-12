# Teardown temp test library with pkgnet test packages
# This should only run if NOT_CRAN env var is set to "true"
# devtools::test() will set it this way

cat("teardown-setTestEnv.R | NOT_CRAN =", Sys.getenv("NOT_CRAN"), "\n")
if(identical(Sys.getenv("NOT_CRAN"), "true")){
    # Uninstall Test Packages From Test Library if Not Already Uninstalled
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

    # Remove test libary path environment variable.
    Sys.unsetenv('PKGNET_TEST_LIB')
}
