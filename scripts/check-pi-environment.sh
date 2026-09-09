#!/usr/bin/env bash
set -euo pipefail

if ! command -v pi >/dev/null 2>&1; then
  echo "pi is not on PATH" >&2
  exit 1
fi

echo "Pi executable: $(command -v pi)"
echo "Pi version: $(pi --version)"
echo "Node version: $(node --version)"
echo "Matching configured model:"
pi --list-models qwen3.8

pi_package_root="$(npm root -g)/@earendil-works/pi-coding-agent"
if [[ -d "$pi_package_root" ]]; then
  echo "Installed Pi package: $pi_package_root"
  echo "Inspect first: $pi_package_root/dist/core/system-prompt.js"
else
  echo "Could not resolve the @earendil-works global package under npm root." >&2
fi

