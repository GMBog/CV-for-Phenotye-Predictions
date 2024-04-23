#Prediction code using BGLR (under paralel job submission)
#RKHS linear kernel to perform GBLUP; RANDOM sampling to get TRAIN and TEST subsets; 

args <- commandArgs(trailingOnly = TRUE)
TRAIT <- as.numeric(args[1]); print(TRAIT)
SEED <- as.numeric(args[2]); print(SEED)
FOLD <- as.numeric(args[3]); print(FOLD)

library(BGLR)

### Read data after preGSf90
data <- read.table("~/dirfiles/data_BGLR/renf90.dat", quote="\"", comment.char="")
data <- data[order(data$V7),]  #data should be ordered as the G matrix

### Read phenotypic data and fixed effects

XF1 <- data[,c(4,5)]; colnames(XF1) = c("cohort", "lact")  #fixed effects

Y <- data[,c(7,TRAIT)]; colnames(Y) = c("id", "y"); y = round(Y[,2],3)


### G matrix computed using SNPs

G <- as.matrix(read.table("~/dirfiles/data_BGLR/Kernels/G_LinearK", quote="\"", comment.char=""))

### Read M matrix as crossproduct of CLR microbial abundances

M <- as.matrix(read.table("~/dirfiles/data_BGLR/Kernels/M_LinearK", quote="\"", comment.char=""))

### Number of animals

n <- nrow(data)

#Create equally size n folds for crossvalidation
nfolds <- 10

#Random sampling data

set.seed(SEED)
sample <- sample (1:n,replace=FALSE)                                                     #sample at random from 1 to number of animals
list <- split(sample, sample(rep(1:nfolds), replace=FALSE))              #split at random samples into n folds
str(list)

tst <- as.vector(unlist(list[FOLD], use.names=FALSE))            #convert list into vector and save the elements of each list
head(tst)

### Creating a testing set

yNA <- y
yNA[tst] <- NA                                                                                   #assing NA to rows that were listed in tst

### Setting predictors

if (TRAIT==1){

  ETA = list(list(K = M, model = "RKHS"),
             list(K = G, model = "RKHS"))

 } else {

  ETA = list(list(~factor(cohort) + factor(lact), data = XF1, model = "FIXED"),
           list(K = M, model = "RKHS"),
           list(K = G, model = "RKHS"))}


### Fitting the model

fm <- BGLR(y = yNA, ETA = ETA, nIter = 100000, burnIn = 30000, thin = 5, saveAt = 'RKHS_Linear_')

save(fm, file = 'fm.rda')
str(fm)

### Assesment of predictive ability in TRN and TST data sets

corP_TRN <- cor(fm$yHat[-tst],y[-tst])
corP_TST <- cor(fm$yHat[tst],y[tst])
corS_TRN <- cor(fm$yHat[-tst],y[-tst], method ="pearson")
corS_TST <- cor(fm$yHat[tst],y[tst], method ="pearson")
MSE_TRN <- mean((y[-tst]-fm$yHat[-tst])^2)
MSE_TST <- mean((y[tst]-fm$yHat[tst])^2)
yHat <- fm$yHat

regression <- lm(y[-tst]~fm$yHat[-tst])
slope_TRN <- regression$coefficients[2]

regression <- lm(y[tst]~fm$yHat[tst])
slope_TST <- regression$coefficients[2]

regression <- lm(y~fm$yHat)
slope <- regression$coefficients[2]

result <- cbind(corP_TRN, corP_TST, corS_TRN, corS_TST, MSE_TRN, MSE_TST, y, yHat, slope_TRN, slope_TST, slope)

file <- paste(paste0(paste0("Trait",TRAIT),"_LinearK_Out",SEED),FOLD,sep=".")
save(result,file = file)
