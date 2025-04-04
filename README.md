# Cross Validation for Phenotype Predictions
Originally developed by Hendyel Pacheco, PhD at UW-Madison.

This pipeline uses R scripts to perform cross-validation for phenotype predictions that can be implmented in Linux and Windows.
The process works like an **American Postman** delivering letters. Here's the analogy:

## 1. 📮 The Postman: 
The postman is the R (in windows) or bash (in linux) script `run.R.jobs.paral.sh`.
This postman’s job is to deliver envelopes (scripts with arguments) to people living in different houses (server nodes or cores).

## 2. ✉️ The Envelope: 
Each envelope is represented by the script `R.jobs.paral.sh`.
Inside the envelope are specific instructions (arguments) that the recipient (person in the house) uses to perform their task.

## 3. 📜 The Letter Inside: 
Once the envelope is opened, the person finds a letter: the R script `Rcode.Pred.R`.
This letter contains detailed instructions to execute phenotype predictions. After completing their task, the person sends a response (results) back to the postman, using a name that includes the task’s key arguments (e.g., TRAIT, SEED, FOLD) for tracking.

## 🛠️ Workflow
### 1️⃣ `run.R.jobs.paral.sh` or `run.R.jobs.R`
This is the main R (in windows) or bash (in linux) script that distributes envelopes (jobs) across server nodes.

### 2️⃣ `R.jobs.paral.sh`
This script (the envelope) passes arguments to the server nodes for execution.
NOTE: We don't need this step in Windows.

### 3️⃣ `Rcode.Pred.R`
The R script (the letter) is executed with the given arguments to perform phenotype predictions.

# 💡 Notes:
- Make sure the server system (e.g., SLURM) is set up properly.
- Check how many cores available you have in your Windows computer.
- Results are named using a consistent format based on the job arguments.
