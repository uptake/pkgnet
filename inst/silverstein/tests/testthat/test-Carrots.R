test_that("Carrots class exists", {
  expect_true(R6::is.R6Class(Carrots))
})

test_that("No additional classes", {
  test_env <- getNamespace("silverstein")
  test_env_names <- ls(test_obj_env)
  test_env_r6_classes <- Filter(function(x) R6::is.R6Class(get(x, test_env)), test_env_names)
  
  expect_setequal(test_env_r6_classes, "Carrots")
})
