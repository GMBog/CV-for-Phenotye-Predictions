library(BGLR)

rm(list = ls()) # initialization

# Open the data set with Animal ID, fixed effects, and phenotypes
data <- readr::read_table("pheno.dat")
data <- data[order(data$Key), ]

## CV nfolds
nfolds <- 10 # Number of folds (in how many parts we will split our data)
repl <- 5 # Number of replicate (hoe many times we will replicate the random process)

# Phenotype (y)
y <- data$TRAIT


# Read matrices with Genomic and/or Spectra data
## Genomic relationship matrix
G <- as.matrix(read.table("G_LinearK", header = FALSE, sep = ""))
rownames(G) <- data$Key

## Milk Spectral data
S <- scale(data[, 49:1107])
row.names(S) <- data$Key

# Checking prior distributions for Spectra and Genome data
nIter <- 10000
burnIn <- 2000

# Test two different prior-distributions for spectral data
## Bayes Ridge Regression (BRR)
fmBRR <- BGLR(
  y = y, ETA = list(list(X = S, model = "BRR")),
  nIter = nIter, burnIn = burnIn, saveAt = "brr_"
)
plot(abs(fmBRR$ETA[[1]]$b), col = 4, cex = 0.5, type = "o", main = "BRR")

## Bayes B (BB)
fmBB <- BGLR(
  y = y, ETA = list(list(X = S, model = "BayesB")),
  nIter = nIter, burnIn = burnIn, saveAt = "bb_"
)
plot(abs(fmBB$ETA[[1]]$b), col = 4, cex = 0.5, type = "o", main = "BayesB")


# Cross-Validation code

n <- nrow(data) # Number of animals
nfolds <- 10    # Create equally size n folds

# Random sampling data (the number of SEED will determine the number of replicates)
SEED <- c(123)
set.seed(SEED)
sample <- sample(1:n, replace = FALSE)

# Create a list with the splitted data
list <- split(sample, sample(rep(1:nfolds), replace = FALSE))
str(list)

# Define the current fold index for iteration (in parallel should be placed outside) 
FOLD <- 5  

# Extract the elements of the specified fold as a vector
tst <- as.vector(unlist(list[FOLD], use.names = FALSE))  
head(tst)  

# Create a testing set
yNA <- y
yNA[tst] <- NA

# Setting predictors
nIter <- 6000
burnIn <- 1000
thin <- 5

## Model XB
fm <- BGLR(
  y = y, ETA = list(list(~ factor(cohort) + factor(DIM), data = data, model = "FIXED")),
  nIter = nIter, burnIn = burnIn, saveAt = "FIXED_"
)

## Model G
fm <- BGLR(
  y = y, ETA = list(
    list(~ factor(cohort) + factor(DIM), data = data, model = "FIXED"),
    list(K = G, model = "RKHS")
  ),
  nIter = nIter, burnIn = burnIn, saveAt = "RKHS_"
)

## Model G+S
fm <- BGLR(
  y = yNA, ETA = list(
    list(~ factor(cohort) + factor(DIM), data = data, model = "FIXED"),
    list(K = G, model = "RKHS"),
    list(X = S, model = "BayesB")
  ),
  nIter = nIter, burnIn = burnIn, saveAt = "bb_"
)

str(fm)

# Assesment of predictive ability in TRN and TST data sets
corP_TRN = cor(fm$yHat[-tst],y[-tst])
corP_TST <- cor(fm$yHat[tst], y[tst])
corS_TRN = cor(fm$yHat[-tst],y[-tst], method = "spearman")
corS_TST <- cor(fm$yHat[tst], y[tst], method = "spearman")
MSE_TRN = mean((y[-tst]-fm$yHat[-tst])^2)
MSE_TST <- mean((y[tst] - fm$yHat[tst])^2)

# Check the goodness-of-fit of the model and output
fm$fit

# Create a table with the results from the CV
result <- cbind(corP_TRN, corP_TST, corS_TRN, corS_TST, MSE_TRN, MSE_TST, y, fm$yHat)

# Save the results table
file <- paste(paste("Out", SEED, sep = ""), FOLD, sep = ".")
save(result, file = file)
