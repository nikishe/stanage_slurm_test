#!/bin/bash
echo "=============Start of Test 5=================="
echo "5. Running interactive job test (hostname)..."
srun --reservation=RPR-538-full-maintenance  -N1 -n1 hostname
echo "==============End of Test 5==================="
echo