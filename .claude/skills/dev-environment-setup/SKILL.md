---
name: dev-environment-setup
description: One-time developer environment setup for building apps with Cursor. Installs Node.js, Git, GitHub CLI, Python, Homebrew, MCP servers, Vercel CLI, Supabase CLI, Docker, and common tools. Detects OS, uses fallback install methods, never stops on failure. Use when user says "set up my dev environment", "install dependencies", "bootstrap my laptop", "first time setup", or "workshop setup".
---

# Dev Environment Setup

Sets up everything needed to build and ship apps with Cursor — in one shot. The agent (you) does all the work. The user should never have to type a terminal command.

## Critical: Agent Behavior

**You are setting up a non-technical user's machine. They do not code. They do not use terminals.**

1. **Run ALL commands yourself.** Never ask the user to copy/paste terminal commands.
2. **Never stop on failure.** If one tool fails, try a fallback method. If all methods fail, log it and move to the next tool.
3. **Skip what's already installed.** Check first, install only what's missing.
4. **Preserve existing config.** When writing MCP config, merge — don't overwrite.
5. **Explain in plain English** as you go. No jargon.
6. **Show a scorecard at the end.**

## Prerequisites (User Must Do Before Running This Skill)

Only two things. Everything else is handled by this skill.

**1. Install Cursor desktop app and sign in**
- Download from [cursor.com](https://cursor.com), install, sign in with Google account

**2. Create a GitHub Personal Access Token (PAT)**
- This token lets Cursor's GitHub tools access your repos. Here's how to get one:
  1. Go to https://github.com/settings/tokens
  2. Click **"Generate new token (classic)"** (not "Fine-grained")
  3. **Note:** Name it `Cursor`
  4. **Expiration:** Choose "90 days" or "No expiration"
  5. **Scopes — check these boxes:**
     - `repo` — Full control of private repositories
     - `read:org` — Read org membership (useful if you're in a GitHub org)
     - `workflow` — Update GitHub Actions workflows (needed for CI/CD)
  6. Click **"Generate token"**
  7. **Copy the token immediately** (starts with `ghp_...`) — you won't see it again
  8. Save it somewhere safe (a note on your phone, password manager, etc.)

## What Gets Installed

| Category | Tools | Why |
|----------|-------|-----|
| **Package Manager** | Homebrew (Mac) | Installs everything else on Mac |
| **Runtime** | Node.js 20 LTS + npm | Runs web apps, powers MCP servers |
| **Runtime** | Python 3.12+ | For Python-based projects and scripts |
| **Version Control** | Git | Tracks code changes, connects to GitHub |
| **Version Control** | GitHub CLI (`gh`) | Manages GitHub repos from Cursor |
| **Deployment** | Vercel CLI | Ships apps to the internet |
| **Database** | Supabase CLI | Database development |
| **Containers** | Docker Desktop | Runs databases, services locally |
| **Utilities** | jq | JSON processing |
| **Utilities** | tree | Directory visualization |
| **Utilities** | wget | File downloads from terminal |
| **MCP** | GitHub | Search code, manage repos inside Cursor |
| **MCP** | Playwright | Browser automation, testing |
| **MCP** | Context7 | Live docs for any library/framework |
| **MCP** | Fetch | Web content retrieval for AI |
| **MCP** | Sequential Thinking | Makes AI reason step-by-step on hard problems |
| **MCP** | Memory | AI remembers context across conversations |
| **MCP** | Notion | Read/write Notion pages and databases |
| **MCP** | Linear | Project management — issues, projects, cycles |
| **MCP** | Figma | Design-to-code, access design files from Cursor |

## Install Strategy: Try, Fallback, Skip

**For every tool, follow this pattern:**

```
1. Check if already installed → skip if yes
2. Try primary install method (brew on Mac, winget on Windows)
3. If primary fails → try fallback method (npm, direct download, curl)
4. If fallback fails → try second fallback if available
5. If all methods fail → log the failure with a plain-English explanation and move on
```

**Never exit. Never stop. Always continue to the next tool.**

## Workflow — Execute All Steps Yourself

### Step 1: Detect OS and Audit Existing Tools

Run all of these in one batch. Don't ask the user — just do it.

```bash
uname -s
node -v 2>/dev/null || echo "NOT_INSTALLED"
npm -v 2>/dev/null || echo "NOT_INSTALLED"
git --version 2>/dev/null || echo "NOT_INSTALLED"
gh --version 2>/dev/null | head -1 || echo "NOT_INSTALLED"
python3 --version 2>/dev/null || python --version 2>/dev/null || echo "NOT_INSTALLED"
vercel --version 2>/dev/null | head -1 || echo "NOT_INSTALLED"
supabase --version 2>/dev/null || echo "NOT_INSTALLED"
docker --version 2>/dev/null || echo "NOT_INSTALLED"
jq --version 2>/dev/null || echo "NOT_INSTALLED"
tree --version 2>/dev/null | head -1 || echo "NOT_INSTALLED"
wget --version 2>/dev/null | head -1 || echo "NOT_INSTALLED"
which brew 2>/dev/null || echo "NOT_INSTALLED"
cat ~/.cursor/mcp.json 2>/dev/null || echo "NO_MCP_CONFIG"
gh auth status 2>/dev/null; echo "GH_AUTH_EXIT:$?"
```

Tell the user: "Let me check what's already on your machine..." then briefly report what's installed and what you'll add.

### Step 2: Homebrew (Mac Only)

```bash
# Primary: official installer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon PATH fix (run after install)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi
```

If Homebrew fails, note it and use direct download methods for subsequent tools.

### Step 3: Install Tools (One by One, With Fallbacks)

**For each tool below: check → try primary → try fallback → verify → log result.**

---

#### Git

**Mac primary:** `brew install git`
**Mac fallback:** `xcode-select --install` (triggers Xcode CLI tools)
**Windows primary:** `winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements`
**Windows fallback:** Tell user to download from https://git-scm.com
**Verify:** `git --version`

---

#### Node.js 20 LTS

**Mac primary:** `brew install node@20 && brew link --overwrite node@20 2>/dev/null || true`
**Mac fallback:** Download and install from https://nodejs.org using curl:
```bash
curl -fsSL https://nodejs.org/dist/v20.18.1/node-v20.18.1.pkg -o /tmp/node.pkg && sudo installer -pkg /tmp/node.pkg -target / && rm /tmp/node.pkg
```
**Windows primary:** `winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements`
**Windows fallback:** Tell user to download from https://nodejs.org
**Verify:** `node -v` (should show v20+) and `npm -v`

---

#### Python 3.12+

**Mac primary:** `brew install python@3.12`
**Mac fallback:** macOS ships with Python 3 via Xcode CLI tools. Check `python3 --version`.
**Windows primary:** `winget install --id Python.Python.3.12 -e --accept-package-agreements --accept-source-agreements`
**Windows fallback:** Tell user to download from https://python.org
**Verify:** `python3 --version` or `python --version`

---

#### GitHub CLI

**Mac primary:** `brew install gh`
**Mac fallback:**
```bash
curl -fsSL https://github.com/cli/cli/releases/latest/download/gh_*_macOS_arm64.zip -o /tmp/gh.zip && unzip -o /tmp/gh.zip -d /tmp/gh && sudo cp /tmp/gh/*/bin/gh /usr/local/bin/ && rm -rf /tmp/gh /tmp/gh.zip
```
**Windows primary:** `winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements`
**Verify:** `gh --version`

---

#### Vercel CLI

**Primary (all OS):** `npm install -g vercel`
**Verify:** `vercel --version`

---

#### Supabase CLI

**Mac primary:** `brew install supabase/tap/supabase`
**Fallback (all OS):** `npm install -g supabase`
**Verify:** `supabase --version`

---

#### Docker Desktop

**Mac primary:** `brew install --cask docker`
**Mac fallback:** Tell user to download from https://docker.com/products/docker-desktop
**Windows primary:** `winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements`
**Windows fallback:** Tell user to download from https://docker.com/products/docker-desktop
**Verify:** `docker --version`
**Note:** Docker Desktop may require a restart and user to open the app once. This is OK — log it as a note.

---

#### jq

**Mac primary:** `brew install jq`
**Mac fallback:** `curl -fsSL https://github.com/jqlang/jq/releases/latest/download/jq-macos-arm64 -o /usr/local/bin/jq && chmod +x /usr/local/bin/jq`
**Windows primary:** `winget install --id jqlang.jq -e --accept-package-agreements --accept-source-agreements`
**Verify:** `jq --version`

---

#### tree

**Mac primary:** `brew install tree`
**Windows:** Built-in (`tree` command exists natively). Skip install.
**Verify:** `tree --version` (Mac) or `tree /?` (Windows)

---

#### wget

**Mac primary:** `brew install wget`
**Windows primary:** `winget install --id JernejSimoncic.Wget -e --accept-package-agreements --accept-source-agreements`
**Fallback:** Skip — `curl` is available on both platforms as alternative.
**Verify:** `wget --version | head -1`

---

### Step 4: Authenticate GitHub CLI

```bash
gh auth status
```

If not authenticated:
```bash
gh auth login --web --git-protocol https
```

Tell the user: "A browser window will open — just log into your GitHub account there and click Authorize."

If `gh auth login` requires interaction that the Shell tool can't handle, tell the user:
"I need you to do one thing: a browser window should have opened. Log into GitHub and click 'Authorize'. Let me know when you're done."

### Step 5: Configure MCP Servers

**MCP config location:** `~/.cursor/mcp.json`

Read existing config. Merge in new servers. **Never overwrite existing servers.**

**Servers to add (if not already present):**

```json
{
  "mcpServers": {
    "GitHub": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "notion": {
      "url": "https://mcp.notion.com/mcp"
    },
    "linear": {
      "url": "https://mcp.linear.app/mcp"
    },
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--stdio"],
      "env": {
        "FIGMA_API_KEY": "${FIGMA_API_KEY}"
      }
    }
  }
}
```

**Notes on specific servers:**
- **Notion** and **Linear** use remote URLs — they'll prompt the user to authenticate via browser on first use. No API key needed upfront.
- **Figma** needs a `FIGMA_API_KEY`. Tell the user: "You can get a Figma API key later from figma.com/developers — it's not needed right now."
- **Sequential Thinking** and **Memory** are zero-config — they just work.

**Merge strategy:**
1. Read `~/.cursor/mcp.json` (or start with `{"mcpServers":{}}` if missing)
2. For each server above: only add if that key doesn't already exist
3. Write back the merged config

Use `jq` if available. If not, read the file, use string manipulation or write a small node script to merge.

### Step 6: Set GITHUB_TOKEN in MCP Config

Ask the user: "Do you have your GitHub Personal Access Token ready? (The one you created before starting — it starts with `ghp_`)"

If yes, ask them to paste it. Then update `~/.cursor/mcp.json` to replace `${GITHUB_TOKEN}` with the actual token in the GitHub MCP server's env block.

If no, tell them:
"No problem — the GitHub MCP server won't work until you add it, but everything else is ready. You can add it later in Cursor Settings → MCP → GitHub → Environment Variables."

### Step 7: Verify and Report Scorecard

Check every tool and MCP server. Report a clean scorecard:

```
Your Setup Scorecard:

Tools:
  ✅ Homebrew      installed
  ✅ Node.js       v20.18.0
  ✅ npm           v10.8.2
  ✅ Git           v2.43.0
  ✅ GitHub CLI    v2.62.0 (authenticated)
  ✅ Python        v3.12.4
  ✅ Vercel CLI    v39.2.0
  ✅ Supabase CLI  v2.10.0
  ✅ Docker        v27.4.0
  ✅ jq            v1.7.1
  ✅ tree          v2.1.1
  ✅ wget          v1.24.5

MCP Servers:
  ✅ GitHub              configured
  ✅ Playwright          configured
  ✅ Context7            configured
  ✅ Fetch               configured
  ✅ Sequential Thinking configured
  ✅ Memory              configured
  ✅ Notion              configured (authenticate on first use)
  ✅ Linear              configured (authenticate on first use)
  ✅ Figma               configured (add API key when ready)

Action needed:
  ⚠️  GITHUB_TOKEN — paste your token in Cursor Settings → MCP → GitHub
  ⚠️  Docker Desktop — open the app once to complete setup
  ⚠️  Notion — log in when Cursor prompts you (first use)
  ⚠️  Linear — log in when Cursor prompts you (first use)
  ⚠️  Figma API key — add later from figma.com/developers (optional for now)

All done! Restart Cursor so the MCP servers load.
```

If there are failures, explain each one in plain English:
- What it is (one sentence)
- Why it matters (one sentence)
- How to fix it manually (link to download page)

### Step 8: Post-Setup

Tell the user:
1. "Close and reopen Cursor so the MCP servers load."
2. "You're all set — your machine is ready to build apps with Cursor."

If Docker was installed, add: "Open the Docker app once from your Applications folder — it needs to finish its own setup."

## Design Principles

- **Agent does the work.** User never touches the terminal.
- **Try → Fallback → Skip.** Every tool has at least 2 install methods. If all fail, log and continue.
- **Never stops.** Each tool is independent. Failures don't block other installs.
- **Idempotent.** Safe to run again — skips what's already installed, retries what failed.
- **Preserves existing config.** MCP merge, not overwrite.
- **No secrets in files.** GITHUB_TOKEN is set via user input or Cursor Settings, never hardcoded.
- **Plain English.** No jargon in user-facing messages.

## Troubleshooting

See [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) for common issues.

---

**Version:** 3.1
**Last Updated:** 2026-02-11
