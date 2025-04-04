#Script to compile results from CV105

# Define the root directory
root <- '/Results'

# List all files matching the pattern "f2_*.RDS"
files <- list.files(path = root, pattern = "^f2_.*\\.RDS$", recursive = TRUE, full.names = TRUE)

Outs <- list()
for (i in 1:length(files)) {
  tryCatch({
    res2 <- readRDS(files[i])  # Using readRDS() for .RDS files
    Outs[[i]] <- res2
  }, error = function(e) {
    cat("Error loading file:", files[i], "\n")
  })
}

Outs_df <- do.call(rbind, Outs)
