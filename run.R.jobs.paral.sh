#!/bin/bash
#SBATCH --job-name=Crossval
#SBATCH --mail-user=@gmail.com
#SBATCH --mail-type=END,FAIL,ARRAY_TASKS
#SBATCH --ntasks=1 
#SBATCH --array=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10mb                     #memory per each job
#SBATCH --time=90:00:00                        #time per each job
#SBATCH --output=PRED_crossval.out             #Output and error log or -o (all error goes here if --error not especified)
#SBATCH --error=PRED_crossval.error            #Error log or e

# List of numbers to use as SEED to execute a random process in R
SEED=(123 1001 1010 1100 2001)  # 5 replicates
# List of the number of folds
FOLD=(1 2 3 4 5 6 7 8 9 10)     # 10-fold cross-validation

# Loop to run CV for phenotype predictions of 3 traits
for t in {1..3} # Number of traits
do
    for i in "${SEED[@]}" # Loop over replicates list
    do
        for j in "${FOLD[@]}" # Loop over folds list
        do
            # Submit a job with the 3 arguments (trait, seed, fold)
            sbatch R.jobs.paral.sh $t $i $j
            sleep 1 # Wait 1 second to submit the next job
        done
    done
done

