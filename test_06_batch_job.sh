#!/bin/bash
echo "=============Start of Test 6=================="
echo "6. Submitting batch test job..."
TEST_SCRIPT=$(mktemp)
cat <<EOF > $TEST_SCRIPT
#!/bin/bash
#SBATCH --job-name=slurm_test_job
#SBATCH --output=slurm_test_output.out
#SBATCH --ntasks=1
#SBATCH --reservation=RPR-538-full-maintenance
echo "Hello from \$(hostname) at \$(date)"
EOF

chmod +x $TEST_SCRIPT
JOB_ID=$(sbatch "$TEST_SCRIPT" | awk '{print $4}')
sleep 3

echo "Waiting for job $JOB_ID to complete..."
sacct -j $JOB_ID --format=JobID,State
sleep 5

MAX_WAIT=30
COUNTER=0
while [[ "$(sacct -j $JOB_ID --noheader | awk '{print $2}')" != "COMPLETED" && $COUNTER -lt $MAX_WAIT ]]; do
    sleep 1
    let COUNTER=COUNTER+1
done

echo "Batch job output:"
cat slurm_test_output.out
rm -f "$TEST_SCRIPT" slurm_test_output.out

echo "==============End of Test 6==================="