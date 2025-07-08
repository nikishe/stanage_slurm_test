#!/bin/bash
echo "=============Start of Test 8=================="
echo "8. Checking for GPU-enabled nodes..."
GPU_NODES=$(scontrol show nodes | grep Gres=gpu | awk '{print $1}' | cut -d= -f2)
if [ -n "$GPU_NODES" ]; then
    echo "Found GPU nodes: $GPU_NODES"
    echo "Submitting GPU job test..."
    GPU_TEST_SCRIPT=$(mktemp)
    cat <<EOF > $GPU_TEST_SCRIPT
#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --job-name=gpu_test
#SBATCH --output=gpu_test.out
#SBATCH --reservation=RPR-538-full-maintenance
module load CUDA
nvidia-smi || echo "nvidia-smi not found"
EOF
    chmod +x $GPU_TEST_SCRIPT
    sbatch "$GPU_TEST_SCRIPT"
    sleep 10
    echo "GPU job output (if completed):"
    cat gpu_test.out 2>/dev/null || echo "Output not ready yet"
    #rm -f "$GPU_TEST_SCRIPT" gpu_test.out
else
    echo "No GPU nodes detected."
fi

echo "==============End of Test 8==================="
echo