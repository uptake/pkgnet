# Note that you would never run this file directly. This is used by tools::testInstallPackages()
# and other packages like covr.
# To actually run the tests, you need to set the working directory then run
# devtools::test('pkgnet')

# This line ensures that R CMD check can run tests.
# See https://github.com/hadley/testthat/issues/144
Sys.setenv("R_TESTS" = "")

library(pkgnet)

#### INSTALL TEST PACKAGES ####

# DUE TO CRAN POLICY, ALL PACKAGES HERE MUST BE INSTALLED INTO TEMP DIRECTORY

tempLib <- tempdir()

# Install Baseball Stats
install.packages(pkgs = system.file('baseballstats',package="pkgnet")
                 , lib = tempLib
                 , repos = NULL
                 , type = "all"
)

# Install Dependencies Too
# Since they are all base R packages, let's just copy the currently installed ones
depPaths <- sapply(c('base', 'methods', 'utils'), find.package)
install.packages(pkgs = depPaths
                 , lib = tempLib
                 , repos = NULL
                 , type = "all")

library(baseballstats, lib.loc = tempLib)

# Install sartre
install.packages(pkgs = system.file('sartre',package="pkgnet")
                 , lib = tempLib
                 , repos = NULL
                 , type = "all"
)

# sartre has no dependencies

library(sartre, lib.loc = tempLib)


#### TEST PKGNET #### 

testthat::test_check('pkgnet')

#### REMOVE TEST PAKCAGES #### 

remove.packages(pkgs = c('sartre'
                         , 'baseballstats'
                         , 'base'
                         , 'methods'
                         , 'utils')
                , lib =  tempLib)
