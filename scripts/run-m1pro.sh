#!/usr/bin/env bash
set -e

echo "Starting M1 Pro laptop profile (Perplexica + native Ollama)"

docker compose -f docker/compose.m1pro.yaml up -d
