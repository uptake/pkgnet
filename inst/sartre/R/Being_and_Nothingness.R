#' @title nothing
#' @name somethingAboutNothing
#'
#' @return nothingness
#' @export
#' @examples \dontrun{NULL}
somethingAboutNothing <- function() {
  quoteBook <- c('Nothingness lies coiled in the heart of being - like a worm.'
                 , 'I exist, that is all, and I find it nauseating.'
                 , 'Thus it amounts to the same thing whether one gets drunk alone or is a leader of nations.'
                 , 'Temporality is obviously an organised structure, and these three so-called elements of time: past, present, future, must not be envisaged as a collection of "data" to be added together...but as the structured moments of an original synthesis. Otherwise we shall immediately meet with this paradox: the past is no longer, the future is not yet, as for the instantaneous present, everyone knows that it is not at all: it is the limit of infinite division, like the dimensionless point.'
  )
  
  return(sample(quoteBook
                , size = 1
                , prob = c(2
                           ,rep(1, length(quoteBook) - 1) 
                           ) / length(quoteBook)
                )
         )
}
