context("CreatePackageReport")

#Supress logger in tests
futile.logger::flog.threshold(0,name=futile.logger::flog.namespace())

test_that("Test that CreatingPackageReport Runs", {
    devtools::install_local(system.file('baseballstats',package="pkgnet"),force=TRUE)
    #TODO: Change when generating reports
    pdf("test_plots.pdf") #PDF doesn't actually work
    reporters <- CreatePackageReport(packageName = "baseballstats")
    dev.off()
    testthat::expect_true(all(unlist(lapply(reporters,function(x) "AbstractPackageReporter" %in% class(x)))))
    testthat::expect_true(file.exists("test_plots.pdf") && file.size("test_plots.pdf") > 0)
    file.remove("test_plots.pdf")
})
