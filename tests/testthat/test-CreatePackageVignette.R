context("CreatePackageVignette Tests")
rm(list = ls())

##### TESTS #####

# baseballstats source path
pkgPath <- system.file("baseballstats"
                       , package = "pkgnet"
                       , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
            )

test_that("Test that CreatePackageVignette runs end-to-end", {

    vignettePath <- tempfile(pattern = "vignette", fileext = ".Rmd")
    outputPath <- tempfile(pattern = "vignette", fileext = ".html")

    expect_true({
        CreatePackageVignette(pkg_name = "baseballstats"
                              , vignette_path = vignettePath
                             )
        TRUE
    })

    # Valid Rmd file was produced successfully
    expect_true(file.exists(vignettePath))
    expect_true(file.info(vignettePath)[["size"]] > 0)
    expect_true({
        rmarkdown::render(
            input = vignettePath
            , output_file = basename(outputPath)
            , output_dir = dirname(outputPath)
            , quiet = TRUE
        )
        TRUE
    })
    expect_true(file.exists(outputPath))
    expect_true(file.info(outputPath)[["size"]] > 0)
})

test_that("Test that CreatePackageVignette errors for bad inputs", {

    vignettePath <- tempfile(pattern = "vignette", fileext = ".Rmd")

    # Non-existent vignette_path directory
    expect_error(
        CreatePackageVignette(
            pkg_name = "baseballstats"
            , vignette_path = file.path(
                dirname(vignettePath)
                , 'notarealdir'
                , basename(vignettePath)
            )
        )
        , regexp = paste(
            "Directory"
            , file.path(dirname(vignettePath), 'notarealdir')
            , "does not exist, please create it before running"
            , "CreatePackageVignette"
        )
        , fixed = TRUE
    )

    # Generator passed into pkg_reporters
    expect_error(
        CreatePackageVignette(pkg_name = "baseballstats"
                              , vignette_path = vignettePath
                              , pkg_reporters = list(DependencyReporter$new()
                                                     , FunctionReporter)
        )
        , regexp = paste("At least one of pkg_reporters is an R6 class"
                         , "generator. This function expects initialized"
                         , "reporter objects.")
        , fixed = TRUE
    )
})

test_that("CreatePackageVignette warns if vignette_path seems wrong", {
    # In a vignettes directory that isn't in a package root
    vignettesDir <- file.path(tempdir(), "vignettes")
    dir.create(vignettesDir)
    expect_warning(
        CreatePackageVignette(pkg_name = "baseballstats"
                              , vignette_path = file.path(vignettesDir
                                                          , "pkgnet_report.Rmd")
        )
        , regexp = paste("not inside a package root directory")
        , fixed = TRUE
    )
    # Clean up
    unlink(file.path(tempdir(), "vignettes"), recursive = TRUE)

    # If in root of a different package
    suppressWarnings({
        utils::package.skeleton(name = "basketballstats", path = tempdir())
    })
    dir.create(file.path(tempdir(), "basketballstats", "vignettes"))
    expect_warning(
        CreatePackageVignette(pkg_name = "baseballstats"
                              , vignette_path = file.path(tempdir()
                                                          , "basketballstats"
                                                          , "vignettes"
                                                          , "pkgnet_report.Rmd")
        )
        , regexp = paste("You are writing a report for baseballstats to the"
                         , "vignettes directory for basketballstats")
        , fixed = TRUE
    )
    # Clean up
    unlink(file.path(tempdir(), "basketballstats"), recursive = TRUE)

})

##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
