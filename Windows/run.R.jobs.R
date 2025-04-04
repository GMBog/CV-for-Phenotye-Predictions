library(foreach)
library(doParallel)

# Define the number of cores (use detectCores() - 1 to leave one core free)
num_cores <- parallel::detectCores() - 1
cl <- makeCluster(num_cores*0.8)
registerDoParallel(cl)

# List of seeds
seeds <- c(123, 456, 10, 15, 8)

# Run in parallel
foreach(s = seeds) %dopar% {
  system(paste("Rscript Rcode.Pred.R", s))  # Runs separate R processes
}

# Stop the cluster
stopCluster(cl)
