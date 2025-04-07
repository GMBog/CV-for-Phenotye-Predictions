library(foreach)
library(doParallel)

# Define the number of cores (use detectCores() - 1 to leave one core free)
num_cores <- parallel::detectCores() - 1
cl <- makeCluster(num_cores*0.8)
registerDoParallel(cl)

# List of seeds
seeds <- c(123, 456, 10, 15, 8)
folds <- seq(1:10)

# Loop over all combinations of seeds and folds
jobs <- expand.grid(seeds, folds)

# Run jobs in parallel
foreach(i = 1:nrow(jobs), .packages = c()) %dopar% {
  s <- jobs$seeds[i]
  f <- jobs$folds[i]
  system(paste("Rscript Rcode.Pred.R", s, f))
}

# Stop the cluster
stopCluster(cl)
