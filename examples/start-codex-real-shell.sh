#!/usr/bin/env bash
set -euo pipefail

# Start Codex inside the tmux daemon.
# Customize this file for your local Node/NVM/Codex installation.

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.nvm/nvm.sh"
fi

exec codex
