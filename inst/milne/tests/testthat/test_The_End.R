theEndClasses <- c('One', 'Two', 'Three', 'Four', 'Five', 'Six')

# Helper function to avoid printing
# http://r.789695.n4.nabble.com/Suppressing-output-e-g-from-cat-tp859876p859882.html
.quiet <- function(x) {
    sink(tempfile())
    on.exit(sink())
    invisible(force(x))
}

for (thisClass in theEndClasses) {
    test_that(
        sprintf('%s class can be sucessfully intialized', thisClass)
        , expect_true({
            .quiet({myObj <- get(thisClass)$new()})
            R6::is.R6(myObj)
        })
    )
}
