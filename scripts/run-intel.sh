#!/usr/bin/env bash
set -e

echo "Starting Intel desktop profile (Perplexica + Ollama optional)"

docker compose -f docker/compose.intel.yaml up -d
