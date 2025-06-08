# data-raw/make-alias-data.R
library(dplyr); library(readr); library(usethis)

aliases <- read_csv("data-raw/whed_aliases.csv",
                    show_col_types = FALSE) |>
  mutate(across(everything(), ~trimws(.x)))

# save compressed .rda object inside data/ for package use
use_data(aliases, overwrite = TRUE)
