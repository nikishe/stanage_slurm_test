#!/bin/bash
echo "=============Start of Test 13=================="
echo "13. Submitting multi-GPU job (2 GPUs)..."
GPU_MULTI_SCRIPT=$(mktemp)
cat <<EOF > $GPU_MULTI_SCRIPT
#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --nodes=1
#SBATCH --reservation=RPR-538-full-maintenance
#SBATCH --gpus-per-node=2  # Requests 2 GPUs
#SBATCH --job-name=multi_gpu_test
#SBATCH --output=multi_gpu_test.out
echo "Requesting 2 GPUs..."
module load CUDA
nvidia-smi || echo "nvidia-smi not found"
EOF

chmod +x "$GPU_MULTI_SCRIPT"
sbatch "$GPU_MULTI_SCRIPT"
sleep 10
echo "--- Multi-GPU job output ---"
cat multi_gpu_test.out 2>/dev/null || echo "Output not ready"
#rm -f "$GPU_MULTI_SCRIPT" multi_gpu_test.out

echo "==============End of Test 13==================="