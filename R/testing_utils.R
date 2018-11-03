

# [Title]   Build A Library For Testing
# [DESC]    Loads all packages necessary for testing into a another directory,
#           preferably a temporary directory. This function also confirms successful installation.
# [param]   targetLibPath (string) path to the location of the new directory
# [return]  boolean TRUE
.BuildTestLib <- function(targetLibPath){

    ### find PKGNET source dir within devtools::test, R CMD CHECK, and vignette building
    pkgnetSourcePath <- gsub('/tests/testthat$', replacement = '', x = getwd())
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/tests$', replacement = '', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck/vign_test/pkgnet$', replacement = '', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/vignettes$', replacement = '', x = pkgnetSourcePath)
    pkgnetSourcePath <- gsub('/pkgnet.Rcheck$', replacement = '', x = pkgnetSourcePath)
    write(pkgnetSourcePath, file = "~/repos/thing.txt", append = TRUE)

    ### packages to be built
    pkgList <- c(
        baseballstats = file.path(pkgnetSourcePath, "inst", "baseballstats")
        , sartre = file.path(pkgnetSourcePath, "inst", "sartre")
        , pkgnet = pkgnetSourcePath
    )

    ### Install and confirm

    # Figure out where R is to avoid those weird warnings about
    # 'R' should not be used without a path -- see par. 1.6 of the manual
    R_LOC <- system('which R', intern = TRUE)

    # force install of SOURCE (not binary) in temporary directory for tests
    cmdstr <- sprintf(
        fmt = '"%s" CMD INSTALL -l "%s" %s'
        , R_LOC
        , targetLibPath
        , paste0(pkgList, collapse = " ")
    )
    print(cmdstr)

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

    # confirm install
    #db <- installed.packages(lib.loc = targetLibPath)

    ### Install and confirm
    # installResult <- sapply(
    #     X = names(pkgList)
    #     , FUN = function(p){
    #
    #         # Figure out where R is to avoid those weird warnings about
    #         # 'R' should not be used without a path -- see par. 1.6 of the manual
    #         R_LOC <- system('which R', intern = TRUE)
    #
    #         # force install of SOURCE (not binary) in temporary directory for tests
    #         cmdstr <- sprintf(
    #             fmt = '"%s" CMD INSTALL -l "%s"'
    #             , R_LOC
    #             , targetLibPath
    #             , pkgList[[p]]
    #         )
    #
    #         exitCode <- system(command = cmdstr, intern = FALSE)
    #
    #         if (exitCode != 0){
    #
    #             # Get the actual error text
    #             output <- system(command = cmdstr, intern = TRUE)
    #             stop(sprintf(
    #                 "Installation of %s in .BuildTestLib failed! (exit code = %s)\n\n%s"
    #                 , pkgList[[p]]
    #                 , exitCode
    #                 , paste0(output, collapse = " ... ")
    #             ))
    #         }
    #
    #         # confirm install
    #         db <- installed.packages(lib.loc = targetLibPath)
    #         return(is.element(el = p, set = db[, 1]))
    #     }
    # )

    ### Message Out
    # if (all(installResult)) {
    #     log_info("Successfully created test library.")
    #     log_info(paste0("Test Libpath: ", targetLibPath))
    #     log_info(paste0(
    #         "Packages: "
    #         , paste(names(pkgList), collapse = ",")
    #     ))
    #     return(TRUE)
    # } else {
    #     missing <- names(pkgList)[!installResult]
    #     log_fatal(paste0(
    #         "Test library incomplete: Missing "
    #         , paste(missing, collapse = ", ")
    #     ))
    # }

}
