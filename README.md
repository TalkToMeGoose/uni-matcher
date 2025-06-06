# uniMatcher R Package

`uniMatcher` is an R package designed to canonicalise university and research organisation names across multiple languages (EN, DE, NL, IT, NO). It uses a combination of direct matching against known aliases and fuzzy matching for new or variant names.

## Features

*   Text normalization (Unicode to ASCII, lowercase, punctuation removal).
*   Language detection for input strings.
*   Direct matching against a curated list of aliases.
*   Fuzzy matching using Jaro-Winkler distance.
*   Functions to manage canonical names and aliases.
*   A Shiny application for interactive matching, review, and alias updating.

## Installation

```r
# Ensure devtools is installed
# if (!requireNamespace("devtools", quietly = TRUE)) {
#   install.packages("devtools")
# }

# Install uniMatcher from GitHub (once pushed)
# devtools::install_github("yourusername/uniMatcher")

# Or, if working locally:
devtools::install(".") 
```

## Quick Start

1.  Install the package (see above).
2.  Load the library:
    ```r
    library(uniMatcher)
    ```
3.  Prepare your input names. For example:
    ```r
    input_names <- c("TU Munchen", "Università di Bologna", "Uni Kassel", "Made-Up College")
    ```
4.  Run the matching function:
    ```r
    # Load default canonical and alias tables (these functions will be created)
    # canonical_data <- canonical_tbl()
    # alias_data <- alias_tbl()

    # For now, let's assume these files are read directly or placeholder functions exist
    # matched_results <- match_unis(input_names, canonical_data, alias_data)
    # print(matched_results)
    
    # Example with placeholder data (actual data loading needs implementation)
    # This is a conceptual example; actual function calls might differ slightly
    # based on how canonical_tbl() and alias_tbl() are implemented.
    cat("Quick start example will be fully runnable once data loading functions are implemented.\n")
    cat("Conceptual usage:\n")
    cat("matched_results <- match_unis(c('TU Munchen', 'Università di Bologna'), canonical_tbl(), alias_tbl())\n")
    ```

5.  Launch the Shiny GUI:
    ```r
    # shiny::runApp(system.file("app", package = "uniMatcher"))
    cat("Shiny app launch: shiny::runApp(system.file('app', package = 'uniMatcher'))\n")
    ```

## Core Functions

*   `match_unis()`: Main function to match a vector of names.
*   `add_alias()`: Add a new alias to the alias table.
*   `clean_string()`: (Internal) Normalizes input strings.
*   `detect_lang()`: (Internal) Detects the language of a string.

## Data Files

The package relies on two key CSV files stored in `inst/extdata/`:

*   `canonical_unis.csv`: Contains the list of canonical university names, ROR IDs, and countries.
*   `alias_table.csv`: Contains known aliases, their corresponding canonical names, and detected language.

## Contributing

(Placeholder for contribution guidelines)

## License

This package is released under the MIT License. See the `LICENSE` file for details.
