# 🏢 Cross-Validation for Phenotype Predictions
# Originally developed by Hendyel Pacheco at UW-Madison

# This pipeline uses Bash and R scripts to perform cross-validation for phenotype predictions.
# The process works like an **American Postman** delivering letters to other postmen. Here's the analogy:

# 1. 📮 The Main Postman: 
# The first postman is the Bash script `1_run.R.jobs.paral.sh`.
# This postman’s job is to deliver envelopes (scripts with arguments) to other postmen (server nodes).

# 2. ✉️ The Envelope: 
# Each envelope is represented by the script `2_R.jobs.paral.sh`.
# It contains the specific arguments (instructions) that each receiving postman needs to perform their task.

# 3. 📜 The Letter Inside: 
# Once the envelope is delivered, the receiving postman opens it and finds the R script `3_Rcode.Pred.R`.
# This letter contains the actual R code to execute phenotype predictions.
# After completing its task, the postman sends a response back to the sender, named based on the arguments provided.

# 🛠️ Workflow
# 1️⃣ `1_run.R.jobs.paral.sh`
# This is the main Bash script that distributes envelopes (jobs) across server nodes.

# 2️⃣ `2_R.jobs.paral.sh`
# This script (the envelope) passes arguments to the server nodes for execution.

# 3️⃣ `3_Rcode.Pred.R`
# The R script (the letter) is executed with the given arguments to perform phenotype predictions.

# 🚀 How to Run the Pipeline
# Step 1: Customize the envelope (2_R.jobs.paral.sh) with your desired arguments.
# Example:
# Modify argument settings such as phenotype type, data paths, and model parameters.

# Step 2: Run the main postman (1_run.R.jobs.paral.sh).
bash 1_run.R.jobs.paral.sh

# Step 3: Wait for results to be delivered back to you.
# Each result will be named based on the specific arguments used in the job.

# 🎯 Why This Approach?
# - Efficient: Tasks are distributed across server nodes in parallel.
# - Flexible: Customizable arguments allow for diverse configurations.
# - Reproducible: Results are tied to specific arguments for easy tracking.

# 💡 Notes:
# - Make sure the server system (e.g., SLURM) is set up properly.
# - Results are named using a consistent format based on the job arguments.
