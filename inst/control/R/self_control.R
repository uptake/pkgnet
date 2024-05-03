#' @title Take a Break
#' @name take_a_break
#' @description Test if .parse_function() breaks with control function 'break'
#' @export
take_a_break <- function() {
    for (i in 1:10){
        if (i==5){
            break
            }
        }
    }

#' @title Next Up
#' @name next_up
#' @description Test if .parse_function() breaks with control function 'next'
#' @export
next_up <- function() {
    for (i in 1:10){
        if (i==5){
            next
            }
        }
    }