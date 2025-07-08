#!/bin/bash
echo "7. Running basic parallel job test with srun (2 tasks)..."
srun --reservation=RPR-538-full-maintenance -N1 -n2 hostname
