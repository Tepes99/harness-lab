#!/usr/bin/env bash
set -euo pipefail

if command -v pi >/dev/null 2>&1; then
  pi_bin=$(command -v pi)
elif [[ -x "$PWD/node_modules/.bin/pi" ]]; then
  pi_bin="$PWD/node_modules/.bin/pi"
else
  echo "pi is not on PATH and the project-local binary is not installed" >&2
  exit 1
fi

echo "Pi executable: $pi_bin"
echo "Pi version: $($pi_bin --version)"
echo "Node version: $(node --version)"
echo "Matching configured model:"
"$pi_bin" --list-models qwen3.8

pi_package_root="$(npm root -g)/@earendil-works/pi-coding-agent"
if [[ -d "$pi_package_root" ]]; then
  echo "Installed Pi package: $pi_package_root"
  echo "Inspect first: $pi_package_root/dist/core/system-prompt.js"
else
  echo "Could not resolve the @earendil-works global package under npm root." >&2
fi
