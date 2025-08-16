#!/usr/bin/env bash
set -euo pipefail

export JUPYTER_PORT="${JUPYTER_PORT:-8888}"
export COMFYUI_PORT="${COMFYUI_PORT:-8188}"
export JUPYTER_TOKEN="${JUPYTER_TOKEN:-runpod}"

mkdir -p /workspace/ComfyUI/{models,output,input}

# Start JupyterLab in background
jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT}" \
  --no-browser \
  --allow-root \
  --ServerApp.token="${JUPYTER_TOKEN}" \
  --ServerApp.allow_origin="*" &

# Start ComfyUI in foreground
cd /workspace/ComfyUI
exec python main.py --listen 0.0.0.0 --port "${COMFYUI_PORT}"
