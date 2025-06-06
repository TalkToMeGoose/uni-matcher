# R/detect_lang.R
# Wrapper around textcat

#' Detect language of a text string
#'
#' Uses the textcat package to identify the language of the input string.
#' Returns a 2-letter ISO 639-1 language code for supported languages
#' (EN, DE, NL, IT, NO), or NA if detection fails or language is unsupported.
#'
#' @param x A character string.
#' @return A 2-letter language code (e.g., "en", "de") or NA.
#' @importFrom textcat textcat
#' @export
detect_lang <- function(x) {
  if (!is.character(x) || length(x) != 1 || nchar(x) == 0 || is.na(x)) {
    return(NA_character_)
  }

  # Supported languages and their textcat profile names (these might need adjustment)
  # textcat profiles can be checked with names(textcat::textcat_profile_db)
  # For this example, we assume some common profile names textcat might return.
  supported_langs_map <- c(
    "english" = "en",
    "german" = "de",
    "dutch" = "nl",
    "italian" = "it",
    "norwegian" = "no",
    # Add direct 2-letter codes as well, in case textcat returns them for some inputs
    "en" = "en",
    "de" = "de",
    "nl" = "nl",
    "it" = "it",
    "no" = "no"
  )

  lang_profile <- tryCatch({
    # textcat can return multiple profiles; we take the first one.
    profiles <- textcat::textcat(x)
    if (length(profiles) > 0) profiles[1] else NULL
  }, error = function(e) {
    # message(sprintf("Language detection by textcat failed for input '%s': %s", x, e$message))
    return(NULL)
  })

  if (is.null(lang_profile)) {
    return(NA_character_)
  }

  # Check if the detected profile is in our map
  lang_code <- supported_langs_map[tolower(lang_profile)]
  
  if (is.na(lang_code)) {
    # If not directly mapped, it might be an unsupported language or a variant
    # For now, we return NA if not in our specific list
    return(NA_character_)
  } else {
    return(unname(lang_code))
  }
}
