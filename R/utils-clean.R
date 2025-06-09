clean_string <- function(x) {
  if (!is.character(x)) {
    stop("Input must be a character string.")
  }
  if (length(x) == 0) {
    return("")
  }
  if (is.na(x)) {
    return(NA_character_)
  }

  x |>
    stringi::stri_trans_general("Latin-ASCII") |>
    tolower() |>
    (\(s) gsub("[[:punct:]]", " ", s))() |>
    stringr::str_squish()
}
