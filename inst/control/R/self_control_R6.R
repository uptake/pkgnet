#' Test Class for Control Statements
#' 
#' @description A Test Class for Control Statements handling in R6
#' @export 
testClass <- R6::R6Class(
    classname = "testClass",
    public = list(
        #' @description
        #' Test if .parse_R6_expression () breaks with control function 'break'
        #' @return Nothing
        take_a_break = function() {
            for (i in 1:10){
                if (i==5){
                    break
                    }
                }
            },
        #' @description
        #' Test if .parse_R6_expression () breaks with control function 'next'
        #' @return Nothing
        next_up = function() {
            for (i in 1:10){
                if (i==5){
                    next
                    }
                }
            }
    )
)
