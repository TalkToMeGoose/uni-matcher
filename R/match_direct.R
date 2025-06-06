# R/match_direct.R
# Exact / alias match

#' Perform a direct match for a university name
#'
#' Cleans the input string and attempts to find an exact match in the 'alias' 
#' column of the alias table. If a match is found, it returns the corresponding
#' canonical name and a confidence score of 1.
#'
#' @param x A single character string (university name to match).
#' @param alias_tbl A data frame or tibble with at least two columns: 
#'                  'alias' (the alias name) and 'canonical_name'.
#'                  It's assumed 'alias' column in alias_tbl is already cleaned 
#'                  or will be cleaned similarly for comparison.
#' @return A tibble with columns: 'canonical_name', 'confidence_score', 'method'. 
#'         Returns a tibble with NA values if no direct match is found.
#' @importFrom dplyr filter select pull tibble
#' @export
match_direct <- function(x, alias_tbl) {
  if (!is.character(x) || length(x) != 1 || is.na(x) || nchar(x) == 0) {
    return(dplyr::tibble(canonical_name = NA_character_, confidence_score = NA_real_, method = "direct"))
  }
  if (!is.data.frame(alias_tbl) || !all(c("alias", "canonical_name") %in% names(alias_tbl))) {
    stop("alias_tbl must be a data frame with 'alias' and 'canonical_name' columns.")
  }

  cleaned_x <- clean_string(x) # Assuming clean_string is available

  # For direct matching, we often assume the alias_tbl 'alias' column is also pre-cleaned
  # or we clean it on the fly. For simplicity here, let's assume it's pre-cleaned.
  # If not, one would do: alias_tbl$cleaned_alias <- sapply(alias_tbl$alias, clean_string)
  # and match against cleaned_alias.
  # For this implementation, we'll match against the provided 'alias' column directly,
  # assuming it's appropriately prepared or that clean_string(x) will match it.
  
  # A more robust direct match might clean the alias_tbl$alias on the fly if it's not guaranteed to be clean
  # However, for performance with large alias tables, pre-cleaning is better.
  # Let's assume alias_tbl$alias is NOT pre-cleaned for this example to show the process.
  
  match_result <- alias_tbl %>%
    dplyr::mutate(cleaned_alias_col = sapply(alias, clean_string)) %>%
    dplyr::filter(cleaned_alias_col == cleaned_x) %>%
    dplyr::select(canonical_name) %>%
    dplyr::slice_head(n = 1) # Take the first match if multiple exist for some reason

  if (nrow(match_result) > 0) {
    return(dplyr::tibble(
      canonical_name = match_result$canonical_name,
      confidence_score = 1.0,
      method = "direct"
    ))
  } else {
    return(dplyr::tibble(
      canonical_name = NA_character_,
      confidence_score = NA_real_,
      method = "direct" # Still indicates an attempt was made via direct matching
    ))
  }
}
