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
- Connects Perplexica to Ollama via `host.docker.internal` when Ollama runs
  natively.

### Scripts (entry points)

The `scripts/` directory provides helper scripts to launch the correct Compose
file for your hardware profile, so a user does not need to memorize commands.

## How the pieces fit together

1. Ollama runs on the host and serves models over `http://localhost:11434`.
2. Docker Compose starts Perplexica and maps its UI to `http://localhost:3000`.
3. Perplexica is configured to call Ollama at
   `http://host.docker.internal:11434`.
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
   - A provider pointing at `http://host.docker.internal:11434`.
   - A chat model and an embedding model.

Once the provider and models are configured, you can chat immediately.

### Daily use

1. Start Ollama (if not already running).
2. Start Perplexica with the profile script.
3. Open the UI and chat.
4. Use the paperclip to upload documents for retrieval.
5. Ask questions referencing your uploads or using search tools.

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
