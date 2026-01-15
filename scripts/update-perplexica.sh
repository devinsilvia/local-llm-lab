#!/usr/bin/env bash
set -euo pipefail

PERPLEXICA_TAG="v1.12.1"

echo "Updating Perplexica submodule to ${PERPLEXICA_TAG}"

git -C perplexica fetch --tags
# Checkout the desired release tag.
git -C perplexica checkout "${PERPLEXICA_TAG}"

cat <<INFO
Perplexica is now at ${PERPLEXICA_TAG}.
If you changed the tag, consider updating docker/compose.*.yaml to match the image tag.
INFO
