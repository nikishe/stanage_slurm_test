#!/bin/bash
echo "=============Start of Test 10=================="
echo "10. Submitting array job (5 tasks)..."
ARRAY_JOB_SCRIPT=$(mktemp)
cat <<EOF > $ARRAY_JOB_SCRIPT
#!/bin/bash
#SBATCH --job-name=array_test
#SBATCH --output=array_job_output_%A_%a.out
#SBATCH --array=1-5
#SBATCH --reservation=RPR-538-full-maintenance
echo "This is task ID \$SLURM_ARRAY_TASK_ID on \$(hostname) at \$(date)"
EOF

chmod +x "$ARRAY_JOB_SCRIPT"
ARRAY_JOB_ID=$(sbatch "$ARRAY_JOB_SCRIPT" | awk '{print $4}')
echo "Submitted array job ID: $ARRAY_JOB_ID"

echo "Waiting for array job to complete..."
sleep 5
MAX_WAIT=60
COUNTER=0
while [[ $(sacct -j ${ARRAY_JOB_ID} --format=JobID,State --noheader | grep -vE 'batch|extern' | grep -c -v COMPLETED) -gt 0 && $COUNTER -lt $MAX_WAIT ]]; do
    sleep 2
    let COUNTER=COUNTER+2
done

echo "Array job outputs:"
for i in {1..5}; do
    OUTPUT_FILE="array_job_output_${ARRAY_JOB_ID}_${i}.out"
    echo "--- $OUTPUT_FILE ---"
    cat "$OUTPUT_FILE" 2>/dev/null || echo "Output not ready"
    #rm -f "$OUTPUT_FILE"
done
rm -f "$ARRAY_JOB_SCRIPT"

echo "==============End of Test 10==================="
echo