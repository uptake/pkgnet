context("CreatePackageVignette Tests")
rm(list = ls())

##### TESTS #####

# baseballstats source path
sourcePath <- system.file("baseballstats"
                       , package = "pkgnet"
                       , lib.loc = Sys.getenv('PKGNET_TEST_LIB')
            )

.CreateSourceCopy <- function(sourcePath) {
    tempDirectory <- tempfile()
    dir.create(tempDirectory)
    file.copy(from = sourcePath
              , to = tempDirectory
              , recursive = TRUE
    )
    return(file.path(tempDirectory, basename(sourcePath)))
}

test_that("Test that CreatePackageVignette runs end-to-end with default inputs", {

    pkgPath <- .CreateSourceCopy(sourcePath)
    originalWD <- getwd()
    setwd(pkgPath)
    on.exit(expr = {
        setwd(originalWD)
        unlink(pkgPath, recursive = TRUE)
    })
    dir.create(file.path(pkgPath, "vignettes"))
    vignettePath <- file.path("vignettes", "pkgnet-report.Rmd")
    outputPath <- tempfile(pattern = "vignette", fileext = ".html")

    expect_true({
        CreatePackageVignette()
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

test_that("Test that CreatePackageVignette runs end-to-end with specified dir", {

    pkgPath <- .CreateSourceCopy(sourcePath)
    on.exit(expr = unlink(pkgPath, recursive = TRUE))
    dir.create(file.path(pkgPath, "vignettes"))
    vignettePath <- file.path(
        pkgPath
        , "vignettes"
        , "vignette_file.Rmd"
    )
    outputPath <- tempfile(pattern = "vignette", fileext = ".html")

    expect_true({
        CreatePackageVignette(pkg = pkgPath
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

test_that("Test that CreatePackageVignette runs end-to-end with non-default reporters", {

    pkgPath <- .CreateSourceCopy(sourcePath)
    on.exit(expr = unlink(pkgPath, recursive = TRUE))
    dir.create(file.path(pkgPath, "vignettes"))
    vignettePath <- file.path(
        pkgPath
        , "vignettes"
        , "vignette_file.Rmd"
    )
    outputPath <- tempfile(pattern = "vignette", fileext = ".html")

    expect_true({
        CreatePackageVignette(pkg = pkgPath
                              , pkg_reporters = list(
                                  SummaryReporter$new()
                                  , DependencyReporter$new()
                              )
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

    pkgPath <- .CreateSourceCopy(sourcePath)
    on.exit(expr = unlink(pkgPath, recursive = TRUE))

    vignettePath <- tempfile(pattern = "vignette", fileext = ".Rmd")

    # pkg doesn't point to a package root
    notPkgPath <- tempfile()
    dir.create(notPkgPath)
    on.exit(unlink(notPkgPath, recursive = TRUE))
    expect_error(
        CreatePackageVignette(pkg = notPkgPath)
        , regexp = "We can't find your DESCRIPTION file"
        , fixed = TRUE
    )

    # Non-existent vignette_path directory
    expect_error(
        CreatePackageVignette(
            pkg = pkgPath
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
        CreatePackageVignette(pkg = pkgPath
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

    pkgPath <- .CreateSourceCopy(sourcePath)
    on.exit(expr = unlink(pkgPath, recursive = TRUE))

    # In a vignettes directory that isn't in a package root
    vignettesDir <- file.path(tempdir(), "vignettes")
    dir.create(vignettesDir)
    expect_warning(
        CreatePackageVignette(pkg = pkgPath
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
        CreatePackageVignette(pkg = pkgPath
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
