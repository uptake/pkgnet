context("CreatePackageReport")

#Supress logger in tests
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

test_that("Test that CreatingPackageReport Runs", {
    reporters <- CreatePackageReport(packageName = "baseballstats",reportPath = 'baseballstats.html')
    testthat::expect_true(all(unlist(lapply(reporters,function(x) "AbstractPackageReporter" %in% class(x)))))
    testthat::expect_true(file.exists("baseballstats.html") && file.size("baseballstats.html") > 0)
    file.remove('baseballstats.html')
})
