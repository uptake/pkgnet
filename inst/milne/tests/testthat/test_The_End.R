test_that('Four class can be sucessfully intialized', expect_true({
    myObj <- Four$new()
    R6::is.R6(myObj)
}))

test_that('Five class can be sucessfully intialized', expect_true({
    myObj <- Five$new()
    R6::is.R6(myObj)
}))

test_that('Six class can be sucessfully intialized', expect_true({
    myObj <- Six$new()
    R6::is.R6(myObj)
}))