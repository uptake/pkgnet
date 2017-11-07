
# [description] Log message. Thin wrapper around 
#               futile.logger::flog.info to make main package code a little less verbose
#' @importFrom futile.logger flog.fatal
log_info <- function(msg, ...){
    futile.logger::flog.info(msg = msg, ...)
    return(invisible(NULL))
}

# [description] Log warning and throw an R warning. Thin wrapper around 
#               futile.logger::flog.warn to make main package code a little less verbose
#' @importFrom futile.logger flog.warn
log_warn <- function(msg, ...){
    futile.logger::flog.warn(msg = msg, ...)
    warning(msg)
    return(invisible(NULL))
}

# [description] Log fatal error and throw an R exception. Thin wrapper around 
#               futile.logger::flog.fatal to make main package code a little less verbose
#' @importFrom futile.logger flog.fatal
log_fatal <- function(msg, ...){
    futile.logger::flog.fatal(msg = msg, ...)
    stop(msg)
    return(invisible(NULL))
}
