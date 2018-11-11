Four <- R6::R6Class(
    "Four",
    public = list(
        when_i_was_four = function() {"I was not much more"}
    ),
    private = list(
        more_level = function() {"not much"}
    )
)

Five <- R6::R6Class(
    "Five",
    inherit = Four,
    public = list(
        when_i_was_five = function() {"I was just alive"}
    ),
    private = list(
    )
)

Six <- R6::R6Class(
    "Six",
    inherit = Five,
    public = list(
        now_i_am_six = function() {
            sprintf("I'm as %s as ever", .clever())
        }, 
        last_time = function() {self$when_i_was_five()}
    ),
    private = list(
        more_level = function() {
            gsub("not ", "", super$more_level())
        }
    )
)

.clever <- function() {
    "clever"
}

