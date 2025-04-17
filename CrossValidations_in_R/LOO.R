# Leave One Out (LOO)

for (i in 1:length(data$ID)) {
  n <- nrow(data)

  y <- data$TRAIT
  yNA <- y

  tst <- i
  trn <- seq(1:n)[-i]

  yNA[tst] <- NA

  ETA <- list(
    ETA = list(X = XB, model = "FIXED"),
    list(X = S, model = "BayesB", saveEffects = TRUE)
  )

  fm <- BGLR(y = yNA, ETA = ETA, nIter = 100000, burnIn = 30000, saveAt = "BB_")

  result[i, 1] <- data$ID[i]
  result[i, 3] <- cor(y[tst], fm$yHat[tst])
  result[i, 5] <- cor(y[tst], fm$yHat[tst], method = "spearman")
  result[i, 7] <- mean((y[tst] - fm$yHat[tst])^2)
  result[i, 8] <- yl[tst]
  result[i, 9] <- fm$yHat[tst]
}

data$cor <- cor(data$y_real, data$y_predicted)
write.table(data, file = "results_LOO.txt", col.names = T, row.names = F, sep = " ")
