# Local LLM Lab User Guide

## Purpose and scope

Local LLM Lab is a self-contained, local-first stack for running and exploring
LLMs on your own hardware. It combines a model runtime (Ollama) with a UI and
retrieval layer (Perplexica) so users can chat, search, and attach local files
without relying on a hosted provider.

This guide explains the moving parts, how they connect, and what a typical user
workflow looks like once everything is running.

## The core components

### Ollama (model runtime)

Ollama is the local model server. It:
- Stores models on your machine.
- Provides a simple HTTP API for chat and embeddings.
- Runs inference using available hardware acceleration (CPU, GPU, or Apple
  Neural Engine when supported).

Perplexica talks to Ollama as its model provider. If Ollama is not running, the
UI can load but model requests will fail.

### Perplexica (UI + retrieval)

Perplexica provides:
- The chat UI.
- Tool calling and search orchestration.
- Document ingestion and chunking for retrieval.
- The logic to mix web search, local uploads, and model responses.

Perplexica is run inside Docker in this repo, and it uses the checked-out
`perplexica/` submodule as its source.

### Docker + Compose (orchestration)

Docker Compose is used to start the Perplexica container and supporting
services. It also:
- Provides a consistent runtime across macOS/Windows.
- Persists Perplexica data via Docker volumes.
- Connects Perplexica to Ollama either:
  - via `http://ollama:11434` when Ollama runs as a Compose service, or
  - via `http://host.docker.internal:11434` when Ollama runs natively on host.

### Scripts (entry points)

The `scripts/` directory provides helper scripts to launch the correct Compose
file for your hardware profile, so a user does not need to memorize commands.
Profiles in this repo:
- macOS Intel (`scripts/run-macos-intel.sh`)
- macOS Apple Silicon (`scripts/run-macos-apple-silicon.sh`)
- Windows (`scripts/run-windows.ps1`)
- Linux (`scripts/run-linux.sh`)

## How the pieces fit together

1. Ollama runs either:
   - as a host process on `http://localhost:11434`, or
   - as the `ollama` Compose service for the macOS Intel Dockerized mode.
2. Docker Compose starts Perplexica and maps its UI to `http://localhost:3000`.
3. Perplexica calls Ollama at:
   - `http://ollama:11434` for Dockerized Ollama, or
   - `http://host.docker.internal:11434` for native host Ollama.
4. When you chat, Perplexica sends prompts to Ollama and renders responses.
5. When you attach files, Perplexica ingests them, builds embeddings (via
   Ollama), and uses those chunks during later searches.

## Typical user workflow

### First-time setup

1. Install Docker Desktop and Ollama for your platform.
2. Start Ollama and pull at least one chat model and one embedding model.
3. Launch the stack using the appropriate script or Compose file.
4. Open Perplexica at `http://localhost:3000`.
5. In Perplexica, configure:
   - A provider pointing at the correct URL for your mode:
   - `http://ollama:11434` for Dockerized Ollama (macOS Intel compose default).
   - `http://host.docker.internal:11434` for native host Ollama.
   - A chat model and an embedding model. Use a tool-capable chat model (for example `llama3.1:8b-instruct-q4_0`) so web search works correctly. See the model compatibility table below for confirmed models for a variety of hardware.
   - Recommended embedding model: `nomic-embed-text:latest`. If you are on lower-tier hardware, see the embedding model guidance below for lighter-weight options.

Once the provider and models are configured, you can chat immediately.

### Picking an embedding model

Embedding models control how uploaded documents are chunked and retrieved. For this local setup, `nomic-embed-text:latest` is the recommended default for quality; if your hardware struggles, use the lighter-weight options below.

- **Fastest/lowest resource**: `all-minilm` (tiny and quick; best for low CPU/GPU).
- **Better quality (slightly heavier)**: `embeddinggemma` (more compute, improved retrieval quality).

If your machine struggles, start with `all-minilm`. If retrieval quality matters more than speed, try `embeddinggemma`.

### Daily use

1. Start Ollama (if not already running).
2. Start Perplexica with the profile script.
3. Open the UI and chat.
4. Use the paperclip to upload documents for retrieval (`.pdf`, `.docx`, `.txt`, `.md`).
5. Ask questions referencing your uploads or using search tools.

### Model management commands by Ollama mode

Use the command set that matches where Ollama runs.

```bash
# Native host Ollama
ollama list
ollama pull llama3.1:8b-instruct-q4_0
ollama pull nomic-embed-text:latest
```

```bash
# Dockerized Ollama (macOS Intel compose default)
docker compose -f docker/compose.macos-intel.yaml exec ollama ollama list
docker compose -f docker/compose.macos-intel.yaml exec ollama ollama pull llama3.1:8b-instruct-q4_0
docker compose -f docker/compose.macos-intel.yaml exec ollama ollama pull nomic-embed-text:latest
```

### Stopping and resuming

Stop the stack with the relevant Compose `down` command. Data stored in Docker
volumes persists across restarts, so uploads and settings remain in place.

## Notes for collaborators

- The `perplexica/` submodule is the upstream project with local patches.
- When updating Perplexica, follow the workflow in
  `PERPLEXICA_UPDATE_WORKFLOW.md`.
- Local changes to Perplexica are summarized in `PERPLEXICA_CHANGES.md`.
- If a collaborator uses a different machine profile, they should use the
  matching script and ensure Ollama is installed for their platform.
- Uploaded file citations open via `/api/uploads/<fileId>` inside the running
  Perplexica instance.

## Model compatibility for web search (Ollama)

This section tracks models that have been confirmed to work with Perplexica web
search. The goal is to help users match a model to their hardware if they
specifically want web search functionality. The table is ordered by increasing
model size, which often correlates with hardware requirements.

| Model (Ollama tag) | Params | Quant | Hardware tested | Min RAM/VRAM | Notes |
| --- | --- | --- | --- | --- | --- |
| qwen3:0.6b | 0.75B | Q4_K_M | MacBook Pro (M1, 32GB unified RAM) | Unknown (tested on 32GB unified) | -- |
| granite4:1b | 1.6B | BF16 | MacBook Pro (M1, 32GB unified RAM) | Unknown (tested on 32GB unified) | -- |
| ministral-3:3b | 3.8B | Q4_K_M | MacBook Pro (M1, 32GB unified RAM) | Unknown (tested on 32GB unified) | -- |
| qwen2.5:7b-instruct-q4_0 | 7.6B | Q4_0 | MacBook Pro (M1, 32GB unified RAM) | Unknown (tested on 32GB unified) | -- |
| llama3.1:8b-instruct-q4_0 | 8.0B | Q4_0 | MacBook Pro (M1, 32GB unified RAM) | Unknown (tested on 32GB unified) | -- |

## Where to go next

- `README.md` for platform-specific setup and run commands.
- `PERPLEXICA_UPDATE_WORKFLOW.md` if you plan to update the submodule.
- `PERPLEXICA_CHANGES.md` to understand local customizations.
