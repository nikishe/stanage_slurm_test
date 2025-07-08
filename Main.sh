#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

read -p "Please Enter the reservation you would like your tests to run: " RESERVATION
read -p "Please Enter the EMAIL ADDRESS you would like your SLURM to send job emails to   : " SLURM_EMAIL
echo
echo

echo "========================= SLURM INSTALLATION TEST MENU ========================="
echo "Select an option:"
echo " 0) Run all tests"
echo " 1) Checking Slurm binaries and versions..."
echo " 2) Checking Slurm daemon status..."
echo " 3) Showing Slurm config summary..."
echo " 4) Checking node status..."
echo " 5) Running interactive job test (hostname)..."
echo " 6) Submitting batch test job..."
echo " 7) Running basic parallel job test with srun (2 tasks)..."
echo " 8) Checking for GPU-enabled nodes..."
echo " 9) Recent log entries..."
echo "10) Submitting array job (5 tasks)..."
echo "11) Submitting job dependency test..."
echo "12) Checking available partitions and submitting to one..."
echo "13) Submitting multi-GPU job (2 GPUs)..."
echo "14) Submitting multi-node job (2 nodes, 1 task each)..."
echo " q) Quit"
echo "================================================================================"

read -p "Enter your choice: " CHOICE

i=1
for script in "$SCRIPT_DIR"/test_*.sh; do
    printf "%2d) %s\n" $((++i)) "$(basename "$script")"
done

read -p "Enter your choice: " CHOICE

if [[ "$CHOICE" == "0" ]]; then
    echo "Running all tests..."
    for script in "$SCRIPT_DIR"/test_*.sh; do
        echo "Running $(basename "$script")"
        bash "$script"
        echo
    done
elif [[ "$CHOICE" =~ ^[2-9]$|^1[0-9]$ ]]; then
    SELECTED_SCRIPT=$(ls "$SCRIPT_DIR"/test_*.sh | sed -n "$((CHOICE - 1))p")
    if [[ -n "$SELECTED_SCRIPT" ]]; then
        echo "Running $(basename "$SELECTED_SCRIPT")"
        bash "$SELECTED_SCRIPT"
    else
        echo "Invalid selection."
    fi
else
    echo "Exiting."
fi
