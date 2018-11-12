#' @title Age Four
#' @name Four
#' @family TheEnd
#' @description Age Four
#' @importFrom R6 R6Class
#' @export
Four <- R6::R6Class(
    "Four",
    public = list(
        when_i_was_four = function() {"I was not much more"}
    ),
    private = list(
        more_level = function() {"not much"}
    )
)

#' @title Age Five
#' @name Five
#' @family TheEnd
#' @description Age Five
#' @importFrom R6 R6Class
#' @export
Five <- R6::R6Class(
    "Five",
    inherit = Four,
    public = list(
        when_i_was_five = function() {"I was just alive"}
    ),
    private = list(
    )
)

#' @title Age Six
#' @name Six
#' @family TheEnd
#' @description Age Six
#' @importFrom R6 R6Class
#' @export
Six <- R6::R6Class(
    "Six",
    inherit = Five,
    public = list(
        now_i_am_six = function() {
            sprintf("I'm as %s as clever", .clever())
        }, 
        last_time = function() {self$when_i_was_five()}
    ),
    private = list(
        more_level = function() {
            gsub("not ", "", super$more_level())
        }
    )
)

# [description] internal function
.clever <- function() {
    "clever"
}
