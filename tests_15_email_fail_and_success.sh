#!/bin/bash
echo "=============Start of Test 15=================="
echo "=============success email=================="
echo "Submitting successful job with email notification..."
EMAIL="research-it@sheffield.ac.uk"  # Replace with your actual email address

SUCCESS_EMAIL_SCRIPT=$(mktemp)
cat <<EOF > $SUCCESS_EMAIL_SCRIPT
#!/bin/bash
#SBATCH --job-name=email_success
#SBATCH --output=email_success.out
#SBATCH --mail-type=END
#SBATCH --mail-user=$EMAIL
#SBATCH --reservation=RPR-538-full-maintenance
echo "Success email test on \$(hostname) at \$(date)"
EOF

chmod +x "$SUCCESS_EMAIL_SCRIPT"
sbatch "$SUCCESS_EMAIL_SCRIPT"
sleep 3
echo "(Check inbox for success email from Slurm)"
#rm -f "$SUCCESS_EMAIL_SCRIPT" email_success.out

echo "=============FAIL email=================="
echo "Submitting failed job with email notification..."
FAIL_EMAIL_SCRIPT=$(mktemp)
cat <<EOF > $FAIL_EMAIL_SCRIPT
#!/bin/bash
#SBATCH --job-name=email_fail
#SBATCH --output=email_fail.out
#SBATCH --mail-type=FAIL
#SBATCH --reservation=RPR-538-full-maintenance
#SBATCH --mail-user=$EMAIL
exit 1
EOF

chmod +x "$FAIL_EMAIL_SCRIPT"
sbatch "$FAIL_EMAIL_SCRIPT"
sleep 3
echo "(Check inbox for failure email from Slurm)"
#rm -f "$FAIL_EMAIL_SCRIPT" email_fail.out

echo "==============End of Test 15==================="