# Changelog

All notable changes to this fork are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); upstream releases
are referenced by their plugin marketplace version where relevant.

## [0.1.0] — 2026-05-17

First public open-source release.

### Added

- `DISCORD_TMUX_TARGET` environment variable. When set, inbound messages that
  pass the access gate are also injected as keystrokes into the named tmux
  session via `tmux send-keys -l` (literal mode, no key-name interpretation,
  no shell). Lets AI CLIs that don't subscribe to MCP `notifications/claude/channel`
  server-push (e.g. OpenAI Codex CLI) react to Discord messages in real time
  when run as a tmux daemon. Original upstream notification path is preserved
  untouched.
- `codex/` directory with setup helpers for running this bridge with OpenAI
  Codex CLI in a tmux daemon configuration. Includes:
  - `AGENTS.md.tmpl.example` — group-chat behavior protocol template.
  - `MEMORY.md.example` — compact memory index template (Claude-Code-style
    auto-memory simulated via static inline + typed memory files).
  - `rebuild-codex-agents-md.sh` — regenerate `~/.codex/AGENTS.md` from
    template + current memory index.
- `FORK.md` (now merged into main `README.md`) — original fork-specific
  documentation.
- `NOTICE` — Apache-2.0 attribution + list of modifications.
- This `CHANGELOG.md`.

### Changed

- Replaced the upstream `msg.author.bot` inbound prefilter with a self-only
  check (`msg.author.id === client.user?.id`). Multi-AI group channels need
  to see *other bots'* messages so the AI's behavior protocol can decide
  whether to reply. Single-AI Claude Code DM setups are unaffected.
- README rewritten as a fork-first document. Upstream's setup walkthrough is
  preserved verbatim in `ACCESS.md`.

### Preserved

- The upstream MCP `notifications/claude/channel` server-push path is
  byte-identical to v0.0.4. Claude Code consumes this server with no behavior
  change relative to the official plugin.
- All upstream tools (`reply`, `react`, `edit_message`, `fetch_messages`,
  `download_attachment`) and skill commands (`/discord:access`,
  `/discord:configure`) are unchanged.

### Forked from

- `anthropics/claude-plugins-official` Discord plugin, version 0.0.4
  (Apache-2.0).

[0.1.0]: https://github.com/robustfengbin/discord-mcp-bridge/releases/tag/v0.1.0
