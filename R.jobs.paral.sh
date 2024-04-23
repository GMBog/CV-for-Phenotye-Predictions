#!/bin/bash

module load R
Rscript Rcode.Pred.R $1 $2 $3 $4
