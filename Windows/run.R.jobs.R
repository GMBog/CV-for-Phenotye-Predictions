library(foreach)
library(doParallel)

# Define the number of cores (use detectCores() - 1 to leave one core free)
num_cores <- parallel::detectCores() - 1
cl <- makeCluster(num_cores*0.8)
registerDoParallel(cl)

# List of seeds
seeds <- c(123, 456, 10, 15, 8)
folds <- seq(1:10)

# Loop over seeds (sequential)
for (s in seeds) {
  cat("Running Seed:", s, "\n")
  
  # Folds 1 to 10 in parallel
  foreach(f = folds, .packages = c(), .export = c()) %dopar% {
    system(paste("Rscript Rcode.Pred.R", s, f))
  }
}

# Stop the cluster
stopCluster(cl)
