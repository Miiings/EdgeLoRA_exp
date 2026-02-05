#!/bin/bash

echo "=== Step 1: Base model only (no LoRA) ==="
./llama-server -m ./models/OpenELM-1.1B/Q4_0-00001-of-00001.gguf -c 2048 --n-gpu-layers 999 &
PID=$!
sleep 5

if kill -0 $PID 2>/dev/null; then
    echo "[STEP 1] SUCCESS - server running (PID=$PID)"
    kill $PID
    wait $PID 2>/dev/null
    sleep 2
else
    echo "[STEP 1] FAILED - server crashed"
    exit 1
fi

echo ""
echo "=== Step 2: LoRA x1, parallel 1 ==="
./llama-server -m ./models/OpenELM-1.1B/Q4_0-00001-of-00001.gguf -c 2048 --lora_repeated ./models/OpenELM-1.1B/lora.gguf 1 --adapter_cache_size 1 --parallel 1 --n-gpu-layers 999 &
PID=$!
sleep 5

if kill -0 $PID 2>/dev/null; then
    echo "[STEP 2] SUCCESS - server running (PID=$PID)"
    kill $PID
    wait $PID 2>/dev/null
    sleep 2
else
    echo "[STEP 2] FAILED - server crashed"
    exit 1
fi

echo ""
echo "=== Step 3: LoRA x20, parallel 60, context 25600 ==="
./llama-server -m ./models/OpenELM-1.1B/Q4_0-00001-of-00001.gguf -c 25600 --lora_repeated ./models/OpenELM-1.1B/lora.gguf 20 --adapter_cache_size 20 --parallel 60 --batch_lora true --n-gpu-layers 999 &
PID=$!
sleep 5

if kill -0 $PID 2>/dev/null; then
    echo "[STEP 3] SUCCESS - server running (PID=$PID)"
    echo "All tests passed! Server is ready."
    echo "Kill with: kill $PID"
else
    echo "[STEP 3] FAILED - server crashed"
    exit 1
fi
