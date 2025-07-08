#!/bin/bash
echo "=============Start of Test 11=================="
echo "11. Submitting job dependency test..."
DEPEND_JOB_A_SCRIPT=$(mktemp)
cat <<EOF > $DEPEND_JOB_A_SCRIPT
#!/bin/bash
#SBATCH --job-name=dep_job_A
#SBATCH --output=dep_job_A.out
#SBATCH --reservation=RPR-538-full-maintenance
echo "Running Job A at \$(date) on \$(hostname)"
sleep 10
EOF

chmod +x "$DEPEND_JOB_A_SCRIPT"
JOB_A_ID=$(sbatch "$DEPEND_JOB_A_SCRIPT" | awk '{print $4}')
echo "Submitted Job A: $JOB_A_ID"

DEPEND_JOB_B_SCRIPT=$(mktemp)
cat <<EOF > $DEPEND_JOB_B_SCRIPT
#!/bin/bash
#SBATCH --job-name=dep_job_B
#SBATCH --output=dep_job_B.out
#SBATCH --reservation=RPR-538-full-maintenance
echo "Running Job B after Job A completed: \$(date) on \$(hostname)"
EOF

chmod +x "$DEPEND_JOB_B_SCRIPT"
JOB_B_ID=$(sbatch --dependency=afterok:$JOB_A_ID "$DEPEND_JOB_B_SCRIPT" | awk '{print $4}')
echo "Submitted Job B (depends on A): $JOB_B_ID"

echo "Waiting for dependent jobs to finish..."
MAX_WAIT=90
COUNTER=0
while [[ $(sacct -j ${JOB_A_ID},${JOB_B_ID} --noheader | grep -vE 'batch|extern' | grep -c -v COMPLETED) -gt 0 && $COUNTER -lt $MAX_WAIT ]]; do
    sleep 2
    let COUNTER+=2
done

echo "--- Job A Output ---"
cat dep_job_A.out 2>/dev/null || echo "Output not ready"
echo "--- Job B Output ---"
cat dep_job_B.out 2>/dev/null || echo "Output not ready"
#rm -f "$DEPEND_JOB_A_SCRIPT" "$DEPEND_JOB_B_SCRIPT" dep_job_A.out dep_job_B.out

echo "==============End of Test 11==================="