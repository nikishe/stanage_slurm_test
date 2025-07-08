#!/bin/bash

echo "=============Start of Test 1=================="
echo "1. Checking Slurm binaries and versions..."

echo "Checking slurmd"
which slurmd && slurmd --version

echo "Checking srun"
which srun && srun --version

echo "Checking sbatch"
which sbatch && sbatch --version

echo "==============End of Test 1==================="
