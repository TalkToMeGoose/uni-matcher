# R/match_unis.R
# Exported function; ties everything together

#' Match university names
#'
#' Takes a vector of university names and attempts to match them against
#' canonical and alias tables. It uses direct matching first, then fuzzy matching.
#'
#' @param x_vec A character vector of university names to match.
#' @param canonical_tbl A data frame or tibble with canonical university names.
#'                      (Currently unused in this direct/fuzzy logic based on alias_tbl,
#'                       but kept as per prompt for potential future use or if logic changes).
#' @param alias_tbl A data frame or tibble with 'alias' and 'canonical_name' columns.
#' @param threshold A numeric value (0-1) for fuzzy matching. Defaults to 0.85.
#' @return A tibble with columns: 'input_name', 'canonical_name', 
#'         'confidence_score', 'method', 'lang_detected'.
#' @importFrom dplyr tibble bind_rows mutate rowwise
#' @importFrom purrr map_dfr
#' @export
match_unis <- function(x_vec, canonical_tbl, alias_tbl, threshold = 0.85) {
  
  if (!is.character(x_vec)) {
    stop("Input x_vec must be a character vector.")
  }
  # Placeholder for canonical_tbl check if it becomes actively used
  # if (!is.data.frame(canonical_tbl)) {
  #   stop("canonical_tbl must be a data frame.")
  # }
  if (!is.data.frame(alias_tbl) || !all(c("alias", "canonical_name") %in% names(alias_tbl))) {
    stop("alias_tbl must be a data frame with 'alias' and 'canonical_name' columns.")
  }

  results_list <- lapply(x_vec, function(single_x) {
    if (is.na(single_x) || nchar(trimws(single_x)) == 0) {
      return(dplyr::tibble(
        input_name = single_x,
        canonical_name = NA_character_,
        confidence_score = NA_real_,
        method = "invalid_input",
        lang_detected = NA_character_
      ))
    }

    # 1. Clean (original string for lang detection, cleaned for matching)
    # Language detection should ideally happen on the original, less processed string.
    detected_lang <- detect_lang(single_x) # Uses detect_lang.R
    # cleaned_input_for_match <- clean_string(single_x) # Uses clean_strings.R - done inside match_direct/fuzzy

    # 2. Try direct match
    # match_direct expects the raw single_x, it will clean it internally
    direct_match_result <- match_direct(single_x, alias_tbl) # Uses match_direct.R

    if (!is.na(direct_match_result$canonical_name)) {
      return(dplyr::tibble(
        input_name = single_x,
        canonical_name = direct_match_result$canonical_name,
        confidence_score = direct_match_result$confidence_score,
        method = direct_match_result$method,
        lang_detected = detected_lang
      ))
    } else {
      # 3. Else, try fuzzy match
      # match_fuzzy expects raw single_x, it will clean it internally
      fuzzy_match_result <- match_fuzzy(single_x, alias_tbl, threshold = threshold) # Uses match_fuzzy.R

      if (!is.na(fuzzy_match_result$canonical_name)) {
        return(dplyr::tibble(
          input_name = single_x,
          canonical_name = fuzzy_match_result$canonical_name,
          confidence_score = fuzzy_match_result$confidence_score,
          method = fuzzy_match_result$method,
          lang_detected = detected_lang
        ))
      } else {
        # 4. Else, flag as unmatched
        # If fuzzy match also fails (returns NA canonical_name), we report the best score it found if available,
        # or NA if it didn't even attempt (e.g. empty input to fuzzy_match). 
        # The current match_fuzzy returns NA score if below threshold.
        return(dplyr::tibble(
          input_name = single_x,
          canonical_name = NA_character_,
          confidence_score = fuzzy_match_result$confidence_score, # This will be NA if no match above threshold
          method = "unmatched",
          lang_detected = detected_lang
        ))
      }
    }
  })

  # Combine list of tibbles into a single tibble
  final_results <- dplyr::bind_rows(results_list)
  
  return(final_results)
}
