# Local LLM Lab: Ollama + Perplexica

## Overview

This repository provides a local LLM stack with:

- **Ollama** as the model runtime.
- **Perplexica** as the web UI and retrieval system.

It supports three setup categories:

- **macOS Intel**: Intel-based Macs (CPU-only for LLMs; AMD GPUs are not used by Ollama).
- **macOS Apple Silicon**: M-series Macs with Apple GPU/Neural Engine acceleration.
- **Windows**: Windows PCs with NVIDIA GPU acceleration (AMD support is more limited).

Use one repo and pick the setup category that matches the machine you are running on.

## Prerequisites (common)

- Docker Desktop installed and running.
- Git installed.
- No local Node or build tools required. Everything runs via Docker.

## Clone the repo (with submodules)

Perplexica is included as a git submodule, so you need to initialize it before
running any Docker or setup commands.

```bash
git clone --recurse-submodules https://github.com/devinsilvia/local-llm-lab
cd local-llm-lab
```

If you already cloned without submodules, run:

```bash
git submodule update --init --recursive
```

## Additional prerequisites - macOS Intel

- macOS Sequoia 15.x on Intel.
- **Ollama option A (preferred):** install Ollama natively from the official macOS installer:
  - Download the macOS Intel installer from `https://ollama.com/download` and run it.
  - Move the Ollama app to `/Applications` when prompted.
  - Launch Ollama once to complete setup.
  - Start it manually before Docker:
    - Run once: `ollama run llama3` to download and warm up a small model.
- **Ollama option B:** use the `ollama` Docker service defined in `docker/compose.macos-intel.yaml`.

## Additional prerequisites - macOS Apple Silicon

- Apple Silicon Mac (M1/M2/M3/M4 series), macOS Sequoia 15.x.
- Install Ollama natively from the Apple Silicon installer and start it before Docker:
  - Download the macOS Apple Silicon installer from `https://ollama.com/download` and run it.
  - Move the Ollama app to `/Applications` when prompted.
  - Launch Ollama once to complete setup.
  - Run once: `ollama run llama3` to download a small model.
- For best performance, **Ollama must run natively**, not in Docker, so it can use Apple GPU/Neural Engine acceleration.
  - Start the service with `ollama serve` (or simply run a model, which starts the service automatically).
  - Verify it is reachable at `http://localhost:11434`.

## Additional prerequisites - Windows

- Windows 11 (or Windows 10 22H2) with WSL 2 enabled.
- Install Docker Desktop for Windows and enable WSL 2 integration.
- Install Ollama for Windows and start it before Docker.
- Use `http://host.docker.internal:11434` as the Ollama API URL in Perplexica.
- NVIDIA GPUs are best supported; AMD support is more limited in Ollama on Windows.
- The Windows profile uses `docker/compose.windows.yaml` (no Ollama container).

### Windows hardware recommendations

- CPU: modern 6- to 12-core (Intel 12th gen+ or AMD Ryzen 5000+).
- RAM: 32 GB recommended (16 GB minimum for smaller models).
- GPU: NVIDIA RTX 3060 (12 GB) or better for smooth 8-14B inference; AMD GPUs are currently less supported in Ollama on Windows.
- Storage: 200+ GB free SSD for models and data.

## Model recommendations

- **macOS Intel:** use **4-8B** models with quantization (e.g., 4-bit), such as Llama 3 8B or Mistral 7B variants; larger models are likely slow.
- **macOS Apple Silicon:** **8-14B** models with appropriate quantization are feasible; unified memory allows bigger models, but speed and context size still matter.
- **Windows:** target **8-14B** 4-bit models if you have a midrange NVIDIA GPU; drop to **4-8B** on CPU-only or AMD.

## Running the macOS Intel profile

1. Clone the repo and `cd` into it.
2. Ensure either:
   - Native Ollama is running (`ollama serve` implicitly when you run a model), or
  - You are going to use the `ollama` container in `docker/compose.macos-intel.yaml`.
3. If using native Ollama:
   - Perplexica will talk to `http://host.docker.internal:11434`.
4. Start the stack:
  - `./scripts/run-macos-intel.sh`
  - Or directly: `docker compose -f docker/compose.macos-intel.yaml up -d`
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

## Running the macOS Apple Silicon profile

1. Install and start native Ollama.
2. Run `ollama run llama3` once to ensure the model is present.
3. Start the stack:
  - `./scripts/run-macos-apple-silicon.sh`
  - Or directly: `docker compose -f docker/compose.macos-apple-silicon.yaml up -d`
4. Perplexica will call Ollama at `http://host.docker.internal:11434`.
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

## Running the Windows profile

1. Install and start Ollama for Windows.
2. Run `ollama run llama3` once to ensure the model is present.
3. Start the stack (PowerShell, uses `docker/compose.windows.yaml`):
   - `./scripts/run-windows.ps1`
   - Or directly: `docker compose -f docker/compose.windows.yaml up -d`
4. Perplexica will call Ollama at `http://host.docker.internal:11434`.
5. Open Perplexica at `http://localhost:3000`.
6. Use the Perplexica UI upload feature (paperclip) to add documents for indexing.

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

## Stopping and restarting Perplexica

Use these commands from the repo root.

### macOS Apple Silicon profile

```bash
docker compose -f docker/compose.macos-apple-silicon.yaml down
docker compose -f docker/compose.macos-apple-silicon.yaml up -d --build
```

### macOS Intel profile

```bash
docker compose -f docker/compose.macos-intel.yaml down
docker compose -f docker/compose.macos-intel.yaml up -d --build
```

### Windows profile

```powershell
# Uses docker/compose.windows.yaml (no Ollama container).
docker compose -f docker/compose.windows.yaml down
docker compose -f docker/compose.windows.yaml up -d --build
```

## Fresh instance (no prior chats/uploads)

Perplexica stores chat history and uploads in the named volume mounted at `/home/perplexica/data`.
You can either reset that volume or run a separate clean instance alongside the original.

### Quick reset (wipe volumes)

This removes the named volumes, which clears chat history and uploads:

```bash
# Use the appropriate command for your profile:
docker compose -f docker/compose.macos-apple-silicon.yaml down -v
```

### Separate clean instance (run alongside original)

Create a new Compose file that uses a different named volume and a different port so it can run in parallel.
For example, copy the compose file and change the port and volume name:

```bash
cp docker/compose.macos-apple-silicon.yaml docker/compose.macos-apple-silicon.fresh.yaml
```

Then edit the copy to use a new volume and port:

```yaml
services:
  perplexica:
    ports:
      - "3001:3000"
    volumes:
      - perplexica_data_fresh:/home/perplexica/data

volumes:
  perplexica_data_fresh:
```

Start the clean instance with:

```bash
docker compose -f docker/compose.macos-apple-silicon.fresh.yaml up -d
```

## Troubleshooting

- **Perplexica fails to reach Ollama:** check that:
  - Ollama is running,
  - The Ollama API URL in the UI matches the profile (`http://ollama:11434` vs `http://host.docker.internal:11434`),
  - Ports are correctly mapped in the compose file.
- **Chat hangs in "Brainstorming":** the selected model likely does not support tool calling.
  - Switch to a tool-capable model (for example `llama3.1:8b-instruct-q4_0`).
- **Performance issues:**
  - macOS Intel: try smaller models or lower concurrency.
  - macOS Apple Silicon: verify Ollama is using GPU (native, not Docker) and avoid other heavy GPU tasks.
  - Windows: ensure GPU drivers are current and reduce model size if you see timeouts.
- **iOS input zoom:** forcing inputs below 16px can trigger Safari zoom on focus; if that happens, revert the font size override in `perplexica/src/app/globals.css`.
- **Docker build snapshot error:** if you see `failed to prepare extraction snapshot` during `docker compose ... --build`, clear build cache with `docker builder prune` (or `docker builder prune -a` if needed). Running this occasionally can also free disk space.

## Perplexica source and updates

- The Perplexica source lives in the `perplexica/` git submodule.
- The Docker builds use the checked-out tag in that submodule.
- To update to a new release tag, edit `PERPLEXICA_TAG` in `scripts/update-perplexica.sh` and run it.
- Keep the `image: perplexica-local:<tag>` value in `docker/compose.*.yaml` aligned with `PERPLEXICA_TAG`.
- See `PERPLEXICA_UPDATE_WORKFLOW.md` for a recommended workflow to pull upstream changes while keeping local modifications.

### Uploads and attached files

File uploads are stored under `/home/perplexica/data/uploads` inside the container.
The compose files mount a named volume to `/home/perplexica/data` so uploaded files persist and are visible to the chat.
