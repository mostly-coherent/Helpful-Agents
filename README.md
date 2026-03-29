# Helpful Agents

> Skills, commands, rules, and subagents for Cursor and Claude Code. Install once, available everywhere.

## Quick Start

### New Builder

```bash
cd "Helpful Agents"
./install.sh
```

That's it. Skills, commands, agents, and rules are now available in both Cursor and Claude Code across all your workspaces.

### Returning Builder (Get Latest)

```bash
cd "Helpful Agents"
./install.sh
```

The install script auto-pulls from git, compares against your current setup, installs updates, and shows exactly what changed:

```
📋 What changed

  + NEW (1):
    + rule:claude:cli-nudge.md

  ~ UPDATED (2):
    ~ skill:cursor:context-engineer
    ~ agent:claude:rigorous-analysis-opus.md

  Total: 1 new, 2 updated, 74 unchanged
```

### Maintainer (Dogfood Loop)

```bash
cd "Helpful Agents"
./install.sh --dogfood
```

Syncs your workspace edits into the repo (both `.cursor/` and `.claude/`), pulls remote changes, installs everything, and shows what changed. One command.

### All Flags

| Flag | What it does |
|------|-------------|
| (none) | Pull latest, install, show what changed |
| `--dry-run` | Show what would change without installing |
| `--dogfood` | Sync workspace → repo → pull → install (maintainer loop) |
| `--no-pull` | Skip git pull (offline mode) |

Flags combine: `./install.sh --dogfood --dry-run` previews the full loop without touching anything.

---

## What You Get

Everything installs to user level (`~/.claude/` and `~/.cursor/`) — available in every workspace with either tool.

### Rules (Ambient — No Invocation Needed)

| Rule | Triggers on... | What it does |
|------|----------------|-------------|
| **brainstorm** | "Help me brainstorm", "Let's brainstorm" | Guided Q&A, one question at a time, user picks output format |
| **take-note** | "Take a note:", "Note:", "Quick note:" | Captures notes, infers location, extracts action items |
| **cli-nudge** | Task characteristics (automatic) | Detects when CLI would be better, advises once per conversation |

### Skills (30 in `.cursor/skills/`; 29 in `.claude/skills/` — `sync-cursor-to-repo` is Cursor-only)

**Code & Development**

| Skill | What it does |
|-------|-------------|
| **plan-review-gate** | Reviews PLAN.md for completeness before coding starts |
| **debug-audit** | Full project audit: bugs, performance, accessibility |
| **codefix** | Code review for bugs, race conditions, error handling |
| **rearchitecture** | Document component architecture and boundaries |
| **app-password-auth** | Add password auth with idle timeout to Next.js apps |
| **generate-server-scripts** | Start/stop/check scripts for multi-service projects |

**Documentation**

| Skill | What it does |
|-------|-------------|
| **requirement-agent** | Create or update PRDs and Builder Briefs |
| **critique-requirements** | Structured feedback on requirements docs |
| **cleanup-docs** | Harmonize scattered .md files to 6-file structure |
| **cleanup-folder** | Clean up and organize files in a directory |
| **upgrade-canonical-docs** | Standardize doc names/formats to latest templates |
| **business-guide** | Translate technical content to business-friendly language |

**Web Extraction**

| Skill | What it does |
|-------|-------------|
| **extract-sitemap** | Map links, check accessibility, generate sitemap |
| **extract-webpage-content** | Extract all content from pages (text, images, accordions) |
| **extract-page-shallow** | Extract one page + direct links only |
| **extract-design-system** | Extract colors, typography, spacing from a website |

**Research & Analysis**

| Skill | What it does |
|-------|-------------|
| **multi-angle-research** | 5-track research + executive summary on any topic |
| **multi-llm-rigorous-analysis** | 4-LLM critique (Sonnet, Opus, GPT, Gemini) |
| **moat-analysis** | 10-moat framework + optional multi-LLM stress test on a company |
| **project-health-audit** | Audit for conflicts, gaps, risks, hygiene |
| **fact-check** | Scan docs for unverified claims and ambiguous phrasing |
| **kb-drift-report** | Detect knowledge base drift and staleness |
| **kb-runner** | Run knowledge base operations |
| **service-kb-template** | Template for service knowledge bases |

**Workflow & Infrastructure**

| Skill | What it does |
|-------|-------------|
| **accountability-checkin** | Focus check-in using FOCUS.md, surfaces next action |
| **update-upstream-fork** | Pull latest from upstream into a fork |
| **workspace-privacy** | Sanitize workspace for sharing (remove PII) |
| **dev-environment-setup** | One-time setup: Node, Git, Python, MCP, Docker |
| **sync-cursor-to-repo** | Mirror Cursor user/project configs into a git repo (Cursor install path only) |
| **context-engineer** | Create the right AI context primitive (rule, skill, agent, hook) by referencing latest Claude Code & Cursor docs |

### Commands (Invoke with `/command-name`)

| Command | What it does |
|---------|-------------|
| `/format-doc` | Style normalization (headings, bullets, spacing) |
| `/revise-doc` | Lossless distillation for clarity and flow |
| `/optimize-doc` | Light-touch refinement, preserve all claims |
| `/refine-readme` | Turn README into best-in-class |
| `/list-questions` | Extract open questions from a document |
| `/list-conflicts` | Extract conflicting facts from a document |
| `/create-builder-brief` | Generate a Builder Brief |
| `/create-business-guide` | Business-facing guide from technical docs |
| `/critique-doc` | Structured critique of a requirements doc |
| `/local-to-wiki` | Markdown → Confluence storage format (full sync needs a Confluence MCP; paste mode always works) |
| `/wiki-to-local` | Confluence page to clean Markdown |

### Subagents (Auto-Delegated)

| Agent | Model | Purpose |
|-------|-------|---------|
| **rigorous-analysis-sonnet** | Claude Sonnet | Sonnet's perspective on a document |
| **rigorous-analysis-opus** | Claude Opus | Opus's perspective |
| **rigorous-analysis-gpt** | GPT Codex | GPT's perspective |
| **rigorous-analysis-gemini** | Gemini Pro | Gemini's perspective |
| **company-research** | Inherit | Company analysis: business model, products, competitors |

The four `rigorous-analysis-*` agents are used by `multi-llm-rigorous-analysis`. Each fetches research from 12 thought-leader sources and produces a critique.

### Workspace Templates (Optional)

These live in `workspace/skills/` and copy into the **parent** of this repo (your lab or monorepo root) under `.claude/skills/` and `.cursor/skills/` — **only if that template folder does not already exist**, so your edits are preserved.

| Template | What to customize |
|----------|-------------------|
| **create-project** | Workspace paths, git config, stack defaults |
| **git-sync** | `WORKSPACE_ROOT`, GitHub org/user, git email |

**Not shipped:** **`slack-triage` is intentionally removed** from this repo (no Slack workspace template here). `install.sh` also **skips** `slack-triage` when copying workspace templates, so it won’t reappear on `install.sh` runs. If you need Slack triage, keep a **private** skill in your own `MyPrivatePrompts` (or equivalent) — never fork work-specific context into the public templates.

---

## Common Workflows

| Goal | Steps |
|------|-------|
| Capture an idea quickly | "Take a note: [content]" |
| Develop an idea | "Help me brainstorm [topic]" |
| Write requirements | `/create-builder-brief` → `critique-requirements` |
| Before building | `plan-review-gate` on PLAN.md |
| Clean up docs | `/optimize-doc` → `/revise-doc` → `/format-doc` |
| Code quality | `debug-audit` → `codefix` |
| Extract from web | `extract-sitemap` → `extract-webpage-content` |
| Strategic research | `multi-angle-research` → `multi-llm-rigorous-analysis` |
| Company defensibility | `moat-analysis` (optional stress test via multi-LLM) |
| Publish your skills | "Update Helpful Agents" or `./install.sh --dogfood` |

---

## How It Works

### Dual-Tool Architecture

Both Cursor and Claude Code read the same skill/command/rule content. The only differences are folder names and rule file extensions:

| | Claude Code | Cursor |
|---|---|---|
| **Skills** | `.claude/skills/` | `.cursor/skills/` |
| **Commands** | `.claude/commands/` | `.cursor/commands/` |
| **Agents** | `.claude/agents/` | `.cursor/agents/` |
| **Rules** | `.claude/rules/*.md` | `.cursor/rules/*.mdc` |

`install.sh` handles both — one run installs to `~/.claude/` and `~/.cursor/`.

### Scope Model

| Level | Location | Applies to |
|-------|----------|-----------|
| **User-level** | `~/.claude/`, `~/.cursor/` | All workspaces |
| **Workspace-level** | `.claude/`, `.cursor/` in project | Current workspace only |

Skills, commands, agents, and rules install to **user-level** (available everywhere). Workspace templates install only if they don't already exist (preserves your customizations). Blocked template names (currently **`slack-triage`**) are defined in `install.sh` as `WORKSPACE_SKILL_SKIP` and are never copied.

### Articles

Two reference articles in this repo for deeper context:

| Article | What it covers |
|---------|---------------|
| `Builder-Guide_Cursor-ClaudeDesktop-CLI.md` | When to use Cursor vs Claude Desktop vs CLI — the three-tier mental model |
| `Cursor-vs-ClaudeCode_Config-Primitives.md` | How skills, commands, rules, hooks, and subagents map between tools |

---

## For AI Agents Reading This Repo

If you're an AI agent exploring this repo on behalf of a user:

1. **To install:** Run `./install.sh` from the repo root. It's idempotent and safe to re-run.
2. **To update:** Run `./install.sh` (auto-pulls latest). Use `--dry-run` to preview first.
3. **To publish user's changes:** Run `./install.sh --dogfood` to sync their workspace into the repo and install.
4. **To understand a specific skill:** Read `.claude/skills/<name>/SKILL.md` (or `.cursor/skills/<name>/SKILL.md` — same content).
5. **To understand the tool differences:** Read `Cursor-vs-ClaudeCode_Config-Primitives.md`.

---

**Last Updated:** 2026-03-29 — Removed **`context-advisor`** (use **`context-engineer`**); documented **30 / 29** Cursor vs Claude skill split; `sync-cursor-to-repo` row added to table.
