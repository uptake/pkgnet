

# [Title]   Build A Library For Testing
# [DESC]    Loads all packages necessary for testing into a another directory,
#           preferably a temporary directory. This function also confirms successful installation.
# [param]   currentLibPath (string) path to the current library in which pkgnet resides
# [param]   targetLibPath (string) path to the location of the new directory
# [return]  boolean TRUE
.BuildTestLib <- function(currentLibPaths
                         , targetLibPath
                         ){

    localDirPathInst <- system.file(
        package = "pkgnet"
        , lib.loc = currentLibPaths
    )

    ### find PKGNET source dir within devtools::test, R CMD CHECK, and vignette building
    pkgnetSourcePath <- gsub(
        pattern = '/tests/testthat$|/vignettes$|pkgnet.Rcheck/tests$'
        , replacement = ''
        , x = getwd()
    )

    ### packages to be built
    pkgList <- list(
        baseballstats = system.file(
            'baseballstats'
            , package = "pkgnet"
            , lib.loc = currentLibPaths
        )
        , sartre = system.file(
            'sartre'
            , package = "pkgnet"
            , lib.loc = currentLibPaths
        )
        , pkgnet = pkgnetSourcePath
    )

    ### Install and confirm
    installResult <- sapply(
        X = names(pkgList)
        , FUN = function(p){

            # Figure out where R is to avoid those weird warnings about
            # 'R' should not be used without a path -- see par. 1.6 of the manual
            R_LOC <- system('which R', intern = TRUE)

            # force install of SOURCE (not binary) in temporary directory for tests
            cmdstr <- sprintf(
                fmt = '"%s" CMD INSTALL -l "%s" --install-tests "%s"'
                , R_LOC
                , targetLibPath
                , pkgList[[p]]
            )

            exitCode <- system(command = cmdstr, intern = FALSE)

            if (exitCode != 0){
                stop(sprintf(
                    "Installation of %s in .BuildTestLib failed! (exit code = %s)"
                    , pkgList[[p]]
                    , exitCode
                ))
            }

            # confirm install
            db <- installed.packages(lib.loc = targetLibPath)
            return(is.element(el = p, set = db[, 1]))
        }
    )

    ### Message Out
    if (all(installResult)) {
        log_info("Successfully created test library.")
        log_info(paste0("Test Libpath: ", targetLibPath))
        log_info(paste0(
            "Packages: "
            , paste(names(pkgList), collapse = ",")
        ))
        return(TRUE)
    } else {
        missing <- names(pkgList)[!installResult]
        log_fatal(paste0(
            "Test library incomplete: Missing "
            , paste(missing, collapse = ", ")
        ))
    }

}
