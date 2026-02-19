# Dev Environment Setup

One-time setup that installs everything you need to build apps with Cursor. The AI agent does all the work — you don't touch the terminal.

## Prerequisites

1. **Cursor** — download from [cursor.com](https://cursor.com), sign in with Google
2. **GitHub Personal Access Token** — create at [github.com/settings/tokens](https://github.com/settings/tokens) (classic, scopes: `repo`, `read:org`, `workflow`)

That's it. Everything else is installed by the skill.

## What It Installs

| Tools | MCP Servers |
|-------|-------------|
| Homebrew (Mac) | GitHub — repo management |
| Node.js 20 LTS + npm | Playwright — browser automation |
| Python 3.12+ | Context7 — live library docs |
| Git | Fetch — web content retrieval |
| GitHub CLI | Sequential Thinking — step-by-step reasoning |
| Vercel CLI | Memory — persistent context across sessions |
| Supabase CLI | Notion — read/write pages and databases |
| Docker Desktop | Linear — project management (issues, cycles) |
| jq, tree, wget | Figma — design-to-code bridge |

## How to Use

1. Open the Helpful Agents folder in Cursor
2. Open Chat (`Cmd+L` / `Ctrl+L`)
3. Type: `@dev-environment-setup Set up my dev environment`
4. The agent handles the rest

## How It Works

- Detects your OS (Mac/Windows/Linux)
- Checks what's already installed — skips those
- Installs missing tools: tries primary method, falls back to alternatives if that fails
- Configures 9 MCP servers (merges with your existing config — won't overwrite)
- Shows a scorecard at the end

If something fails, it tries another way. If all methods fail, it logs the issue and moves on — one failure never blocks the rest.

## MCP Server Details

| Server | Auth Required | Notes |
|--------|--------------|-------|
| GitHub | GitHub PAT (from prerequisites) | Core — manages repos from Cursor |
| Playwright | None | Browser automation, testing |
| Context7 | None | Up-to-date docs for any library |
| Fetch | None | AI can read any webpage |
| Sequential Thinking | None | Better reasoning on complex problems |
| Memory | None | AI remembers across conversations |
| Notion | Notion login (prompted on first use) | PMs live in Notion |
| Linear | Linear login (prompted on first use) | Project management for teams |
| Figma | Figma API key (optional, add later) | Design collaboration |

## Supports

- macOS (Intel + Apple Silicon)
- Windows 10/11
- Linux (Debian/Ubuntu, Fedora, Arch)
