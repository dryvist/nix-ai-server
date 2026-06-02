#!/usr/bin/env bash
# Re-render every docs/**/*.mmd file to a sibling .svg via mermaid-cli.
# Used by the mermaid-render-check workflow to enforce that source +
# rendered output stay in sync. Exit non-zero on any render failure.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PUPPETEER_CONFIG="${SCRIPT_DIR}/puppeteer-config.json"

while IFS= read -r -d '' f; do
  echo "rendering $f"
  nix run nixpkgs#mermaid-cli -- \
    -i "$f" -o "${f%.mmd}.svg" \
    --puppeteerConfigFile "$PUPPETEER_CONFIG" \
    --quiet
done < <(find docs -type f -name '*.mmd' -print0)
