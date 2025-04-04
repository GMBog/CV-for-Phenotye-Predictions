
# Modules
require(BGLR)
require(MASS)

rm(list = ls())

# Load data and relationship matrix
phenotype_data <- readr::read.table("/Data.dat", header = TRUE)
G_matrix <- as.matrix(readr::read.table("G.mat", header = FALSE, sep = "", quote = ""))

# Define the arguments
args <- commandArgs(trailingOnly = TRUE)
seed <- as.numeric(args[1]); print(seed)

# Assign phenotypes and random matrices
Y <- phenotype_data[,2]
X <- phenotype_data[, c(4,5)]
G <- G_matrix

# Define number of folds
nfolds <- 10

# Define the number of iterations, burnin, and thin (or interval)
niter <- 30000
burnin <- 5000
thin <- 2 

root <- '/Results'

set.seed(seed)
FixColNam <- c('col1', 'col2')
stopifnot(ncol(X) == 2)
colnames(X) <- FixColNam

n <- length(Y)

# Define the effects in the model
ETA0 <- list(list(~factor(col1) + factor(col2), data = X, model = 'FIXED'),
             list(K = G, model = 'RKHS'))

# Split data in folds (random process)
s <- sample(1:n)
l <- split(s, sample(rep(1:nfolds)))

f0 <- paste0('RKHS_Linear_', seed, '_')
f1 <- file.path(root, f0)

seq_idx <- 1:nfolds
idx = 1 ##
for (idx in seq_idx) {
  cat('6.1.', idx,  '\n')
  tst <- l[[idx]]
  yNA <- Y
  yNA[tst] <- NA
  outn <- paste0(f1, idx, '.out')
  cat('6.2.', idx,  '\n')
  cat('outn: \n ', outn, '\n')
  
  # Run the model in BGLR
  fm <- BGLR(y = yNA, 
             ETA = ETA0, 
             nIter = niter, 
             burnIn = burnin, 
             thin = thin, 
             saveAt = outn)
  cat('6.3.', idx,  '\n')
  fn <- paste0('fm_', idx, '.rda')
  fp <- file.path(root, fn)
  save(fm, file = fp)
  
  # Compute correlation between predicted and observed
  corP_TRN <- cor(fm$yHat[-tst],Y[-tst], method = "pearson")
  corP_TST <- cor(fm$yHat[tst],Y[tst], method = "pearson")
  MSEP_TRN <- mean((Y[-tst]-fm$yHat[-tst])^2)
  MSEP_TST <- mean((Y[tst]-fm$yHat[tst])^2)
  
  # Compute regression and slope of the model
  regression <- lm(Y[-tst]~fm$yHat[-tst])
  slope_TRN <- regression$coefficients[2]
  regression <- lm(Y[tst]~fm$yHat[tst])
  slope_TST <- regression$coefficients[2]
  regression <- lm(Y~fm$yHat)
  slope <- regression$coefficients[2]
  
  # Save results
  cat('6.4.', idx,  '\n')
  res1 <- cbind(Y, fm$yHat)
  colnames(res1) <- c('Y', 'YH')
  res2 <- cbind(corP_TRN, corP_TST, MSEP_TRN, MSEP_TST, slope_TRN, slope_TST, slope)
  rownames(res2) = 1
  
  fn1 = paste0('f1_s', seed, '_f', idx, '.RDS')
  fn2 = paste0('f2_s', seed, '_f', idx, '.RDS')
  fp1 = file.path(root, fn1)
  fp2 = file.path(root, fn2)
  cat('6.5.', idx,  '\n')
  saveRDS(res1,file = fp1)
  print(res2)
  saveRDS(res2,file = fp2)
}


