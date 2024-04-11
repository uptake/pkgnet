
#' @title At-bats
#' @name at_bats
#' @description Given the outcomes of plate appearances, calculate player's
#'              at-bats.
#' @family Batting Statistics
#' @param outcomes Character vector of valid outcomes for a plate appearance
#' @export
#' @references \href{https://en.wikipedia.org/wiki/Baseball_statistics}{baseball statistics}
at_bats <- function(outcomes){
    
    out_val <- sum(outcomes %in% c('1b', '2b', '3b', 'hr', 'k',
                                   'po', 'go', 'lo', 'fo'))
    return(out_val)
}


#' @title Batting Average
#' @name batting_avg
#' @description Given the outcomes of plate appearances, calculate player's
#'              batting average.
#' @family Batting Statistics
#' @param outcomes Character vector of valid outcomes for a plate appearance
#' @export
#' @references \href{https://en.wikipedia.org/wiki/Baseball_statistics}{baseball statistics}
batting_avg <- function(outcomes){

    if (length(outcomes) == 0){
        return(NA_real_)
    }

    
    hits <- sum(outcomes %in% c('1b', '2b', '3b', 'hr'))
    return(hits / at_bats(outcomes))
}


#' @title On Base Percentage
#' @name on_base_pct
#' @description Given the outcomes of plat appearances, calculate player's
#'              on base percentage.
#' @family Batting Statistics
#' @param outcomes Character vector of valid outcomes for a plate appearance
#' @export
#' @references \href{https://en.wikipedia.org/wiki/Baseball_statistics}{baseball statistics}
on_base_pct <- function(outcomes){

    if (length(outcomes) == 0){
        return(NA_real_)
    }

    appearances <- length(outcomes)
    reaches <- sum(outcomes %in% c('bb', '1b', '2b', '3b', 'hr', 'hbp', 'fc'))
    obp <- reaches / appearances

    return(obp)
}


#' @title Slugging average
#' @name slugging_avg
#' @description Given the outcomes of plat appearances, calculate player's
#'              slugging average.
#' @family Batting Statistics
#' @param outcomes Character vector of valid outcomes for a plate appearance
#' @export
#' @references \href{https://en.wikipedia.org/wiki/Baseball_statistics}{baseball statistics}
slugging_avg <- function(outcomes){

    if (length(outcomes) == 0){
        return(NA_real_)
    }

    bases_on_hits <- {1 * sum(outcomes == '1b') +
                      2 * sum(outcomes == '2b') +
                      3 * sum(outcomes == '3b') +
                      4 * sum(outcomes == 'hr')
                     }
    
    denom <- do.call("at_bats", outcomes)
    return(bases_on_hits / denom)
}


#' @title On-base Percentage
#' @name ops
#' @description Given the outcomes of plat appearances, calculate player's
#'              on base plus slugging (OPS).
#' @family Batting Statistics
#' @param outcomes Character vector of valid outcomes for a plate appearance
#' @export
#' @references \href{https://en.wikipedia.org/wiki/Baseball_statistics}{baseball statistics}
OPS <- function(outcomes){

    if (length(outcomes) == 0){
        return(NA_real_)
    }

    return(slugging_avg(outcomes) + batting_avg(outcomes))
}
