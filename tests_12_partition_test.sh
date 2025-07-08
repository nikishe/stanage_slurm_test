#!/bin/bash
echo "12. Submitting job to test partition..."
DEFAULT_PARTITION="RPR-538-full-maintenance"
SCRIPT=$(mktemp)
cat <<EOF > $SCRIPT
#!/bin/bash
#SBATCH --job-name=partition_test
#SBATCH --partition=$DEFAULT_PARTITION
#SBATCH --output=partition_test.out
echo \"Running in partition \$SLURM_JOB_PARTITION on \$(hostname)\"
EOF
chmod +x "$SCRIPT"
sbatch "$SCRIPT"
sleep 10
cat partition_test.out 2>/dev/null || echo "Output not ready"