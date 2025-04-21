# Load libraries
library(caret)
library(pls)

rm(list = ls()) # initialization

# Set directory
setwd("/Users/GuillermoMartinez/Documents/Projects/Project_UW_GCIGreenFeed/Methane/Spectra/Predictions/PLS/")

# Open the data set with Animal ID, fixed effects, and phenotypes
data <- readr::read_table("Methane_Spectral535.dat")

# Select cols
data <- data[,c(2,4,8,9,14:548)]

set.seed(123)
Station <- as.character(unique(data$Station))

prediction <- list()
bestcomp <- list()

for(i in 1:length(Station)){
  
  train_ <- filter(data, data$Station != Station[i])
  train <- train_[3:539]
  test_ <- filter(data, data$Station == Station[i])
  test <- test_[3:539]
  
  # Define a control for CV k-fold
  control <- caret::trainControl(method = "cv", number = 10)
  
  # PLS model
  model <- caret::train(CH4 ~ ., 
                        data = train, 
                        method = "pls", 
                        trControl = control, 
                        tuneLength = 20, 
                        metric = "RMSE")
  
  # Prediction
  pred <- data.frame(Obs = test$CH4, Pred = predict(model, newdata = test), Sample = test_$Station)
  comp <- data.frame(ncomp = model[["bestTune"]][["ncomp"]])
  prediction <- rbind(prediction, pred)
  bestcomp <- rbind(bestcomp, comp)
}


# Predictive quality measures

## Mean Squared Error
squared_error <- (prediction$Obs - prediction$Pred)^2
mse <- mean(squared_error)

## Root Mean Squared Error
rmse <- sqrt(mse)

## Mean Absolute Error
absolute_error <- abs(prediction$Obs - prediction$Pred)
abs <- mean(absolute_error)

## Predictive Correlation
cor <- cor(prediction$Obs, prediction$Pred)

results <- c(mse, rmse, abs, cor, cor^2)
results

## Plot Predicted vs Observed
plot(prediction$Obs, prediction$Pred, xlab = "CH4", ylab = "CH4_Pred")
