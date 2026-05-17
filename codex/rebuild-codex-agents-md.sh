#!/usr/bin/env bash
# Rebuild $HOME/.codex/AGENTS.md from template + current memory index.
# Run after writing any memory file (the owner will see effect on next Codex restart).
set -e

TMPL=$HOME/.codex/AGENTS.md.tmpl
INDEX=$HOME/.codex/memories/MEMORY.md
OUT=$HOME/.codex/AGENTS.md

if [ ! -f "$TMPL" ]; then
  echo "rebuild_agents.sh: missing $TMPL" >&2
  exit 1
fi
if [ ! -f "$INDEX" ]; then
  echo "rebuild_agents.sh: missing $INDEX (creating empty)" >&2
  mkdir -p "$(dirname $INDEX)"
  : > "$INDEX"
fi

{
  cat "$TMPL"
  echo ""
  echo "## Memory Index (auto-inserted from $HOME/.codex/memories/MEMORY.md)"
  echo ""
  cat "$INDEX"
} > "$OUT"

echo "rebuilt $OUT ($(wc -l < $OUT) lines)"
