#!/bin/bash

echo "=============Start of Test 2=================="
echo "2. Checking Slurm daemon status..."

for service in slurmd; do
    if systemctl list-units --type=service | grep -q "$service"; then
        systemctl is-active --quiet "$service" && echo "$service: active" || echo "$service: inactive"
    else
        echo "$service: not installed"
    fi
done

echo "==============End of Test 2==================="