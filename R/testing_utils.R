
# [Title]   Build A Library For Testing
# [DESC]    Installs all packages necessary for testing into a another directory,
#           preferably a temporary directory. This function will throw a fatal error
#           if that installation fails.
# [param]   targetLibPath (string) path to the location of the new directory
# [return]  boolean TRUE
.BuildTestLib <- function(targetLibPath){

    ### Find pkgnet and test package source directory ###

    # Within devtools::test(), R CMD CHECK, and vignette building. Depending on
    # what is running the test, the directory structure is different so we need
    # to figure out which case we have and navigate to the right place

    # NOTE: this can be fragile. Uncomment the lines with "# [DEBUG]" and run test.sh
    #       from the repo root if something goes wrong

    # [DEBUG] write("=========", file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(paste0("target lib path: ", targetLibPath), file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(list.files(getwd(), recursive = TRUE), file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(paste0("working dir: ", getwd()), file = "~/thing.txt", append = TRUE)

    pkgnetSourcePath <- getwd()

    # For R CMD check
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests/testthat$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)

    # For R CMD check on some Windows that explicitly install 64 bit
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests_x64/testthat$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests_x64$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)

    # For R CMD check on some Linux machines that explicitly install i386 
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests_i386/testthat$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests_i386$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    
    
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/vign_test/pkgnet$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet/vignettes$', replacement = '/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('pkgnet/tests/testthat', replacement = 'pkgnet', x = pkgnetSourcePath)

    # For covr
    pkgnetSourcePath <- gsub('/pkgnet/pkgnet-tests/testthat', replacement = '/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet/pkgnet-tests', replacement = '/pkgnet', x = pkgnetSourcePath)

    # [DEBUG] write(paste0("pkgnet path: ", pkgnetSourcePath), file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(list.files(pkgnetSourcePath, recursive = TRUE), file = "~/thing.txt", append = TRUE)

    ######

    # Check if there is an inst directory in pkgnetSource.
    # If there is an inst directory (because of raw package copy) then look in there
    # for the test packages.
    # Otherwise if not, it means that it's an installed package copy and the test
    # packages are in the package root directory.
    testPkgSourceDir <- ""
    if ("inst" %in% list.files(pkgnetSourcePath)) {
        testPkgSourceDir <- "inst"
    }

    ### packages to be built
    pkgList <- c(
        baseballstats = file.path(pkgnetSourcePath, testPkgSourceDir, "baseballstats")
        , sartre = file.path(pkgnetSourcePath, testPkgSourceDir, "sartre")
        , milne = file.path(pkgnetSourcePath, testPkgSourceDir, "milne")
        , pkgnet = pkgnetSourcePath
    )

    # [DEBUG] write(paste0("Installing: ", paste(pkgList)), file = "~/thing.txt", append = TRUE)

    ### Install

    # Figure out where R is to use the current R binary to install the packages
    # This guarantees you're using the right R binary, e.g., in case someone
    # from CRAN is running RD CMD CHECK instead of R CMD CHECK
    # https://stackoverflow.com/questions/33798115/command-to-see-r-path-that-rstudio-is-using
    R_LOC <- file.path(R.home("bin"), "R")

    # force install of SOURCE (not binary) in temporary directory for tests
    cmdstr <- sprintf(
        fmt = '"%s" CMD INSTALL -l "%s" %s'
        , R_LOC
        , targetLibPath
        , paste0(pkgList, collapse = " ")
    )

    exitCode <- system(command = cmdstr, intern = FALSE)

    if (exitCode != 0){

        # Get the actual error text
        output <- system(command = cmdstr, intern = TRUE)
        stop(sprintf(
            "Installation of packages in .BuildTestLib failed! (exit code = %s)\n\n%s"
            , exitCode
            , paste0(output, collapse = " ... ")
        ))
    }

    # [DEBUG] write("=========", file = "~/thing.txt", append = TRUE)

    return(invisible(TRUE))
}
