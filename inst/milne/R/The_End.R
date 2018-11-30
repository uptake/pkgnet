# R6 Class Definitions for testing

#' @title Age One
#' @name One
#' @family TheEnd
#' @description Age One
#' @importFrom R6 R6Class
#' @export
One <- R6::R6Class(
    classname = "One",
    public = list(
        initialize = function() {
            cat("The End, by A. A. Milne \n")
        },
        print_poem = function() {
            cat("When I was One, \n",
                "I had just begun. \n"
                )
        },
        how_old_am_i = function() {private$get_age()}
    ),
    private = list(
        get_age = function() {.classname(self)}
    )
)

#' @title Age Two
#' @name Two
#' @family TheEnd
#' @description Age Two
#' @importFrom R6 R6Class
#' @export
Two <- R6::R6Class(
    classname = "Two",
    inherit = One,
    public = list(
        print_poem = function() {
            super$print_poem()
            cat("When I was Two, \n",
                "I was nearly new. \n"
            )
        }
    )
)

#' @title Age Three
#' @name Three
#' @family TheEnd
#' @description Age Three
#' @importFrom R6 R6Class
#' @export
Three <- R6::R6Class(
    # R6 classes don't need classname to match generator name
    classname = "HardlyThree",
    inherit = Two,
    public = list(
        print_poem = function() {
            super$print_poem()
            cat("When I was Three, \n",
                "I was hardly Me. \n"
            )
        }
    )
)

#' @title Age Four
#' @name Four
#' @family TheEnd
#' @description Age Four
#' @importFrom R6 R6Class
#' @export
Four <- R6::R6Class(
    # R6 classes don't need classname at all
    classname = NULL,
    inherit = Three,
    public = list(
        print_poem = function() {
            super$print_poem()
            cat("When I was Four, \n",
                "I was not much more. \n"
            )
        }
    )
)

#' @title Age Five
#' @name Five
#' @family TheEnd
#' @description Age Five
#' @importFrom R6 R6Class
#' @export
Five <- R6::R6Class(
    classname = "Five",
    inherit = Four,
    public = list(
        print_poem = function() {
            super$print_poem()
            cat("When I was Five, \n",
                "I was just alive. \n"
            )
        }
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
    classname = "Six",
    inherit = Five,
    public = list(
        print_poem = function() {
            super$print_poem()
            cat("But now I am Six,",
                "I'm as clever as clever. \n"
            )
            private$print_ending()
        }
    ),
    private = list(
        print_ending = function() {
            cat("So I think I'll be six now",
                "for ever and ever."
            )
        }
    )
)

# [description] internal function
.classname <- function(obj) {
    class(obj)[1]
}
