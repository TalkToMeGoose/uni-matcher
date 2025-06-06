# clean_strings.R
# Text normalisation and helper functions

#' Clean a character string
#'
#' This function converts a string to ASCII, lowercases it, removes punctuation,
#' and squashes multiple spaces into single spaces.
#'
#' @param x A character string.
#' @return A cleaned character string.
#' @examples
#' # clean_string("  Université  de Genève!! ")
#' @importFrom stringi stri_trans_general
#' @export
clean_string <- function(x) {
  if (!is.character(x)) stop("Input must be a character string.")
  if (length(x) == 0) return("")
  if (is.na(x)) return(NA_character_)

  # Unicode → ASCII
  x_ascii <- stringi::stri_trans_general(x, "Latin-ASCII")
  
  # Lowercase
  x_lower <- tolower(x_ascii)
  
  # Replace punctuation with space (to handle cases like "word-word" becoming "word word")
  x_no_punct <- gsub("[[:punct:]]", " ", x_lower)
  
  # Squash multiple spaces into single spaces
  x_squashed <- gsub("\\s+", " ", x_no_punct)
  
  # Trim leading/trailing whitespace
  x_trimmed <- trimws(x_squashed)
  
  return(x_trimmed)
}
