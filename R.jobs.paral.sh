#!/bin/bash

# Execute R code with the 3 arguments (#trait, #seed, #fold) 
module load R
Rscript Rcode.Pred.R $1 $2 $3
