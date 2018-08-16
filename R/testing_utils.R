

# [Title]   Build A Library For Testing
# [DESC]    Loads all packages necessary for testing into a another directory, 
#           preferably a temporary directory. This function also confirms successful installation. 
# [param]   currentLibPath (string) path to the current library in which pkgnet resides
# [param]   targetLibPath (string) path to the location of the new directory
# [return]  boolean TRUE
.BuildTestLib <- function(currentLibPaths
                         , targetLibPath){
    
    localDirPathInst <- system.file(package = "pkgnet"
                                , lib.loc = currentLibPaths
    )
    
    # find PKGNET source dir with tests
    pkgnetSourcePath <- gsub(pattern = '/tests/testthat$|/vignettes$|pkgnet.Rcheck/tests$'
                  , replacement = ''
                  , x = getwd()
    )
    
    print(pkgnetSourcePath)
    
    cmdstr <- sprintf(fmt = 'R CMD INSTALL -l "%s" --install-tests "%s"'
                      , targetLibPath
                      , pkgnetSourcePath
                      )
    
    system(command = cmdstr)
    
    # packages to be built
    pkgList <- list(baseballstats = system.file('baseballstats'
                                                , package = "pkgnet"
                                                , lib.loc = currentLibPaths
                                                )
                    , sartre = system.file('sartre'
                                           , package = "pkgnet"
                                           , lib.loc = currentLibPaths
                                           )
    )
    
    print(pkgList)
    # print(list.dirs(path = dirname(pkgList[['pkgnet']])
    #                 , recursive = TRUE
    #                 , full.names = FALSE
    # )
    # )
    # print(list.dirs(path = pkgList[['pkgnet']]
    #                 , recursive = TRUE
    #                 , full.names = FALSE
    #                 )
    #       )
    log_info(pkgList)
    
    
    installResult <- sapply(X = names(pkgList)
                            , FUN = function(p){
                                # install
                                utils::install.packages(pkgs = pkgList[[p]]
                                                        , lib = targetLibPath
                                                        , repos = NULL
                                                        , type = "source"
                                                        , INSTALL_opts = c('--install-tests'
                                                        )
                                )
                                
                                # confirm install
                                db <- installed.packages(lib.loc = targetLibPath)
                                return(
                                    is.element(el = p
                                                  , set = db[,1]
                                                  )
                                       )
                            })

    if(all(installResult)) {
        log_info("Successfully created test library.")
        log_info(paste0("Test Libpath: ", targetLibPath))
        log_info(paste0("Packages: "
                        , paste(names(pkgList)
                                , collapse = ","
                                )
                        )
        )
        return(TRUE)
    } else {
        missing <- names(pkgList)[!installResult]
        log_fatal(paste0("Test library incomplete: Missing "
                         , paste(missing, collapse = ",")
                         )
                  )
    }
    
}

