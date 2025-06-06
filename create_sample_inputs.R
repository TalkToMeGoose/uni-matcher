# Script to create data/sample_inputs.rda
# Please run this script from your R console when your working directory is the root of the 'uniMatcher' project.
# You can run it using the command: source("create_sample_inputs.R")

message("Attempting to create data/sample_inputs.rda...")

sample_inputs <- c(
  "University of Cambridge",
  "MIT",
  "ETH Zurich",
  "Sorbonne Université",
  "Universität Heidelberg",
  "Univerza v Ljubljani",
  "Politecnico di Milano",
  "Universiteit van Amsterdam",
  "Universitetet i Oslo",
  "A Completely Made Up University Name"
)

# Ensure the data directory exists relative to the project root
data_dir <- file.path(getwd(), "data")
if (!dir.exists(data_dir)) {
  message(paste("Creating directory:", data_dir))
  dir.create(data_dir, recursive = TRUE)
}

rda_file_path <- file.path(data_dir, "sample_inputs.rda")

tryCatch({
  save(sample_inputs, file = rda_file_path)
  message(paste("Successfully created:", rda_file_path))
}, error = function(e) {
  message(paste("Error creating .rda file:", e$message))
  message("Please ensure your working directory is set to the 'uniMatcher' project root.")
})
