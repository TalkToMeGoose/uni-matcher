clean_string <- function(x){
  x |>
    stringi::stri_trans_general("Latin-ASCII") |>
    tolower() |>
    gsub("[^a-z0-9\\s]", " ", x = _) |>
    stringr::str_squish()
}
