# Local LLM Lab: Ollama + Perplexica

## Overview

This repository provides a local LLM stack with:

- **Ollama** as the model runtime.
- **Perplexica** as the web UI and retrieval system.

It supports two hardware profiles:

- **Intel desktop profile**: Intel i7, 32 GB RAM, AMD GPU (treated as CPU-only for LLMs).
- **M1 Pro laptop profile**: Apple M1 Pro, 32 GB unified memory, Apple GPU/Neural Engine acceleration.
- **Windows desktop profile**: recent Windows PC with NVIDIA GPU acceleration.

Use one repo and pick the profile that matches the machine you are running on.

## Prerequisites (common)

- Docker Desktop installed and running.
- Git installed.
- No local Node or build tools required. Everything runs via Docker.

## Additional prerequisites - Intel desktop profile

- macOS Sequoia 15.x on Intel.
- **Ollama option A (preferred):** install Ollama natively from the official macOS installer:
  - Download the macOS Intel installer from `https://ollama.com/download` and run it.
  - Move the Ollama app to `/Applications` when prompted.
  - Launch Ollama once to complete setup.
  - Start it manually before Docker:
    - Run once: `ollama run llama3` to download and warm up a small model.
- **Ollama option B:** use the `ollama` Docker service defined in `docker/compose.intel.yaml`.

## Additional prerequisites - M1 Pro laptop profile

- 2021 MacBook Pro with Apple M1 Pro chip, 32 GB RAM, macOS Sequoia 15.x.
- Install Ollama natively from the Apple Silicon installer and start it before Docker:
  - Download the macOS Apple Silicon installer from `https://ollama.com/download` and run it.
  - Move the Ollama app to `/Applications` when prompted.
  - Launch Ollama once to complete setup.
  - Run once: `ollama run llama3` to download a small model.
- For best performance, **Ollama must run natively**, not in Docker, so it can use Apple GPU/Neural Engine acceleration.
  - Start the service with `ollama serve` (or simply run a model, which starts the service automatically).
  - Verify it is reachable at `http://localhost:11434`.

## Additional prerequisites - Windows desktop profile

- Windows 11 (or Windows 10 22H2) with WSL 2 enabled.
- Install Docker Desktop for Windows and enable WSL 2 integration.
- Install Ollama for Windows and start it before Docker.
- Use `http://host.docker.internal:11434` as the Ollama API URL in Perplexica.
- NVIDIA GPUs are best supported; AMD support is more limited.
- The Windows profile uses `docker/compose.m1pro.yaml` (no Ollama container).

### Windows hardware recommendations

- CPU: modern 6- to 12-core (Intel 12th gen+ or AMD Ryzen 5000+).
- RAM: 32 GB recommended (16 GB minimum for smaller models).
- GPU: NVIDIA RTX 3060 (12 GB) or better for smooth 8-14B inference.
- Storage: 200+ GB free SSD for models and data.

## Model recommendations

- **Intel profile:** use **4-8B** models with quantization (e.g., 4-bit), such as Llama 3 8B or Mistral 7B variants; larger models are likely slow.
- **M1 Pro profile:** **8-14B** models with appropriate quantization are feasible; 32 GB unified memory allows bigger models, but speed and context size still matter.
- **Windows profile:** target **8-14B** 4-bit models if you have a midrange NVIDIA GPU; drop to **4-8B** on CPU-only.

## Running the Intel profile

1. Clone the repo and `cd` into it.
2. Ensure either:
   - Native Ollama is running (`ollama serve` implicitly when you run a model), or
   - You are going to use the `ollama` container in `docker/compose.intel.yaml`.
3. If using native Ollama:
   - Perplexica will talk to `http://host.docker.internal:11434`.
4. Start the stack:
   - `./scripts/run-intel.sh`
   - Or directly: `docker compose -f docker/compose.intel.yaml up -d`
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

## Running the M1 Pro profile

1. Install and start native Ollama.
2. Run `ollama run llama3` once to ensure the model is present.
3. Start the stack:
   - `./scripts/run-m1pro.sh`
   - Or directly: `docker compose -f docker/compose.m1pro.yaml up -d`
4. Perplexica will call Ollama at `http://host.docker.internal:11434`.
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

## Running the Windows profile

1. Install and start Ollama for Windows.
2. Run `ollama run llama3` once to ensure the model is present.
3. Start the stack (PowerShell, uses `docker/compose.m1pro.yaml`):
   - `./scripts/run-windows.ps1`
   - Or directly: `docker compose -f docker/compose.m1pro.yaml up -d`
4. Perplexica will call Ollama at `http://host.docker.internal:11434`.
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

## Stopping and restarting Perplexica

Use these commands from the repo root.

### M1 Pro profile

```bash
docker compose -f docker/compose.m1pro.yaml down
docker compose -f docker/compose.m1pro.yaml up -d --build
```

### Intel profile

```bash
docker compose -f docker/compose.intel.yaml down
docker compose -f docker/compose.intel.yaml up -d --build
```

### Windows profile

```powershell
# Uses docker/compose.m1pro.yaml (no Ollama container).
docker compose -f docker/compose.m1pro.yaml down
docker compose -f docker/compose.m1pro.yaml up -d --build
```

## Troubleshooting

- **Perplexica fails to reach Ollama:** check that:
  - Ollama is running,
  - The Ollama API URL in the UI matches the profile (`http://ollama:11434` vs `http://host.docker.internal:11434`),
  - Ports are correctly mapped in the compose file.
- **Chat hangs in "Brainstorming":** the selected model likely does not support tool calling.
  - Switch to a tool-capable model (for example `llama3.1:8b-instruct-q4_0`).
- **Performance issues:**
  - Intel: try smaller models or lower concurrency.
  - M1 Pro: verify Ollama is using GPU (native, not Docker) and avoid other heavy GPU tasks.
- **iOS input zoom:** forcing inputs below 16px can trigger Safari zoom on focus; if that happens, revert the font size override in `perplexica/src/app/globals.css`.
- **Docker build snapshot error:** if you see `failed to prepare extraction snapshot` during `docker compose ... --build`, clear build cache with `docker builder prune` (or `docker builder prune -a` if needed). Running this occasionally can also free disk space.

## Perplexica source and updates

- The Perplexica source lives in the `perplexica/` git submodule.
- The Docker builds use the checked-out tag in that submodule.
- To update to a new release tag, edit `PERPLEXICA_TAG` in `scripts/update-perplexica.sh` and run it.
- See `PERPLEXICA_UPDATE_WORKFLOW.md` for a recommended workflow to pull upstream changes while keeping local modifications.

## Using Perplexica (after it is running)

The first run usually takes you through a setup flow inside the web UI at `http://localhost:3000`.
Menu names can vary slightly by version, but the flow is typically:

1. Open the UI and go to **Settings** or **Connections**.
2. Add a **provider/connection** for Ollama.
   - API URL: `http://host.docker.internal:11434`
   - API key: leave blank or use any placeholder if required by the form.
3. Add a **chat model** and an **embedding model**.
   - Provider: `Ollama`
   - Model key: use the exact Ollama tag shown by `ollama list` (this is the model name).
   - Example chat model key: `llama3.1:8b-instruct-q4_0`
   - Example embedding model key: `nomic-embed-text` or `nomic-embed-text:latest`
4. Save the settings and return to the main chat UI.

Note: Perplexica uses tool calling during search. If your chat model does not support tools in Ollama, requests can hang or fail.
Perplexica v1.12.1 stores provider and model settings in its internal database under `/home/perplexica/data`, not in the `config/*.toml` files.

If you do not see the setup flow, look for a Settings or Admin icon in the left sidebar or top navigation.

### Verifying models in Ollama

Use these commands on the host to confirm the model keys available to Perplexica:

```bash
ollama list
```

If a model is missing, pull it once:

```bash
ollama pull llama3
ollama pull nomic-embed-text
```

Then return to Perplexica and select the same model key.

### Uploads and attached files

File uploads are stored under `/home/perplexica/data/uploads` inside the container.
The compose files mount a named volume to `/home/perplexica/data` so uploaded files persist and are visible to the chat.
