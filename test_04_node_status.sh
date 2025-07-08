#!/bin/bash

echo "=============Start of Test 4=================="
echo "4. Checking node status..."

sinfo
echo
scontrol show nodes | grep -E 'NodeName|State|CPU|RealMemory'

echo "==============End of Test 4==================="
