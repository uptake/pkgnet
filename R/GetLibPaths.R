

# [TITLE]   Get Library Paths
# [NAME]    .GetLibPaths
# [DESC]    This is a necessary redundancy for enabling standard unit
#           testing and vignette creation on CRAN.  One requirement of 
#           a CRAN hosted program is to not write outside of the temporary 
#           directory with any default functionality.  In order to test pkgnet, 
#           R packages with known structures must be available.  For this purpose, two 
#           test packages are loaded from the inst folder during testing: baseballstats
#           and sartre.  However, if not provided an alternate path, these packages 
#           will be loaded into the user's R library which is outside the 
#           temporary directory and therefore a violation of CRAN policy.  
#           Loading baseballstats and sartre for use in building a vignette encounters 
#           the same violation.  


# [VALUE] Same thing as .libPaths(): a character vector of file paths.
# .GetLibPaths <- function(){
#     return(.libPaths())
# }
