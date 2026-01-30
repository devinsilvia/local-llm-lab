#!/usr/bin/env bash
set -e

echo "Starting macOS Intel profile (Perplexica + Ollama optional)"

docker compose -f docker/compose.macos-intel.yaml up -d --build
