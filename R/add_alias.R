# R/add_alias.R
# Append new alias safely

#' Add a new alias to the alias table
#'
#' Appends a new alias and its corresponding canonical name to the alias table CSV.
#' It detects the language of the new alias and avoids adding duplicate entries
#' (based on the combination of alias, canonical_name, and lang).
#'
#' @param new_alias A character string, the new alias to add.
#' @param canonical_name A character string, the canonical name for this alias.
#' @param alias_tbl_path The file path to the alias table CSV file.
#' @return Invisibly returns TRUE if the alias was added or already existed with the same canonical name and lang,
#'         FALSE if there was an error or invalid input.
#' @importFrom dplyr tibble filter anti_join
#' @importFrom readr read_csv write_csv
#' @importFrom fs file_exists
#' @export
add_alias <- function(new_alias, canonical_name, alias_tbl_path) {
  if (!is.character(new_alias) || length(new_alias) != 1 || nchar(trimws(new_alias)) == 0 || is.na(new_alias)) {
    warning("Invalid 'new_alias' provided.")
    return(invisible(FALSE))
  }
  if (!is.character(canonical_name) || length(canonical_name) != 1 || nchar(trimws(canonical_name)) == 0 || is.na(canonical_name)) {
    warning("Invalid 'canonical_name' provided.")
    return(invisible(FALSE))
  }
  if (!is.character(alias_tbl_path) || length(alias_tbl_path) != 1) {
    warning("Invalid 'alias_tbl_path' provided.")
    return(invisible(FALSE))
  }

  # Detect language of the new alias
  lang_detected <- detect_lang(new_alias)
  if (is.na(lang_detected)) {
    warning(paste("Could not detect language for alias:", new_alias, "- alias not added."))
    # Or, default to a specific lang or allow user to specify? For now, skip if NA.
    # lang_detected <- "und" # Undetermined, if we want to add it anyway
    return(invisible(FALSE))
  }

  new_entry <- dplyr::tibble(
    alias = trimws(new_alias),
    canonical_name = trimws(canonical_name),
    lang = lang_detected
  )

  # Load existing alias table or create a new tibble if file doesn't exist
  if (fs::file_exists(alias_tbl_path)) {
    existing_aliases <- tryCatch({
      readr::read_csv(alias_tbl_path, col_types = readr::cols(alias="c", canonical_name="c", lang="c"), show_col_types = FALSE)
    }, error = function(e) {
      warning(paste("Error reading alias table:", e$message, "- creating a new one if possible or failing."))
      # If read fails, treat as if table is empty or handle error more gracefully
      dplyr::tibble(alias = character(), canonical_name = character(), lang = character())
    })
    if (!all(c("alias", "canonical_name", "lang") %in% names(existing_aliases))){
        warning("Alias table is missing required columns: 'alias', 'canonical_name', 'lang'. Cannot add new alias.")
        # Potentially re-initialize with new_entry if columns are bad, or just fail.
        existing_aliases <- dplyr::tibble(alias = character(), canonical_name = character(), lang = character())
    }
  } else {
    existing_aliases <- dplyr::tibble(alias = character(), canonical_name = character(), lang = character())
  }

  # Check for duplicates (exact match of alias, canonical_name, and lang)
  is_duplicate <- nrow(dplyr::inner_join(existing_aliases, new_entry, by = c("alias", "canonical_name", "lang"))) > 0
  
  # A more nuanced check: what if the alias exists but for a DIFFERENT canonical_name?
  # This could be a conflict. For now, we only check for exact duplicates of the full entry.
  # existing_alias_conflict <- new_entry$alias %in% existing_aliases$alias && 
  #                            !(new_entry$canonical_name %in% existing_aliases$canonical_name[existing_aliases$alias == new_entry$alias])
  # if (existing_alias_conflict) {
  #   warning(paste("Alias '", new_entry$alias, "' already exists with a different canonical name. Not adding."))
  #   return(invisible(FALSE))
  # }

  if (is_duplicate) {
    # message(paste("Alias '", new_alias, "' for '", canonical_name, "' (lang: ", lang_detected, ") already exists.", sep=""))
    return(invisible(TRUE)) # Considered success as the entry is present
  } else {
    updated_aliases <- dplyr::bind_rows(existing_aliases, new_entry)
    tryCatch({
      readr::write_csv(updated_aliases, alias_tbl_path)
      # message(paste("Added alias: '", new_alias, "' -> '", canonical_name, "' (lang: ", lang_detected, ")", sep=""))
      return(invisible(TRUE))
    }, error = function(e) {
      warning(paste("Error writing updated alias table:", e$message))
      return(invisible(FALSE))
    })
  }
}
