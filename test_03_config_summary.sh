#!/bin/bash

echo "=============Start of Test 3=================="
echo "3. Showing Slurm config summary..."

scontrol show config | grep -E 'SlurmctldHost|StateSaveLocation|SlurmUser|SlurmdbdHost|AccountingStorageType'

echo "==============End of Test 3==================="