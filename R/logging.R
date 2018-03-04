
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
}

#' @importFrom futile.logger flog.threshold logger.options
silence_logger <- function() {
    
    loggerOptions <- futile.logger::logger.options()
    if (!identical(loggerOptions, list())){
        origLogThreshold <- loggerOptions[[1]][['threshold']]
    }
    futile.logger::flog.threshold(0)
    return(invisible(NULL))
}

#' @importFrom futile.logger INFO flog.threshold
unsilence_logger <- function(thresh = futile.logger::INFO) {
    futile.logger::flog.threshold(thresh)
    return(invisible(NULL))
}

