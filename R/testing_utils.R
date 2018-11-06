
# [Title]   Build A Library For Testing
# [DESC]    Installs all packages necessary for testing into a another directory,
#           preferably a temporary directory. This function will throw a fatal error
#           if that installation fails.
# [param]   targetLibPath (string) path to the location of the new directory
# [return]  boolean TRUE
.BuildTestLib <- function(targetLibPath){

    ### find PKGNET source dir within devtools::test(), R CMD CHECK, and vignette building
    # NOTE: this can be fragile. Uncomment the lines with "# [DEBUG]" and run test.sh
    #       from the repo root if something goes wrong

    # [DEBUG] write("=========", file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(list.files(getwd(), recursive = TRUE), file = "~/thing.txt", append = TRUE)
    # [DEBUG] write(paste0("working dir: ", getwd()), file = "~/thing.txt", append = TRUE)

    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests/testthat$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = getwd())
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/vign_test/pkgnet$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet/vignettes$', replacement = '/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('pkgnet/tests/testthat', replacement = 'pkgnet', x = pkgnetSourcePath)

    # [DEBUG] write(paste0("pkgnet path: ", pkgnetSourcePath), file = "~/thing.txt", append = TRUE)
    # [DEBUG] write("=========", file = "~/thing.txt", append = TRUE)

    ### packages to be built
    pkgList <- c(
        baseballstats = file.path(pkgnetSourcePath, "inst", "baseballstats")
        , sartre = file.path(pkgnetSourcePath, "inst", "sartre")
        , pkgnet = pkgnetSourcePath
    )

    ### Install

    # Figure out where R is to avoid those weird warnings about
    # 'R' should not be used without a path -- see par. 1.6 of the manual.
    #
    # NOTE: R CMD CHECK comes with its own bundled "R" binary which doesn't
    #       work the same way and causes that error. Just trust me on this.
    #
    # NOTE: "Sys.which()" would be the correct, portable way to do this but it
    # doesn't support matching ALL matches, so for now we'll make it work
    # on unix-alike operating systems and deal with Windows later
    #
    R_LOC <- system("which -a R", intern = TRUE)
    R_LOC <- R_LOC[!grepl("R_check_bin", R_LOC)][1]

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

    return(invisible(TRUE))
}
