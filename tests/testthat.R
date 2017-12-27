# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

library(pkgnet)

# Install Fake Packages - For local testing if not already installed
devtools::install_local(system.file('baseballstats',package="pkgnet"),force=TRUE)
devtools::install_local(system.file('sartre',package="pkgnet"),force=TRUE)

testthat::test_check('pkgnet')

# Uninstall Fake Packages - For local testing 
devtools::uninstall(system.file('baseballstats',package="pkgnet"))
devtools::uninstall(system.file('sartre',package="pkgnet"))
