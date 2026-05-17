# Codex Setup Guide

This directory contains setup helpers for running this `discord-mcp-bridge` with
**OpenAI Codex CLI** in a tmux daemon configuration, including a
Claude-Code-style **persistent memory system** so Codex can carry context
across sessions.

## Files

| File | Purpose |
|---|---|
| `AGENTS.md.tmpl.example` | Template for `~/.codex/AGENTS.md.tmpl` — group chat behavior protocol + auto-memory rules. Customize then drop into your Codex config dir. |
| `MEMORY.md.example` | Template for `~/.codex/memories/MEMORY.md` — the compact index that gets injected into `AGENTS.md` on rebuild. |
| `rebuild-codex-agents-md.sh` | Script to regenerate `~/.codex/AGENTS.md` from the template + current memory index. Run after every memory write. |

## Memory System (A + C combo)

Codex CLI has a `~/.codex/memories/` directory but **no built-in auto-memory
feature** like Claude Code. This setup gives you the same behavior using two
ingredients:

- **A: Static inline** — the entire `MEMORY.md` index is concatenated into
  `AGENTS.md` at build time. Codex loads `AGENTS.md` on every session start
  and sees the full index immediately (no extra startup shell call).
- **C: Agent-compatible typed memory files** — each fact lives in its own
  `{type}_{name}.md` file under `~/.codex/memories/`. Types: `user`,
  `feedback`, `project`, `reference`.

When memory changes, run `rebuild-codex-agents-md.sh` and start a new
Codex session.

## Setup Steps

1. Place files:
   ```bash
   mkdir -p ~/.codex/memories
   cp AGENTS.md.tmpl.example ~/.codex/AGENTS.md.tmpl
   cp MEMORY.md.example ~/.codex/memories/MEMORY.md
   cp rebuild-codex-agents-md.sh ~/rebuild-codex-agents-md.sh
   chmod +x ~/rebuild-codex-agents-md.sh
   ```

2. Edit `~/.codex/AGENTS.md.tmpl` — replace the example owner Discord
   user_id, group ID, and any deployment-specific paths with yours.

3. First rebuild:
   ```bash
   ~/rebuild-codex-agents-md.sh
   ```
   This generates `~/.codex/AGENTS.md` (= template + memory index inline).

4. Start Codex daemon:
   ```bash
   tmux new-session -d -s codex-discord-direct -c "$HOME" "$HOME/start_tmux_real_shell.sh"
   ```
   (`start_tmux_real_shell.sh` should be a one-liner like:
   `source ~/.nvm/nvm.sh && exec codex`)

## Writing Memory

Codex will write its own memory entries when:

- The owner explicitly asks ("remember that...", "记下来 X")
- A task produces durable operating facts a future session needs

Each memory file format:

```markdown
---
name: Memory Title
description: One-line description used to decide relevance in future sessions
type: user|feedback|project|reference
---

{body. for feedback/project: lead with the rule/fact, then **Why:** and **How to apply:** lines}
```

After writing, append a one-line index entry to `~/.codex/memories/MEMORY.md`
under "Memory Files", then run `~/rebuild-codex-agents-md.sh`.

## What NOT to Save

Memory is **not** for:

- Code patterns / architecture / file paths (re-readable from source)
- Git history / blame data (`git log` is authoritative)
- Debugging recipes (the fix is in the code)
- Ephemeral task state (use plans / tasks instead)
- **Secrets** (tokens, cookies, keys, passwords, one-time codes) — record
  the *location* and *reset path*, not the value

## Why This Design

Compared to alternatives:

- **B: AGENTS.md tells Codex to `cat MEMORY.md` at session start** — wastes
  one shell tool call per session, and unattended auto-execute behavior
  depends on how you launch Codex.
- **Plain text in AGENTS.md without typed files** — works for tiny memory
  sets, but harder to grow / audit / share between AIs.

A+C gives you fast boot (no extra shell call), structured per-fact files
that diff cleanly in git, and a schema that can be shared across AI agents.
