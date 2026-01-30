#!/usr/bin/env bash
set -e

echo "Starting macOS Apple Silicon profile (Perplexica + native Ollama)"

docker compose -f docker/compose.macos-apple-silicon.yaml up -d --build
