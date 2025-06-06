# R/utils_io.R
# Load/save alias & canonical tables

#' Load the canonical universities table
#'
#' Loads the 'canonical_unis.csv' file bundled with the package.
#'
#' @return A tibble containing the canonical university data, or an empty tibble
#'         if the file is not found or cannot be read.
#' @importFrom readr read_csv cols
#' @importFrom dplyr tibble
#' @export
canonical_tbl <- function() {
  path <- system.file("extdata", "canonical_unis.csv", package = "uniMatcher")
  if (path == "") {
    warning("canonical_unis.csv not found in package 'extdata' directory.")
    return(dplyr::tibble(canonical_name = character(), ror_id = character(), country = character()))
  }
  tryCatch({
    readr::read_csv(path, col_types = readr::cols(
      canonical_name = "c",
      ror_id = "c",
      country = "c"
    ), show_col_types = FALSE)
  }, error = function(e) {
    warning(paste("Error reading canonical_unis.csv:", e$message))
    return(dplyr::tibble(canonical_name = character(), ror_id = character(), country = character()))
  })
}

#' Load the alias table
#'
#' Loads the 'alias_table.csv' file bundled with the package.
#'
#' @return A tibble containing the alias data, or an empty tibble
#'         if the file is not found or cannot be read.
#' @importFrom readr read_csv cols
#' @importFrom dplyr tibble
#' @export
alias_tbl <- function() {
  path <- system.file("extdata", "alias_table.csv", package = "uniMatcher")
  if (path == "") {
    warning("alias_table.csv not found in package 'extdata' directory.")
    return(dplyr::tibble(alias = character(), canonical_name = character(), lang = character()))
  }
  tryCatch({
    readr::read_csv(path, col_types = readr::cols(
      alias = "c",
      canonical_name = "c",
      lang = "c"
    ), show_col_types = FALSE)
  }, error = function(e) {
    warning(paste("Error reading alias_table.csv:", e$message))
    return(dplyr::tibble(alias = character(), canonical_name = character(), lang = character()))
  })
}

# Note: A function to save/update these tables (especially alias_table.csv)
# might be needed if changes are made programmatically outside of add_alias.
# add_alias directly writes to the CSV, which is one approach.
# For now, only loaders are explicitly requested for utils_io.R beyond add_alias.
