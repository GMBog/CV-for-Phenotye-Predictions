# 🏢 Cross-Validation for Phenotype Predictions
Originally developed by Hendyel Pacheco, PhD at UW-Madison.

This pipeline uses Bash and R scripts to perform cross-validation for phenotype predictions.
The process works like an **American Postman** delivering letters to other postmen. Here's the analogy:

## 1. 📮 The Postman: 
The postman is the Bash script `1_run.R.jobs.paral.sh`.
This postman’s job is to deliver envelopes (scripts with arguments) to people living in different houses (server nodes).

## 2. ✉️ The Envelope: 
Each envelope is represented by the script `2_R.jobs.paral.sh`.
Inside the envelope are specific instructions (arguments) that the recipient (person in the house) uses to perform their task.

## 3. 📜 The Letter Inside: 
Once the envelope is opened, the person finds a letter: the R script `3_Rcode.Pred.R`.
This letter contains detailed instructions to execute phenotype predictions. After completing their task, the person sends a response (results) back to the postman, using a name that includes the task’s key arguments (e.g., TRAIT, SEED, FOLD) for tracking.

## 🛠️ Workflow
### 1️⃣ `1_run.R.jobs.paral.sh`
This is the main Bash script that distributes envelopes (jobs) across server nodes.

### 2️⃣ `2_R.jobs.paral.sh`
This script (the envelope) passes arguments to the server nodes for execution.

### 3️⃣ `3_Rcode.Pred.R`
The R script (the letter) is executed with the given arguments to perform phenotype predictions.

## 🚀 How to Run the Pipeline
Step 1: Customize the envelope (2_R.jobs.paral.sh) with your desired arguments.
Example. Modify argument settings such as phenotype type, data paths, and model parameters.

Step 2: Run the main postman (1_run.R.jobs.paral.sh).
bash 1_run.R.jobs.paral.sh

Step 3: Wait for results to be delivered back to you.
Each result will be named based on the specific arguments (TRAIT, SEED, FOLD) used in the job.

# 💡 Notes:
- Make sure the server system (e.g., SLURM) is set up properly.
- Results are named using a consistent format based on the job arguments.
