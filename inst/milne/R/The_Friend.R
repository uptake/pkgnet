# Reference Class (a.k.a. "R5") Definitions for testing

#' @title Pooh's Answer
#' @name PoohAnswer
#' @family TheFriend
#' @description Pooh's Answer to a Question
#' @export PoohAnsuh
#' @exportClass PoohAnswer
# Generator name doesn't need to match class name
PoohAnsuh <- setRefClass(
    Class = "PoohAnswer",
    methods = list(
        get_answer = function() {"sixpence"}
    )
)

# @title My Answer
# @name MyAnswer
# @family TheFriend
# @description My Answer to a Question
# Generators don't have to be bound to an object
# Can use the function `new` to generate new object
setRefClass(
    Class = "MyAnswer"
)

#' @title Right Answer
#' @name RightAnswer
#' @family TheFriend
#' @description Correct Answer to a Question
#' @export RightAnswer
#' @exportClass RightAnswer
RightAnswer <- setRefClass(
    Class = "RightAnswer",
    contains = c("PoohAnswer", "MyAnswer")
)

# @title Wrong Answer
# @name WrongAnswer
# @family TheFriend
# @description Incorrect Answer to a Question
WrongAnswer <- setRefClass(
    Class = "WrongAnswer",
    contains = c("PoohAnswer", "numeric")
)
