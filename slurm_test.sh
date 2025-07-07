#!/bin/bash

echo "========================= SLURM INSTALLATION TEST ========================="
echo "============This scrip carries out the following test======================"
echo "1. Checking Slurm binaries and versions..."
echo "2. Checking Slurm daemon status..."
echo "3. Showing Slurm config summary..."
echo "4. Checking node status..."
echo "5. Running interactive job test (hostname)..."
echo "6. Submitting batch test job..."
echo "7. Running basic parallel job test with srun (2 tasks)..."
echo "8. Checking for GPU-enabled nodes..."
echo "9. Recent log entries..."
echo "10. Submitting array job (5 tasks)..."
echo "11. Submitting job dependency test..."
echo "12. Checking available partitions and submitting to one..."
echo "13. Submitting multi-GPU job (2 GPUs)..."
echo "14. Submitting multi-node job (2 nodes, 1 task each)..."
echo "==========================================================================="


echo "=============Start of Test 1=================="
echo "1. Checking Slurm binaries and versions..."
#Cant access  slurmctld but leaving for platforms incase they find the script useful
#which slurmctld && slurmctld --version
echo "Checking slurmd" 
which slurmd && slurmd --version
echo "Checking srun" 
which srun && srun --version
echo "Checking sbatch" 
which sbatch && sbatch --version
echo "==============End of Test 1==================="
echo

echo "=============Start of Test 2=================="
echo "2. Checking Slurm daemon status..."
# Platforms can add more services like "slurmctld slurmdbd". Leavins as a foor loop for future additions
for service in  slurmd ; do
    if systemctl list-units --type=service | grep -q "$service"; then
        systemctl is-active --quiet "$service" && echo "$service: active" || echo "$service: inactive"
    else
        echo "$service: not installed"
    fi
done

echo "==============End of Test 2==================="
echo

echo "=============Start of Test 3=================="
echo "3. Showing Slurm config summary..."
# Platforms can add "ControlMachine" in the future
scontrol show config | grep -E 'SlurmctldHost|StateSaveLocation|SlurmUser|SlurmdbdHost|AccountingStorageType'

echo "==============End of Test 3==================="
echo

echo "=============Start of Test 4=================="
echo "4. Checking node status..."
sinfo
echo
scontrol show nodes | grep -E 'NodeName|State|CPU|RealMemory'
echo "==============End of Test 4==================="
echo

echo "=============Start of Test 5=================="
echo "5. Running interactive job test (hostname)..."
srun -N1 -n1 hostname
echo "==============End of Test 5==================="
echo

echo "=============Start of Test 6=================="
echo "6. Submitting batch test job..."
TEST_SCRIPT=$(mktemp)
cat <<EOF > $TEST_SCRIPT
#!/bin/bash
#SBATCH --job-name=slurm_test_job
#SBATCH --output=slurm_test_output.out
#SBATCH --ntasks=1
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
echo

echo "=============Start of Test 7=================="
echo "7. Running basic parallel job test with srun (2 tasks)..."
srun -N1 -n2 hostname
echo "==============End of Test 7==================="
echo

echo "=============Start of Test 8=================="
echo "8. Checking for GPU-enabled nodes..."
GPU_NODES=$(scontrol show nodes | grep Gres=gpu | awk '{print $1}' | cut -d= -f2)
if [ -n "$GPU_NODES" ]; then
    echo "Found GPU nodes: $GPU_NODES"
    echo "Submitting GPU job test..."
    GPU_TEST_SCRIPT=$(mktemp)
    cat <<EOF > $GPU_TEST_SCRIPT
#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --job-name=gpu_test
#SBATCH --output=gpu_test.out
module load CUDA
nvidia-smi || echo "nvidia-smi not found"
EOF
    chmod +x $GPU_TEST_SCRIPT
    sbatch "$GPU_TEST_SCRIPT"
    sleep 10
    echo "GPU job output (if completed):"
    cat gpu_test.out 2>/dev/null || echo "Output not ready yet"
    #rm -f "$GPU_TEST_SCRIPT" gpu_test.out
else
    echo "No GPU nodes detected."
fi

echo "==============End of Test 8==================="
echo

echo "====Test 9 has been skipped as it needs permisions only platform have===="
#Leaving the following for platforms as they will be able to access those areas, as support does not have permisions 
#echo "=============Start of Test 9=================="
#echo "9. Recent log entries..."
## Platforms can add the followin if they need "/var/log/slurmctld.log /var/log/slurmdbd.log"
#for LOG in  /var/log/slurmd.log ; do
#    if [ -f "$LOG" ]; then
#        echo "--- $LOG ---"
#        tail -n 10 "$LOG"
#    fi
#done
#echo "==============End of Test 9==================="
#echo

echo "=============Start of Test 10=================="
echo "10. Submitting array job (5 tasks)..."
ARRAY_JOB_SCRIPT=$(mktemp)
cat <<EOF > $ARRAY_JOB_SCRIPT
#!/bin/bash
#SBATCH --job-name=array_test
#SBATCH --output=array_job_output_%A_%a.out
#SBATCH --array=1-5
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

echo "=============Start of Test 11=================="
echo "11. Submitting job dependency test..."
DEPEND_JOB_A_SCRIPT=$(mktemp)
cat <<EOF > $DEPEND_JOB_A_SCRIPT
#!/bin/bash
#SBATCH --job-name=dep_job_A
#SBATCH --output=dep_job_A.out
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
echo

echo "=============Start of Test 12=================="
echo "12. Checking available partitions and submitting to one..."
sinfo -s || echo "Partition summary not available"
DEFAULT_PARTITION="sheffield" #$(scontrol show partition | awk '/PartitionName/ {print $1}' | head -n1 | cut -d= -f2)
echo "Detected partition: $DEFAULT_PARTITION"

PARTITION_TEST_SCRIPT=$(mktemp)
cat <<EOF > $PARTITION_TEST_SCRIPT
#!/bin/bash
#SBATCH --job-name=partition_test
#SBATCH --partition=$DEFAULT_PARTITION
#SBATCH --output=partition_test.out
echo "Running in partition: \$SLURM_JOB_PARTITION on \$(hostname) at \$(date)"
EOF

chmod +x "$PARTITION_TEST_SCRIPT"
sbatch "$PARTITION_TEST_SCRIPT"
sleep 5
echo "--- Partition job output ---"
cat partition_test.out 2>/dev/null || echo "Output not ready"
#rm -f "$PARTITION_TEST_SCRIPT" partition_test.out

echo "==============End of Test 12==================="
echo

echo "=============Start of Test 13=================="
echo "13. Submitting multi-GPU job (2 GPUs)..."
GPU_MULTI_SCRIPT=$(mktemp)
cat <<EOF > $GPU_MULTI_SCRIPT
#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --nodes=1
#SBATCH --gpus-per-node=2  # Requests 2 GPUs
#SBATCH --job-name=multi_gpu_test
#SBATCH --output=multi_gpu_test.out
echo "Requesting 2 GPUs..."
module load CUDA
nvidia-smi || echo "nvidia-smi not found"
EOF

chmod +x "$GPU_MULTI_SCRIPT"
sbatch "$GPU_MULTI_SCRIPT"
sleep 10
echo "--- Multi-GPU job output ---"
cat multi_gpu_test.out 2>/dev/null || echo "Output not ready"
#rm -f "$GPU_MULTI_SCRIPT" multi_gpu_test.out

echo "==============End of Test 13==================="
echo

echo "=============Start of Test 14=================="
#only works on stanage as we cant do multi node on bessemer

echo "14. Submitting multi-node job (2 nodes, 1 task each)..."
MULTI_NODE_SCRIPT=$(mktemp)
cat <<EOF > $MULTI_NODE_SCRIPT
#!/bin/bash
#SBATCH --job-name=multi_node_test
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --output=multi_node_test.out
srun hostname
EOF

chmod +x "$MULTI_NODE_SCRIPT"
sbatch "$MULTI_NODE_SCRIPT"
sleep 10
echo "--- Multi-node job output ---"
cat multi_node_test.out 2>/dev/null || echo "Output not ready"
#rm -f "$MULTI_NODE_SCRIPT" multi_node_test.out

echo "==============End of Test 14==================="
echo

echo "=============Start of Test 15=================="
echo "15. Submitting successful job with email notification..."
EMAIL="research-it@sheffield.ac.uk"  # Replace with your actual email address

SUCCESS_EMAIL_SCRIPT=$(mktemp)
cat <<EOF > $SUCCESS_EMAIL_SCRIPT
#!/bin/bash
#SBATCH --job-name=email_success
#SBATCH --output=email_success.out
#SBATCH --mail-type=END
#SBATCH --mail-user=$EMAIL
echo "Success email test on \$(hostname) at \$(date)"
EOF

chmod +x "$SUCCESS_EMAIL_SCRIPT"
sbatch "$SUCCESS_EMAIL_SCRIPT"
sleep 3
echo "(Check inbox for success email from Slurm)"
#rm -f "$SUCCESS_EMAIL_SCRIPT" email_success.out

echo "==============End of Test 15==================="
echo

echo "=============Start of Test 16=================="
echo "16. Submitting failed job with email notification..."
FAIL_EMAIL_SCRIPT=$(mktemp)
cat <<EOF > $FAIL_EMAIL_SCRIPT
#!/bin/bash
#SBATCH --job-name=email_fail
#SBATCH --output=email_fail.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=$EMAIL
exit 1
EOF

chmod +x "$FAIL_EMAIL_SCRIPT"
sbatch "$FAIL_EMAIL_SCRIPT"
sleep 3
echo "(Check inbox for failure email from Slurm)"
#rm -f "$FAIL_EMAIL_SCRIPT" email_fail.out

echo "==============End of Test 16==================="
echo

echo "==== SLURM INSTALLATION FULL TEST COMPLETE ===="
