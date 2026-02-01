#!/usr/bin/env bash
set -e

echo "Starting Linux profile (Perplexica + native Ollama)"

docker compose -f docker/compose.linux.yaml up -d --build
