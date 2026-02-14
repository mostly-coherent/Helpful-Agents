---
name: dev-environment-setup
description: One-time developer environment setup for building apps with Cursor. Installs Node.js, Git, GitHub CLI, Python, package managers, MCP servers, Vercel CLI, Supabase CLI, and common tools. Detects OS (Mac/Windows/Linux) and runs idempotent installs. Use when user says "set up my dev environment", "install dependencies", "bootstrap my laptop", "first time setup", or "workshop setup".
---

# Dev Environment Setup

Sets up everything needed to build and ship apps with Cursor — in one shot. The agent (you) does all the work. The user should never have to type a terminal command.

## When to Use

- First time using Cursor to build apps
- Setting up a new laptop for development
- Preparing for a Cursor workshop or buildathon
- Someone asks "what do I need to install?"

## Critical: Agent Behavior

**You are setting up a non-technical user's machine. They are likely a PM, designer, or someone who has never used a terminal.**

1. **Run ALL commands yourself** using the Shell tool. Never ask the user to copy/paste terminal commands.
2. **Never stop on failure.** If one tool fails, log it and move to the next. Install everything you can.
3. **Skip what's already installed.** Check first, install only what's missing.
4. **Preserve existing config.** When writing MCP config, merge — don't overwrite.
5. **Explain what you're doing in plain English** as you go. No jargon.
6. **At the end, show a simple scorecard** — what's ready, what needs attention.

## What Gets Installed

| Category | Tools | Why They Need It |
|----------|-------|-----------------|
| **Runtime** | Node.js 20 LTS, npm | Runs web apps and MCP servers |
| **Runtime** | Python 3.12+ | For Python-based projects |
| **Version Control** | Git | Tracks code changes, connects to GitHub |
| **Version Control** | GitHub CLI (`gh`) | Manages GitHub repos from Cursor |
| **Package Manager** | Homebrew (Mac) | Installs everything else on Mac |
| **Deployment** | Vercel CLI | Ships apps to the internet |
| **Database** | Supabase CLI | Database development |
| **Utilities** | jq, tree | JSON processing, directory visualization |
| **MCP: GitHub** | `@modelcontextprotocol/server-github` | Search code, manage repos inside Cursor |
| **MCP: Playwright** | `@playwright/mcp` | Browser automation, testing |
| **MCP: Context7** | `@upstash/context7-mcp` | Live docs for any library |

## Workflow — Execute All Steps Yourself

### Step 1: Detect OS and Check What's Already Installed

Run these checks silently. Don't ask the user — just do it.

```bash
# Detect OS
uname -s  # Darwin = Mac, Linux = Linux

# Check each tool
node -v 2>/dev/null
npm -v 2>/dev/null
git --version 2>/dev/null
gh --version 2>/dev/null
python3 --version 2>/dev/null || python --version 2>/dev/null
vercel --version 2>/dev/null
supabase --version 2>/dev/null
jq --version 2>/dev/null
tree --version 2>/dev/null
which brew 2>/dev/null  # Mac only
```

Tell the user: "Let me check what's already on your machine..." then report what's installed and what you'll add.

### Step 2: Install Package Manager (Mac only)

**Mac — Homebrew:**
```bash
# Only if brew is not found
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Apple Silicon PATH fix
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Windows:** winget is pre-installed. If missing, tell user to install "App Installer" from Microsoft Store.

### Step 3: Install Tools (One by One, Skip What Exists)

Run each install command yourself. If one fails, log it and continue to the next.

**Mac (via Homebrew):**
```bash
brew install git           # if git not found
brew install node@20       # if node < v18
brew link --overwrite node@20 2>/dev/null || true
brew install python@3.12   # if python < v3.10
brew install gh            # if gh not found
brew install supabase/tap/supabase  # if supabase not found
brew install jq            # if jq not found
brew install tree          # if tree not found
npm install -g vercel      # if vercel not found (after node is installed)
```

**Windows (via winget + npm):**
```powershell
winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
winget install --id Python.Python.3.12 -e --accept-package-agreements --accept-source-agreements
winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
winget install --id jqlang.jq -e --accept-package-agreements --accept-source-agreements
npm install -g vercel
npm install -g supabase
```

**After each install, verify it worked:**
```bash
node -v    # should show v20+
git --version
gh --version
# etc.
```

### Step 4: Authenticate GitHub CLI

```bash
gh auth status
```

If not authenticated, run:
```bash
gh auth login
```
This opens a browser for the user to log in with their GitHub account. Tell them: "A browser window will open — log into your GitHub account there."

### Step 5: Configure MCP Servers

Read existing config, merge in new servers, write back. **Never overwrite existing servers.**

**MCP config location:**
- Mac/Linux: `~/.cursor/mcp.json`
- Windows: `%USERPROFILE%\.cursor\mcp.json`

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
    }
  }
}
```

**Use jq to merge safely if available.** If not, read the file, parse it, and write back with the new servers added.

### Step 6: GitHub Personal Access Token

Check if `GITHUB_TOKEN` is set. If not, guide the user:

Tell them (in plain English, not terminal commands):
1. Open this link in your browser: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name it "Cursor" and check the box next to "repo"
4. Click "Generate token" and copy the token
5. Come back to Cursor

Then set it in the MCP config for them (update the `env` block in `~/.cursor/mcp.json`), or tell them to paste it in Cursor Settings → MCP → GitHub → Environment Variables.

### Step 7: API Keys Guidance

Tell the user which API keys they'll want (don't store these — just inform):

| Key | Where | Free Tier | Priority |
|-----|-------|-----------|----------|
| **Anthropic** | console.anthropic.com | $5 free credit | Get this one |
| **OpenAI** | platform.openai.com | Pay-as-you-go | Optional |
| **Supabase** | supabase.com/dashboard | 2 free projects | When building with a database |

### Step 8: Verify and Report

Run the verification script to check everything:

```bash
bash scripts/verify.sh
```

Or manually check each tool and report a scorecard to the user:

```
Your Setup Scorecard:
✅ Node.js     v20.18.0
✅ npm         v10.8.2
✅ Git         v2.43.0
✅ GitHub CLI  v2.62.0 (authenticated)
✅ Python      v3.12.4
✅ Vercel CLI  v39.2.0
✅ Supabase    v2.10.0
✅ jq          v1.7.1
✅ tree        v2.1.1
✅ MCP: GitHub     configured
✅ MCP: Playwright configured
✅ MCP: Context7   configured

⚠️  GITHUB_TOKEN — not set yet (you'll need this for GitHub MCP)
```

### Step 9: Post-Setup

Tell the user:
1. "Restart Cursor so the MCP servers load."
2. "You're all set! Everything is installed."

If there were failures, explain each one in plain English and offer to retry.

## Design Principles

- **Agent does the work.** User never touches the terminal.
- **Never stops on failure.** Each tool is independent. Install everything you can.
- **Idempotent.** Safe to run again — skips what's already installed.
- **Preserves existing config.** MCP merge, not overwrite.
- **No secrets in files.** API keys are guided, never written by the script.
- **Plain English.** No jargon in user-facing messages.

## Troubleshooting

See [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) for common issues.

---

**Version:** 2.0
**Last Updated:** 2026-02-11
