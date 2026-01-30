Write-Host "Starting Windows profile (Perplexica + native Ollama)"

docker compose -f docker/compose.windows.yaml up -d --build
