# R/match_fuzzy.R
# Fuzzy Jaro-Winkler match

#' Perform a fuzzy match for a university name
#'
#' Cleans the input string and computes the Jaro-Winkler similarity 
#' (1 - distance) against all aliases in the alias table. 
#' Returns the best match (canonical name and similarity score) if the score 
#' is above the specified threshold. Otherwise, returns NA.
#'
#' @param x A single character string (university name to match).
#' @param alias_tbl A data frame or tibble with at least 'alias' and 'canonical_name' columns.
#' @param threshold A numeric value between 0 and 1. Matches below this threshold are ignored.
#'                  Defaults to 0.85.
#' @return A tibble with columns: 'canonical_name', 'confidence_score', 'method'.
#'         Returns a tibble with NA values if no fuzzy match meets the threshold.
#' @importFrom stringdist stringsim
#' @importFrom dplyr mutate filter arrange desc slice_head select tibble
#' @export
match_fuzzy <- function(x, alias_tbl, threshold = 0.85) {
  if (!is.character(x) || length(x) != 1 || is.na(x) || nchar(x) == 0) {
    return(dplyr::tibble(canonical_name = NA_character_, confidence_score = NA_real_, method = "fuzzy"))
  }
  if (!is.data.frame(alias_tbl) || !all(c("alias", "canonical_name") %in% names(alias_tbl))) {
    stop("alias_tbl must be a data frame with 'alias' and 'canonical_name' columns.")
  }
  if (nrow(alias_tbl) == 0) {
    return(dplyr::tibble(canonical_name = NA_character_, confidence_score = NA_real_, method = "fuzzy"))
  }

  cleaned_x <- clean_string(x) # Assuming clean_string is available

  # Calculate Jaro-Winkler similarity with all aliases
  # As with direct matching, alias_tbl$alias could be pre-cleaned or cleaned on the fly.
  # For this example, let's assume alias_tbl$alias is NOT pre-cleaned.
  # Note: stringdist functions work well even with minor variations, so cleaning the target (alias_tbl$alias)
  # might not always be strictly necessary for fuzzy matching but can improve consistency.

  # Create a temporary column with cleaned aliases for matching
  # This is computationally more intensive on the fly but ensures consistent comparison
  temp_alias_tbl <- alias_tbl %>%
    dplyr::mutate(cleaned_alias_for_fuzzy = sapply(alias, clean_string))

  # Calculate similarity scores
  # stringsim returns similarity (1 - distance)
  similarities <- stringdist::stringsim(cleaned_x, temp_alias_tbl$cleaned_alias_for_fuzzy, method = "jw", p = 0.1)
  
  # Add similarities to the temporary table
  temp_alias_tbl$similarity_score <- similarities

  # Find the best match above the threshold
  best_match <- temp_alias_tbl %>%
    dplyr::filter(similarity_score >= threshold) %>%
    dplyr::arrange(dplyr::desc(similarity_score)) %>%
    dplyr::slice_head(n = 1) # Get the top match

  if (nrow(best_match) > 0) {
    return(dplyr::tibble(
      canonical_name = best_match$canonical_name,
      confidence_score = best_match$similarity_score,
      method = "fuzzy"
    ))
  } else {
    return(dplyr::tibble(
      canonical_name = NA_character_,
      confidence_score = NA_real_, # Or perhaps the best score found, even if below threshold, for diagnostics?
                                   # Prompt implies NA if below threshold.
      method = "fuzzy"
    ))
  }
}
