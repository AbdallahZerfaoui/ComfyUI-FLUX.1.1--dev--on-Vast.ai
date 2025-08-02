#!/usr/bin/env bash
# ------------------------------------------------------------------
#  setup_flux1.1_dev_on_vastai.sh
#  One-shot installer for FLUX 1.1 dev + ComfyUI on a Vast.ai GPU
#  Run this script immediately after you SSH into the rented machine.
#
#  IMPORTANT: execute with
#      bash setup_flux1.1_dev_on_vastai.sh
#  (Make it executable once with  chmod +x  if you wish.)
# ------------------------------------------------------------------

set -e  # stop on first error

echo "===== 1. OS dependencies ====="
apt-get update -qq
apt-get install -y git git-lfs aria2 pv htop

echo "===== 2. Clone ComfyUI (fresh) ====="
cd /
if [ -d ComfyUI ]; then
  echo "ComfyUI already exists – removing for clean install"
  rm -rf ComfyUI
fi
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt

echo "===== 3. Install ComfyUI-Manager ====="
mkdir -p custom_nodes
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ..

# echo "===== 4. Create model folders ====="
# mkdir -p models/unet
# mkdir -p models/clip
# mkdir -p models/vae

# ------------------------------------------------------------------
# 5. Download FLUX 1.1 dev weights
#    Replace the URLs below with the signed ones you received from
#    Black-Forest-Labs or their Discord #download channel.
# ------------------------------------------------------------------
# echo "===== 5. Download FLUX 1.0 dev weights (this may take 5-10 min) ====="

# 5-a) Main 23 GB checkpoint
# aria2c -x16 -s16 \
#   "https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors" \
#   -o models/unet/flux1-dev-fp8.safetensors

# aria2c -x16 -s16 \
#   "https://huggingface.co/Comfy-Org/FLUX.1-Krea-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-krea-dev_fp8_scaled.safetensors" \
#   -o ComfyUI/models/checkpoints/flux1-krea-dev_fp8_scaled.safetensors

# aria2c -x16 -s16 \
#   "https://huggingface.co/AI-Porn/pornworks-nude-people-photo-realistic-nsfw-flux-1d-checkpoint/resolve/main/pornworksNudePeoplePhoto_02.safetensors?download=true" \
#   -o ~/ComfyUI/models/checkpoints/vision_realistic9.safetensors


# # 5-b) CLIP text encoders
# aria2c -x16 -s16 \
#   "https://huggingface.co/camenduru/FLUX.1-dev/resolve/main/clip_l.safetensors" \
#   -o ComfyUI/models/text_encoders/clip_l.safetensors

# aria2c -x16 -s16 \
#   "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors" \
#   -o models/clip/t5xxl_fp8_e4m3fn.safetensors

# # 5-c) VAE (auto-encoder, same file as FLUX 1.0)
# aria2c -x16 -s16 \
#   "https://huggingface.co/ffxvs/vae-flux/resolve/main/ae.safetensors" \
#   -o models/vae/ae.safetensors

# echo "===== 6. Download example workflow (optional) ====="
# mkdir -p workflows
# wget -q https://gist.githubusercontent.com/your-gist/flux1.1-dev-workflow.json \
#      -O workflows/flux1.1-dev.json || true  # ignore 404

# echo "===== 7. Start ComfyUI ====="
# echo "Opening port 8188 on 0.0.0.0 (use SSH tunnel on your laptop)"
# python main.py --listen --port 8188

# ------------------------------------------------------------------
# 5-A. Download FLUX-1.1-dev-fp8 checkpoint (23 GB)
# ------------------------------------------------------------------
# echo "===== 5-A. FLUX-1.1-dev-fp8 checkpoint ====="
# aria2c -x16 -s16 \
#   "https://blackforestlabs.storage.googleapis.com/flux1.1-dev/flux1.1-dev-fp8.safetensors" \
#   -o models/unet/flux1.1-dev-fp8.safetensors

# ------------------------------------------------------------------
# 5-B. Download Instagram-realism LoRAs (place in LoRA folder)
# ------------------------------------------------------------------
# mkdir -p models/loras
# echo "===== 5-B. Instagram-realism LoRAs ====="

# # 1) Realistic Skin Texture LoRA
# aria2c -x4 \
#   "https://huggingface.co/prithivMLmods/Canopus-LoRA-Flux-FaceRealism/resolve/main/Canopus-LoRA-Flux-FaceRealism.safetensors?download=true" \
#   -o ComfyUI/models/loras/canopus_real_skin.safetensors

# # 2) Fashion-Model Poses LoRA
# aria2c -x4 \
#   "https://civitai.com/api/download/models/148192?type=Model&format=SafeTensor" \
#   -o models/loras/ig_fashion_pose.safetensors

# # 3) Soft-Golden-Hour Lighting LoRA
# aria2c -x4 \
#   "https://civitai.com/api/download/models/142376?type=Model&format=SafeTensor" \
#   -o models/loras/golden_hour_light.safetensors