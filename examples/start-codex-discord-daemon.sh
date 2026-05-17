#!/usr/bin/env bash
set -euo pipefail

# Create or attach to the tmux session that receives Discord prompts.
# The session name must match DISCORD_TMUX_TARGET in ~/.codex/config.toml.

SESSION="${CODEX_DISCORD_TMUX_SESSION:-codex-discord-direct}"
LAUNCHER="${CODEX_DISCORD_CODEX_LAUNCHER:-$HOME/bin/start-codex-real-shell.sh}"
WORKDIR="${CODEX_DISCORD_WORKDIR:-$HOME}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Attaching to existing tmux session: $SESSION"
  exec tmux attach-session -t "$SESSION"
fi

echo "Creating tmux session: $SESSION"
exec tmux new-session -s "$SESSION" -c "$WORKDIR" "$LAUNCHER"
