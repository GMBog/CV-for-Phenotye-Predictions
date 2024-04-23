#!/bin/bash
#SBATCH --job-name=Crossval_GM
#SBATCH --mail-user=@gmail.com
#SBATCH --mail-type=END,FAIL,ARRAY_TASKS
#SBATCH --ntasks=1 
#SBATCH --array=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10mb                     #memory per each job
#SBATCH --time=90:00:00                                 #time per each job
#SBATCH --output=PRED_GM_crossval.out                  #Output and error log or -o (all error goes here if --error not especified)
#SBATCH --error=PRED_GM_crossval.error                 #Error log or e


#SEED=(123 1001 1010 1100 2001 101 313 3002 231 4440)           #10 replicates
SEED=(123 1001 1010 1100 2001)                                  #5 replicates   
FOLD=(1 2 3 4 5 6 7 8 9 10)                                     #n folds crossvalidation


### Loop to do CV using the whole microbial matrix

for t in {1..3}
do
        for i in "${SEED[@]}"
        do
                for j in "${FOLD[@]}"
                do

                        sbatch R.jobs.paral.sh $t $i $j
                        sleep 1                                         #wait 1 secod to submit next job
                done
        done
done
