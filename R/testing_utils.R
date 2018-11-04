

# [Title]   Build A Library For Testing
# [DESC]    Loads all packages necessary for testing into a another directory,
#           preferably a temporary directory. This function also confirms successful installation.
# [param]   targetLibPath (string) path to the location of the new directory
# [param]   rBinaryLoc (string) full path to the "R" executable. When you run R CMD CHECK,
#                               it bundles in its own custom R executable. When you try to use
#                               that version in an "R CMD INSTALL" call while using the --as-cran
#                               flag to CHECK, things get weird.
# [return]  boolean TRUE
.BuildTestLib <- function(targetLibPath){

    write("=========", file = "~/repos/thing.txt", append = TRUE)
    write(list.files(getwd(), recursive = TRUE), file = "~/repos/thing.txt", append = TRUE)
    ### find PKGNET source dir within devtools::test, R CMD CHECK, and vignette building
    write(paste0("working dir: ", getwd()), file = "~/repos/thing.txt", append = TRUE)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests/testthat$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = getwd())
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/vign_test/pkgnet$', replacement = '/pkgnet.Rcheck/00_pkg_src/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet/vignettes$', replacement = '/pkgnet', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('pkgnet/tests/testthat', replace = 'pkgnet', x = pkgnetSourcePath)
    write(paste0("pkgnet path: ", pkgnetSourcePath), file = "~/repos/thing.txt", append = TRUE)
    write("=========", file = "~/repos/thing.txt", append = TRUE)

    ### packages to be built
    pkgList <- c(
        baseballstats = file.path(pkgnetSourcePath, "inst", "baseballstats")
        , sartre = file.path(pkgnetSourcePath, "inst", "sartre")
        , pkgnet = pkgnetSourcePath
    )

    ### Install and confirm

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

    return(TRUE)
}
