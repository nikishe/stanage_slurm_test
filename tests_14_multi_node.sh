#!/bin/bash
echo "=============Start of Test 14=================="
#only works on stanage as we cant do multi node on bessemer

echo "14. Submitting multi-node job (2 nodes, 1 task each)..."
MULTI_NODE_SCRIPT=$(mktemp)
cat <<EOF > $MULTI_NODE_SCRIPT
#!/bin/bash
#SBATCH --job-name=multi_node_test
#SBATCH --nodes=3
#SBATCH --ntasks=2
#SBATCH --reservation=RPR-538-full-maintenance
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