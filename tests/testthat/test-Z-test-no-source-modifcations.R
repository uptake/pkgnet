# Inditended to be run last, this is to confirm that no files 
# within the package directory are modified during the normal 
# operation of pkgnet during these tests.  This includes the 
# creation and deletion of temp files for rendering. 

test_that('No modification to pkgnet directory during testing',{
    startModTime <- as.POSIXct(Sys.getenv('PKGNET_LATEST_MOD'))
    
    tmp_pkgnet_path <- file.path(Sys.getenv('PKGNET_TEST_LIB'), 'pkgnet')
    currentModTime <- file.info(tmp_pkgnet_path)$mtime

    if (as.character(startModTime) != as.character(currentModTime)){
        pkgnet:::.printModifiedFiles(tmp_pkgnet_path, startModTime)
    }

    expect_equal(object = currentModTime
                 , expected = startModTime
                 , info = "The source directory was modified during the execution of tests."
                 )

})