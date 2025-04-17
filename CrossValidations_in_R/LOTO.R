# Leave One Trial Out (LOTO)

# Phenotype (y)
y <- data$TRAIT

# Read matrices with Genomic and Spectral data

## Genomic relationship matrix
G <- as.matrix(read.table("G_LinearK", header = FALSE, sep = ""))
rownames(G) <- data$Key

## Spectral data
S <- scale(data[, 49:1107])
row.names(S) <- data$Key

# Set seed for reproducibility
SEED <- 123
set.seed(SEED)

# Assuming your data frame is named 'data' and you have a response vector 'y'
# Split data by Trial
Trials <- data$Experiment
split_data <- split(data, Trials)

## Select one of the trials and create the testing set
trial <- unique(data$Experiment)[3]
tst <- which(data$Experiment == trial)

# Create a copy of 'y' and replace test set indices with NA
yNA <- y
yNA[tst] <- NA

### Setting predictors
nIter <- 6000
burnIn <- 1000

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
corP_TRN <- cor(fm$yHat[-tst], y[-tst])
corP_TST <- cor(fm$yHat[tst], y[tst])
corS_TRN <- cor(fm$yHat[-tst], y[-tst], method = "spearman")
corS_TST <- cor(fm$yHat[tst], y[tst], method = "spearman")
MSE_TRN <- mean((y[-tst] - fm$yHat[-tst])^2)
MSE_TST <- mean((y[tst] - fm$yHat[tst])^2)

# Check the goodness-of-fit of the model and output
fm$fit

# Create a table with the results from the CV
result <- cbind(corP_TRN, corP_TST, corS_TRN, corS_TST, MSE_TRN, MSE_TST, y, fm$yHat)

# Save the results table
file <- paste(paste("Out", SEED, sep = ""), FOLD, sep = ".")
save(result, file = file)
