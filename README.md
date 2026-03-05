# Helpful Agents

> Reusable AI agents, skills, and commands for Cursor—development, documentation, and project scaffolding.

![Type](https://img.shields.io/badge/Type-AI%20Agents-purple)
![Status](https://img.shields.io/badge/Status-Active-green)
![Stack](https://img.shields.io/badge/Stack-Cursor%20%7C%20Claude-blue)

## What's in This Repo

| Type | Location | Scope | How to Use |
|------|----------|-------|------------|
| **User-level skills** | `.cursor/skills/` | All workspaces | Auto-invoke or mention by name |
| **User-level commands** | `.cursor/commands/` | All workspaces | `/command-name` in Cursor chat |
| **User-level rules** | `.cursor/rules/` | All workspaces | Apply intelligently (natural-language triggers) |
| **User-level agents** | `.cursor/agents/` | All workspaces | Cursor Agents panel or `@agent-name` |
| **Workspace skill templates** | `workspace/skills/` | Current workspace | Customize after install |
| **Workspace rules** | `workspace/rules/` | Current workspace | Cursor rules (e.g. accountability) |
| **Workspace templates** | `workspace/templates/` | Workspace root | FOCUS.md, etc. |
| **Templates** | Root `*.md` files | Any project | `@filename.md` as context |
| **Install script** | `install.sh` | — | One-time setup after clone |

### First-Time Setup

```bash
git clone https://github.com/mostly-coherent/Helpful-Agents.git
cd Helpful-Agents
./install.sh
```

`install.sh` places configs in two locations:
- **User-level** (`~/.cursor/`) — skills, commands, rules, and agents available in every workspace
- **Workspace** (parent folder of Helpful Agents) — skill templates, rules, and `FOCUS.md` (skipped if already customized)

**Tip:** Clone Helpful Agents into your main project folder so workspace configs land in the right place. For standalone clones, set `WORKSPACE_ROOT=/path/to/your/workspace ./install.sh`.

### Hooks (Auto-Trigger Skills)

**What are Hooks?** Cursor's automation layer — triggers skills automatically after file edits, saves, commits, etc. No manual invocation needed.

This repo includes `hooks.json` with three quality checks that auto-run after editing `.md` files:

| Hook | What It Does | Skill Referenced |
|------|--------------|------------------|
| **fact-check** | Scans for unverified claims, force-fit jargon, ambiguous phrasing | `fact-check` (public, included) |
| **detect-ai-slop** | Catches AI-generated patterns, mechanical phrasing | `detect-ai-slop` (private, not included) |
| **in-my-voice** | Ensures content sounds authentic, not generic AI | `in-my-voice` (private, not included) |

**Graceful degradation:** Hooks for missing skills fail silently — no errors, just skip. You can:
- Use `fact-check` immediately (public skill included)
- Add your own `detect-ai-slop` and `in-my-voice` skills if desired
- Edit `~/.cursor/hooks.json` to remove hooks you don't want
- Create your own hooks following Cursor's docs: https://cursor.com/docs/agent/hooks

**Installation:** `install.sh` copies `hooks.json` to `~/.cursor/hooks.json` (prompts before overwriting if you already have one).

---

## User-Level Rules

Apply-intelligently rules that activate on natural-language triggers. Installed to `~/.cursor/rules/` (available in all workspaces).

| Rule | Purpose | Trigger Examples |
|------|---------|------------------|
| **brainstorm** | Guide idea development through Q&A | "Help me brainstorm", "Let's brainstorm [topic]" |
| **take-note** | Capture ad-hoc notes to markdown | "Take a note:", "Note:", "Capture this:", "Jot down:" |

---

## User-Level Skills

Universal skills available in all Cursor workspaces after install.

### Code & Development

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **debug-audit** | Full project audit: bugs, performance, accessibility | "audit this project", "find bugs" |
| **codefix** | Code review for bugs, race conditions, error handling | "review this code", "prep for UAT" |
| **rearchitecture** | Document component boundaries and architecture | "document architecture" |
| **app-password-auth** | Add password-gated auth with idle timeout to Next.js | "add password protection" |
| **generate-server-scripts** | Generate start/stop/check scripts for multi-service projects | "generate server scripts" |

### Documentation

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **cleanup-docs** | Harmonize scattered .md files to canonical 6-file structure | "cleanup docs" |
| **cleanup-folder** | Clean up and organize files in a directory | "cleanup folder" |
| **upgrade-canonical-docs** | Standardize doc names and formats to latest templates | "upgrade canonical docs" |
| **business-guide** | Translate technical content to business-friendly language | "explain for stakeholders" |
| **requirement-agent** | Create or update PRDs and Builder Briefs | "create PRD", "Builder Brief" |
| **critique-requirements** | Structured feedback on requirements docs | "critique requirements" |

### Web Extraction

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **extract-webpage-content** | Extract all content from pages (text, images, accordions) | "extract webpage" |
| **extract-sitemap** | Map links from a page, check accessibility, generate sitemap | "discover site structure" |
| **extract-page-shallow** | Extract one page + direct links only (no deep crawl) | "shallow extraction" |
| **extract-design-system** | Extract colors, typography, spacing from a site | "extract design tokens" |

### Infrastructure & Workflow

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **update-upstream-fork** | Pull latest from upstream into a fork or cloned repo | "update fork", "pull upstream" |
| **workspace-privacy** | Sanitize workspace for sharing (remove PII) | "prep for sharing" |
| **dev-environment-setup** | One-time setup: Node, Git, Python, MCP, Docker | "set up dev environment" |
| **sync-cursor-to-repo** | Sync cursor configs to a shared repo | "sync skills to repo", "mirror configs" |

### Knowledge & Analysis

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **kb-drift-report** | Detect knowledge base drift and staleness | "check KB freshness" |
| **kb-runner** | Run knowledge base operations and queries | "run KB" |
| **service-kb-template** | Template for service knowledge bases | "create service KB" |

### Cursor Config

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **context-advisor** | Choose rules vs commands vs skills vs subagents vs Hooks | "should I create a rule or skill?", "gate agent actions" |
| **multi-llm-rigorous-analysis** | Rigorous critique of a write-up using multiple LLMs | "rigorous analysis", "critique with Gemini/GPT/Opus/Sonnet" |
| **accountability-checkin** | Structured check-in against your FOCUS.md plan | "check in", "what should I do next", "am I on track" |

---

## User-Level Agents

Subagents for deep analysis. Invoke via Cursor Agents panel or `@agent-name` with a source file.

| Agent | Model | Purpose |
|-------|-------|---------|
| **company-research** | Inherit | Researches a company comprehensively (business model, products, moats, competitors, risks) |
| **rigorous-analysis-gemini** | Gemini 3.1 Pro | Rigorous critique with web research from 12 thought-leader sources |
| **rigorous-analysis-gpt** | GPT 5.3 Codex | Same workflow, GPT perspective |
| **rigorous-analysis-opus** | Claude Opus | Same workflow, Opus perspective |
| **rigorous-analysis-sonnet** | Claude Sonnet | Same workflow, Sonnet perspective |

**Pipeline:** `@company-research [Company]` → produces analysis → `@rigorous-analysis-* @research/Company_Analysis.md` for multi-LLM critique.

---

## Accountability Workflow

The **accountability-checkin** skill + **accountability** rule + **FOCUS.md** template work together:

1. **FOCUS.md** — Your single source of truth for 4 active targets and a 10-week timeline. Lives at workspace root. Fill in your targets, actions, and dates.
2. **accountability rule** — Surfaces your plan when you drift or ask "what should I work on?" Installed to `.cursor/rules/`.
3. **accountability-checkin skill** — Runs a structured check-in: reads FOCUS.md, asks what you've done, calls out drift, gives one next action, updates the file. Run `@accountability-checkin` at session start or when you feel yourself drifting.

`install.sh` copies the rule and FOCUS template to your workspace (the folder containing Helpful Agents) — skips if you've already customized them. For best results, clone Helpful Agents into your main project folder so FOCUS.md lives at your workspace root.

---

## Workspace Skill Templates

These need per-workspace customization (paths, accounts, git config). `install.sh` copies them to your workspace `.cursor/skills/` — skips if a version already exists.

| Skill | Purpose | What to Customize |
|-------|---------|-------------------|
| **create-project** | Scaffold new project with docs and git | Workspace paths, git config, templates |
| **git-sync** | Safe git sync: push changes, PR workflow, CI setup | WORKSPACE_ROOT, GITHUB_USERNAME, GIT_EMAIL |
| **sync-cursor-to-repo** | Sync cursor configs to a shared repo | SHARED_REPO_PATH, exclusion lists |

---

## Workspace Rules

Rules installed to `.cursor/rules/` in your workspace (skip if already exists). Complement the accountability workflow.

| Rule | Purpose | When It Applies |
|------|---------|-----------------|
| **accountability** | Surfaces FOCUS.md when drifting or asking for direction | "what should I work on?", "where was I" |
| **conversational-flow** | One question at a time, build on answers, wait for response | Brainstorming, check-ins, discovery |
| **discovery** | Ask one discovery question at a time for rules/commands/skills | "Should I create a rule or skill?" |
| **requirements-gathering** | Ask one item at a time for Builder Brief, PRD, specs | requirement-agent, create-builder-brief |

---

## Commands

Universal commands available in all workspaces. Use `/command-name` in Cursor chat.

| Command | Purpose | Usage |
|---------|---------|-------|
| **format-doc** | Style normalization (headings, bullets, spacing) | `/format-doc @README.md` |
| **revise-doc** | Lossless distillation for clarity and flow | `/revise-doc @spec.md` |
| **optimize-doc** | Light-touch refinement, preserve claims | `/optimize-doc @doc.md` |
| **refine-readme** | Turn README into best-in-class (value prop, quick start) | `/refine-readme` |
| **list-questions** | Extract open questions from a document | `/list-questions @doc.md` |
| **list-conflicts** | Extract conflicting facts from a document | `/list-conflicts @doc.md` |
| **create-builder-brief** | Generate a Builder Brief from template | `/create-builder-brief` |
| **create-business-guide** | Generate business-facing guide from technical docs | `/create-business-guide` |
| **critique-doc** | Structured critique of a requirements doc | `/critique-doc @prd.md` |
| **local-to-wiki** | Convert Markdown to Confluence storage format | `/local-to-wiki` |
| **wiki-to-local** | Convert Confluence page to clean Markdown | `/wiki-to-local` |

---

## Templates (@-mention .md Files)

| File | Purpose | How to Use |
|------|---------|------------|
| **generic_cursor_user_rule.md** | Cursor User Rules starter | Copy into Cursor Settings → User Rules, then customize |
| **prompt-context-harness.md** | Comparison table: Prompt Engineering vs Context Engineering vs Harness Engineering | `@prompt-context-harness.md` when discussing LLM context strategy or choosing an approach |

---

## Common Workflows

| Need | Use |
|------|-----|
| **Focus check** | `@accountability-checkin` at session start or when drifting |
| **New project** | README template → `/refine-readme` |
| **Requirements** | `requirement-agent` → `critique-requirements` |
| **Doc cleanup** | `/optimize-doc` → `/revise-doc` → `/format-doc` |
| **Code quality** | `debug-audit` → `codefix` before PR |
| **Extract from web** | `extract-sitemap` → `extract-webpage-content` |

---

## Contributing

Found a bug? Have a better agent? Open an issue or PR on [GitHub](https://github.com/mostly-coherent/Helpful-Agents).

**Philosophy:** Fast time to value. Straight to execution, minimal ceremony, clear examples.

---

**Last Updated:** 2026-03-04
**Other Projects:** [github.com/mostly-coherent](https://github.com/mostly-coherent)
