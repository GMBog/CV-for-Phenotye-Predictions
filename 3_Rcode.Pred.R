#Prediction code using BGLR (under paralel job submission)
#RKHS linear kernel to perform GBLUP; RANDOM sampling to get TRAIN and TEST subsets; 

args <- commandArgs(trailingOnly = TRUE)
TRAIT <- as.numeric(args[1]); print(TRAIT)
SEED <- as.numeric(args[2]); print(SEED)
FOLD <- as.numeric(args[3]); print(FOLD)

library(BGLR)

# Read data after preGSf90
data <- read.table("~/dirfiles/data.dat", quote="\"", comment.char="")
data <- data[order(data$ID),]  #data should be ordered as the G matrix

# Define a table with fixed effects
XF1 <- data[,c(4,5)]
colnames(XF1) = c("cohort", "lact")

# Define a table with IDs and phenotypes
Y <- data[,c(7,TRAIT)]
colnames(Y) = c("id", "y")
y = round(Y[,2],3)

# Read G matrix computed using SNP markers
# It should be created beforehand to avoid the use of memory and time
G <- as.matrix(read.table("~/dirfiles/G_LinearK", quote="\"", comment.char=""))

# Read M matrix computed as crossproduct of CLR microbial abundances
M <- as.matrix(read.table("~/dirfiles/M_LinearK", quote="\"", comment.char=""))

# Number of animals
n <- nrow(data)

# Create equally size n folds for crossvalidation
nfolds <- 10

# Random sampling data
set.seed(SEED)
sample <- sample (1:n,replace=FALSE)                                     #sample at random from 1 to number of animals
list <- split(sample, sample(rep(1:nfolds), replace=FALSE))              #split at random samples into n folds
str(list)

# Create the testing set based on the FOLD argument
tst <- as.vector(unlist(list[FOLD], use.names=FALSE))            #convert list into vector and save the elements of each list
head(tst)

# Introduce NA for the individuals in the testing set
yNA <- y
yNA[tst] <- NA

# Setting predictors
# If the traits use have different models with fixed effects then is necessary to define here
if (TRAIT==1){

  ETA = list(list(K = M, model = "RKHS"),
             list(K = G, model = "RKHS"))

 } else {

  ETA = list(list(~factor(cohort) + factor(lact), data = XF1, model = "FIXED"),
           list(K = M, model = "RKHS"),
           list(K = G, model = "RKHS"))}

# Fitting the model
fm <- BGLR(y = yNA, 
           ETA = ETA, 
           nIter = 100000, 
           burnIn = 30000, 
           thin = 5, 
           saveAt = 'RKHS_Linear_')

save(fm, file = 'fm.rda')
str(fm)

# Assesment of predictive ability in TRN and TST data sets
# Predictive correlation (corP) and Mean-Squared Error of Predictions (MSEP)
corP_TRN <- cor(fm$yHat[-tst],y[-tst], method ="pearson")
corP_TST <- cor(fm$yHat[tst],y[tst], method ="pearson")
MSEP_TRN <- mean((y[-tst]-fm$yHat[-tst])^2)
MSEP_TST <- mean((y[tst]-fm$yHat[tst])^2)
yHat <- fm$yHat

regression <- lm(y[-tst]~fm$yHat[-tst])
slope_TRN <- regression$coefficients[2]
regression <- lm(y[tst]~fm$yHat[tst])
slope_TST <- regression$coefficients[2]
regression <- lm(y~fm$yHat)
slope <- regression$coefficients[2]

# Create a table with results
result <- cbind(corP_TRN, corP_TST, MSEP_TRN, MSEP_TST, y, yHat, slope_TRN, slope_TST, slope)

# Save results
file <- paste(paste0(paste0("Trait",TRAIT),"_LinearK_Out",SEED),FOLD,sep=".")
save(result,file = file)
