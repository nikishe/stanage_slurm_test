#!/bin/bash
echo "9. Log check skipped (requires elevated permissions)."
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