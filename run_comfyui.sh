#!/usr/bin/env bash
# ------------------------------------------------------------------
#  run_comfyui.sh
#  Starts ComfyUI in the Vast.ai instance.
#  Run this AFTER you have run setup_flux1.1_dev_on_vastai.sh once.
# ------------------------------------------------------------------

set -e
COMFY_DIR="/workspace/ComfyUI"          # same folder used in setup script
PORT=8288                     # port ComfyUI will listen on

echo ">>> Starting ComfyUI on 0.0.0.0:$PORT …"
cd "$COMFY_DIR"
exec python main.py --listen 0.0.0.0 --port "$PORT"
