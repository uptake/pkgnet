# Reference Class (a.k.a. "R5") Definitions for testing

#' @title Pooh's Answer
#' @name PoohAnswer
#' @family TheFriend
#' @description Pooh's Answer to a Question
#' @export
PoohAnswer <- setRefClass("PoohAnswer")

#' @title My Answer
#' @name MyAnswer
#' @family TheFriend
#' @description My Answer to a Question
#' @export
MyAnswer <- setRefClass("MyAnswer")

#' @title Right Answer
#' @name RightAnswer
#' @family TheFriend
#' @description Correct Answer to a Question
#' @export
RightAnswer <- setRefClass(
    "RightAnswer", 
    contains = c("PoohAnswer", "MyAnswer")
)

#' @title Wrong Answer
#' @name WrongAnswer
#' @family TheFriend
#' @description Incorrect Answer to a Question
#' @export
WrongAnswer <- setRefClass(
    "WrongAnswer", 
    contains = "PoohAnswer"
)

