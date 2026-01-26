#' Simple Logger Class
#'
#' @description A minimal logging class using only base R functions.
#' Provides threshold-based logging with INFO, WARN, and FATAL levels.
#'
#' @keywords internal
#' @importFrom R6 R6Class
SimpleLogger <- R6::R6Class(
    classname = "SimpleLogger"
    , public = list(

        #' @description Initialize a new SimpleLogger
        #' @param threshold Initial threshold level (default: 0 for silent)
        #' @return A new SimpleLogger instance
        initialize = function(threshold = 0) {
            private$threshold <- threshold
        }

        #' @description Log an informational message
        #' @param msg Message to log
        #' @param ... Additional arguments (currently ignored)
        #' @return NULL invisibly
        , info = function(msg, ...) {
            if (private$threshold >= 4) {
                message(sprintf("INFO [%s] %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg))
            }
            return(invisible(NULL))
        }

        #' @description Log a warning message
        #' @param msg Message to log
        #' @param ... Additional arguments (currently ignored)
        #' @return NULL invisibly
        , warn = function(msg, ...) {
            if (private$threshold >= 5) {
                message(sprintf("WARN [%s] %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg))
            }
            return(invisible(NULL))
        }

        #' @description Log a fatal error message
        #' @param msg Message to log
        #' @param ... Additional arguments (currently ignored)
        #' @return NULL invisibly
        , fatal = function(msg, ...) {
            if (private$threshold >= 6) {
                message(sprintf("FATAL [%s] %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg))
            }
            return(invisible(NULL))
        }

        #' @description Get current threshold
        #' @return Current threshold value
        , get_threshold = function() {
            return(private$threshold)
        }

        #' @description Set threshold level
        #' @param level Threshold level (0 = silent, 4 = INFO, 5 = WARN, 6 = FATAL)
        #' @return NULL invisibly
        , set_threshold = function(level) {
            private$threshold <- level
            return(invisible(NULL))
        }
    )

    , private = list(
        threshold = 0
    )
)

# Create a package-level environment to hold the logger instance
# (environments remain mutable even when locked in the namespace)
.pkgnet_env <- new.env(parent = emptyenv())
.pkgnet_env$logger <- NULL

#' @keywords internal
.get_logger <- function() {
    if (is.null(.pkgnet_env$logger)) {
        .pkgnet_env$logger <- SimpleLogger$new()
    }
    return(.pkgnet_env$logger)
}

# [description] Log informational message
log_info <- function(msg, ...) {
    .get_logger()$info(msg = msg, ...)
    return(invisible(NULL))
}

# [description] Log warning and throw an R warning
log_warn <- function(msg, ...) {
    .get_logger()$warn(msg = msg, ...)
    warning(msg, call. = FALSE)
    return(invisible(NULL))
}

# [description] Log fatal error and throw an R exception
log_fatal <- function(msg, ...) {
    .get_logger()$fatal(msg = msg, ...)
    stop(msg, call. = FALSE)
}

# [description] Silence logger by setting threshold to 0
silence_logger <- function() {
    .get_logger()$set_threshold(0)
    return(invisible(NULL))
}

# [description] Unsilence logger by setting threshold to INFO level (4)
unsilence_logger <- function(thresh = 4) {
    .get_logger()$set_threshold(thresh)
    return(invisible(NULL))
}
