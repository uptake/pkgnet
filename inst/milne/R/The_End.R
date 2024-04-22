# R6 Class Definitions for testing

#' R6 Class Age One
#' 
#' @description 
#' Age One
#' 
#' @details 
#' Age One
#' 
#' @importFrom R6 R6Class
#' @export
One <- R6::R6Class(
    classname = "One",
    public = list(

        #' @description
        #' Create a New Age One Object
        #' @return An Age One Object
        initialize = function() {
            cat("The End, by A. A. Milne \n")
        },

        #' @description 
        #' Print poem
        print_poem = function() {
            cat("When I was One, \n",
                "I had just begun. \n"
                )
        },

        #' @description 
        #' Get Age
        how_old_am_i = function() {private$get_age()}
    ),
    private = list(
        get_age = function() {.classname(self)}
    )
)

#' R6 Class Age Two
#' 
#' @description 
#' Age Two
#' 
#' @details 
#' Age Two
#' 
#' @importFrom R6 R6Class
#' @export
Two <- R6::R6Class(
    classname = "Two",
    inherit = One,
    public = list(
        #' @description 
        #' Print poem two
        print_poem = function() {
            super$print_poem()
            cat("When I was Two, \n",
                "I was nearly new. \n"
            )
        }
    )
)

#' R6 Class Age Three
#' 
#' @description 
#' Age Three
#' 
#' @details 
#' Age Three
#' 
#' @importFrom R6 R6Class
#' @export
Three <- R6::R6Class(
    # R6 classes don't need classname to match generator name
    classname = "HardlyThree",
    inherit = Two,
    public = list(
        #' @description 
        #' Print poem thrice
        print_poem = function() {
            super$print_poem()
            cat("When I was Three, \n",
                "I was hardly Me. \n"
            )
        }
    )
)

#' R6 Class Age Four
#' 
#' @description 
#' Age Four
#' 
#' @details 
#' Age Four
#' 
#' @importFrom R6 R6Class
#' @export
Four <- R6::R6Class(
    # R6 classes don't need classname at all
    classname = NULL,
    inherit = Three,
    public = list(
        #' @description 
        #' Print poem four
        print_poem = function() {
            super$print_poem()
            cat("When I was Four, \n",
                "I was not much more. \n"
            )
        }
    )
)

#' R6 Class Age Five
#' 
#' @description 
#' Age Five
#' 
#' @details 
#' Age Five
#' 
#' @importFrom R6 R6Class
#' @export
Five <- R6::R6Class(
    classname = "Five",
    inherit = Four,
    public = list(
        #' @description 
        #' Print poem five times
        #' @details
        #' Did your hand hit on the river?
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

#' R6 Class Age Six
#' 
#' @description 
#' Age Six
#' 
#' @details 
#' Age Six
#' 
#' @importFrom R6 R6Class
#' @export
Six <- R6::R6Class(
    classname = "Six",
    inherit = Five,
    public = list(
        #' @description 
        #' Print poem six times
        #' @details
        #' I should have looked ahead
        print_poem = function() {
            super$print_poem()
            cat("But now I am Six,",
                "I'm as clever as clever. \n"
            )
            private$print_ending()
        }
    ),
    private = list(
        # I don't think private classes and methods are supported by Roxygen2
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
