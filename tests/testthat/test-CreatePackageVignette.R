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

test_that("Test that CreatePackageVignette with pkg_path runs end-to-end", {

    vignettePath <- tempfile(pattern = "vignette", fileext = ".Rmd")
    outputPath <- tempfile(pattern = "vignette", fileext = ".html")

    expect_true({
        CreatePackageVignette(pkg_name = "baseballstats"
                              , pkg_path = pkgPath
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



##### TEST TEAR DOWN #####

rm(list = ls())
closeAllConnections()
