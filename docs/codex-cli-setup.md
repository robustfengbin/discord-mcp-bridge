# Codex CLI Setup

This guide shows how to run `discord-mcp-bridge` with OpenAI Codex CLI.

The bridge keeps the original Claude Code MCP notification path, and adds an
optional tmux delivery path for Codex CLI. When `DISCORD_TMUX_TARGET` is set,
Discord messages that pass the access gate are injected into a named tmux
session with `tmux send-keys -l`, so Codex receives the message as a normal
interactive prompt.

## When to use this mode

Use this setup when you want:

- One Discord bot to relay work to a Codex CLI session.
- A mixed AI room where Claude Code and Codex can both see Discord context.
- A long-running Codex daemon that can receive Discord messages without manual
  copy and paste.
- Access control through `access.json` before any message reaches Codex.

Do not expose this bridge to public channels without a strict allowlist.
Discord messages become prompts to your local AI session, so prompt-injection
risk is real even though tmux key injection is literal and does not invoke a
shell.

## Prerequisites

- Bun installed.
- `tmux` installed.
- Codex CLI installed and already authenticated.
- A Discord application bot token.
- Discord Message Content Intent enabled for the bot.
- A private server or controlled channel for first setup.

## Fresh Clone Quickstart

Clone and install:

```bash
git clone https://github.com/<owner>/discord-mcp-bridge.git ~/codex-discord
cd ~/codex-discord
bun install
```

Create a state directory:

```bash
mkdir -p ~/codex/discord-state
chmod 700 ~/codex/discord-state
```

Store the bot token outside the repo:

```bash
cat > ~/codex/discord-state/.env <<'EOF'
DISCORD_BOT_TOKEN=<your-discord-bot-token>
EOF
chmod 600 ~/codex/discord-state/.env
```

Create `~/codex/discord-state/access.json`:

```json
{
  "dmPolicy": "allowlist",
  "allowFrom": ["<owner-discord-user-id>"],
  "groups": {
    "<discord-channel-id>": {
      "requireMention": true,
      "allowFrom": ["<owner-discord-user-id>"]
    }
  },
  "ackReaction": "👀",
  "replyToMode": "first",
  "textChunkLimit": 1900,
  "chunkMode": "newline"
}
```

For a multi-AI room, add the other bot user IDs to the channel `allowFrom`.
Use an empty channel `allowFrom` only if everyone in that channel is trusted.

## Codex Config

Add the Discord MCP server to `~/.codex/config.toml`.

Use the example in `examples/codex-config.toml.example` and adjust these
values:

- `command`: path to your `bun` binary.
- `args[2]`: path to your local `discord-mcp-bridge` checkout.
- `DISCORD_STATE_DIR`: path to the state directory created above.
- `DISCORD_TMUX_TARGET`: tmux session name that will run Codex.

Minimal example:

```toml
[mcp_servers.discord]
command = "/home/<user>/.bun/bin/bun"
args = ["run", "--cwd", "/home/<user>/codex-discord", "server.ts"]
startup_timeout_sec = 30
tool_timeout_sec = 120

[mcp_servers.discord.env]
DISCORD_STATE_DIR = "/home/<user>/codex/discord-state"
DISCORD_TMUX_TARGET = "codex-discord-direct"
```

## Start the Codex tmux daemon

Copy the example launcher:

```bash
mkdir -p ~/bin
cp ~/codex-discord/examples/start-codex-discord-daemon.sh ~/bin/
cp ~/codex-discord/examples/start-codex-real-shell.sh ~/bin/
chmod +x ~/bin/start-codex-discord-daemon.sh ~/bin/start-codex-real-shell.sh
```

Start or attach to the daemon:

```bash
~/bin/start-codex-discord-daemon.sh
```

The script creates a tmux session named `codex-discord-direct` and runs
`start-codex-real-shell.sh` inside it. That second script starts Codex.

If your Codex CLI asks whether to trust the current directory on first launch,
answer it in the tmux session once. After that, inbound Discord messages can
trigger Codex turns.

## Verify the bridge

Start the MCP server through Codex by launching Codex with the config above.
Then send a message in the allowed Discord channel.

Expected behavior:

1. The bridge reacts with the configured `ackReaction`.
2. The tmux Codex session receives a prompt shaped like:

   ```xml
   <channel source="discord" chat_id="..." message_id="..." user="..." user_id="..." ts="...">
   message text
   </channel>
   ```

3. Codex decides whether to reply based on its `AGENTS.md` behavior protocol.
4. Codex can use the Discord MCP tools to reply, react, fetch messages, edit
   its own messages, and download attachments.

## Safety checklist

Before going beyond a private test channel:

- Keep `DISCORD_STATE_DIR` outside the git repo.
- Never commit `.env`, `access.json`, bot tokens, cookies, or private keys.
- Use `dmPolicy: "allowlist"` for active deployments. Use `dmPolicy:
  "disabled"` only when you intentionally want to shut off all inbound
  delivery, including guild channels.
- Set channel `allowFrom` to explicit user and bot IDs.
- Keep `requireMention: true` unless the room is intentionally AI-operated.
- Put strict behavior rules in `~/.codex/AGENTS.md`.
- Avoid running Codex with broad machine privileges unless the Discord channel
  is tightly controlled.
- Treat every Discord message as untrusted prompt input.

## Troubleshooting

`DISCORD_BOT_TOKEN required`

: The bridge did not find a token in the environment or in
  `$DISCORD_STATE_DIR/.env`.

No Discord message reaches Codex

: Check `DISCORD_TMUX_TARGET`, confirm `tmux ls` shows that session name, and
  confirm the message passed `access.json` allowlist rules.

Discord messages have empty content

: Enable Message Content Intent in the Discord Developer Portal.

Codex sees messages but does not reply

: Check `AGENTS.md` behavior rules. In a multi-AI room, Codex may intentionally
  stay silent unless the message is directed at it or it has independent value.

The bot cannot read channel history

: Ensure the bot has `Read Message History`, `View Channels`, and
  `Send Messages` permissions in that Discord channel.
