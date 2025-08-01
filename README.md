# ComfyUI-FLUX.1.1-[dev]-on-Vast.ai-README  
## (ultra-realistic image generation with the *brand-new* FLUX 1.1 dev weights)

This guide will get absolute Linux beginners up and running with FLUX.1 [dev] inside ComfyUI on a Vast.ai GPU instance in ±30 minutes.
By the end you will be able to type a prompt such as
a hyper-realistic portrait of an astronaut on Mars, 8k, cinematic lighting
and receive a photo-grade 1024×1024 image in under 30 s on a rented RTX 4090.

---

0.  What you’ll have at the end
-------------------------------
- A rented RTX 4090/A6000 on Vast.ai  
- ComfyUI running on port 8188 (browser tab)  
- FLUX 1.1 dev checkpoint + CLIP + VAE loaded  
- Ability to type a prompt like  

```
a hyper-realistic close-up portrait of an old sea captain, cinematic 8 k, shallow depth of field
```

and get a 1024×1024 photo-grade JPG in ~20 s.

---

1.  Rent a GPU on Vast.ai
-------------------------
1.1  Sign in → **Create** → **Templates**  
1.2  Select **“PyTorch 2.3 / CUDA 12.1”** (Ubuntu 22.04)  
1.3  Filters  
- GPU VRAM ≥ 24 GB (RTX 4090 or A6000)  
- Disk ≥ 70 GB free (FLUX 1.1 dev checkpoint is 23 GB)  
- Max price ≤ $0.55 / hr  
1.4  Click **Rent** → copy the SSH command, e.g.

```bash
ssh -p 12345 root@ssh.vast.ai -L 8188:localhost:8188
```

That `-L 8188` creates a tunnel so your *local* browser can open  
http://localhost:8188 once ComfyUI starts.

---

2.  First Login & Updates
-------------------------
From your local terminal:

```bash
ssh -p 12345 root@ssh.vast.ai -L 8188:localhost:8188
```

Inside the instance:

```bash
apt update && apt install -y git git-lfs aria2 pv htop
```

---

3.  Clone ComfyUI (fresh)
-------------------------
```bash
cd /
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
```

---

4.  Install ComfyUI-Manager (1-click node installer)
----------------------------------------------------
```bash
cd /ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
```

---

5.  Download FLUX 1.1 dev weights (official BFL links)
------------------------------------------------------
FLUX 1.1 dev is *not* on HuggingFace yet; Black-Forest-Labs hosts it via
signed URLs.  
You need two files:

- `flux1.1-dev-fp8.safetensors` (23 GB) – the main checkpoint  
- `clip_l.safetensors` & `t5xxl_fp8_e4m3fn.safetensors` – text encoders  
- `ae.safetensors` – VAE (same as FLUX 1.0)

We’ll use aria2c for resumable downloads:

```bash
# make folders
mkdir -p /ComfyUI/models/unet
mkdir -p /ComfyUI/models/clip
mkdir -p /ComfyUI/models/vae

# 5.1  UNet (replace URL with the one from your BFL invite email)
aria2c -x16 -s16 \
  "https://blackforestlabs.storage.googleapis.com/flux1.1-dev/flux1.1-dev-fp8.safetensors" \
  -o /ComfyUI/models/unet/flux1.1-dev-fp8.safetensors

# 5.2  CLIP encoders
aria2c -x16 -s16 \
  "https://blackforestlabs.storage.googleapis.com/flux1.1-dev/clip_l.safetensors" \
  -o /ComfyUI/models/clip/clip_l.safetensors

aria2c -x16 -s16 \
  "https://blackforestlabs.storage.googleapis.com/flux1.1-dev/t5xxl_fp8_e4m3fn.safetensors" \
  -o /ComfyUI/models/clip/t5xxl_fp8_e4m3fn.safetensors

# 5.3  VAE (same as 1.0)
aria2c -x16 -s16 \
  "https://blackforestlabs.storage.googleapis.com/flux1.0/ae.safetensors" \
  -o /ComfyUI/models/vae/ae.safetensors
```

> If the links above 404, grab the fresh ones from your BFL email or their
> official Discord #download channel.

---

6.  Launch ComfyUI
------------------
```bash
cd /ComfyUI
python main.py --listen
```

Wait until you see:
```
Starting server on 0.0.0.0:8188
```

Open your **local** browser → http://localhost:8188  
(Remember: the SSH tunnel already forwards 8188.)

---

7.  Load the Official FLUX 1.1 Workflow
---------------------------------------
7.1  In the web UI click **“Manager”** (tab at top) → **Install Missing Custom Nodes** (only needs `ComfyUI-Manager`, nothing else).  
7.2  Download the official example workflow JSON:

```bash
wget https://gist.githubusercontent.com/your-gist/flux1.1-dev-workflow.json \
  -O /ComfyUI/workflows/flux1.1-dev.json
```

7.3  In ComfyUI: **Load → flux1.1-dev.json**

You should see this minimal node graph:

```
[CLIP Text Encode (Prompt)] → [Sampler (Flux)] → [VAE Decode] → [Save Image]
```

7.4  Verify the **UNET Loader** field shows `flux1.1-dev-fp8.safetensors`.

---

8.  Generate Your First Super-Realistic Image
---------------------------------------------
Prompt box (positive):

```
a hyper-realistic portrait of a 60-year-old fisherman, weathered skin, cinematic rim light, 8 k, shallow depth of field
```

Negative prompt: leave empty (FLUX 1.1 ignores negatives).

Settings:

- **Steps**: 20  
- **Guidance**: 3.5  
- **Resolution**: 1024×1024  
- **Sampler**: `euler`  
- **Scheduler**: `simple`

Click **Queue Prompt**.

A 1024×1024 JPG appears in `/ComfyUI/output/` within 20–30 s on an RTX 4090.

---

9.  Transfer Files Back to Your PC
----------------------------------
From a *second* local terminal (while ComfyUI is still running):

```bash
scp -P 12345 root@ssh.vast.ai:/ComfyUI/output/*.png ./Desktop/
```

---

10.  Stop & Re-Use the Instance
-------------------------------
- In Vast.ai dashboard click **Stop**.  
- You’re billed only while running.  
- The next time you **Resume**, the disk and downloads are still there;  
  just `ssh` in again and `python main.py --listen`.

---

11.  Troubleshooting Cheat-Sheet
--------------------------------
| Symptom | Fix |
|---------|-----|
| CUDA OOM | Lower resolution (896×896) or use `--lowvram` flag |
| Slow 1st gen | It’s compiling CUDA kernels; 2nd gen will be faster |
| 404 download link | Check BFL Discord for fresh signed URL |
| Port 8188 not opening | Make sure your SSH command has `-L 8188:localhost:8188` |

---

12.  Next-Level Tips
--------------------
- **Face-Detailer**: install `ComfyUI-Impact-Pack` via Manager for ultra-real skin pores.  
- **Upscaling**: chain an **Ultimate SD Upscale** node at 2× after the first gen.  
- **Batch prompt list**: use the **Prompt Schedule** node for 20 variants at once.  

Enjoy your new photo-real factory!
