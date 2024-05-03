#' Carrots R6 Class Definitions for testing
#' @family Carrots
#' @description Class in which every method has an equal number of package function references
#' @importFrom R6 R6Class
#' @export
Carrots  <- R6Class(
  classname = "Carrots",

  # necessary to guarantee all class methods have precisely one reference
  cloneable = FALSE,

  public = list(
    #' @description Initialize Carrots. 
    #' @return nothing
    initialize = function() {
      couplet_1()
    }
  ),
  private = list(
    finalize = function() {
      couplet_2()
    }
  )
)

couplet_1 <- function() {
  cat("They say that carrots are good for your eyes,\nThey swear that they improve your sight,\n")
}

couplet_2 <- function() {
  cat("But I'm seein' worse than I did last night--\nYou think maybe I aint usin' 'em right?\n")
}
