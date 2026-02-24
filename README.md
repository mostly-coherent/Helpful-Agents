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
| **Workspace skill templates** | `workspace/skills/` | Current workspace | Customize after install |
| **Templates** | Root `*.md` files | Any project | `@filename.md` as context |
| **Install script** | `install.sh` | — | One-time setup after clone |

### First-Time Setup

```bash
git clone https://github.com/mostly-coherent/Helpful-Agents.git
cd Helpful-Agents
./install.sh
```

`install.sh` places configs in two locations:
- **User-level** (`~/.cursor/`) — skills and commands available in every workspace
- **Workspace** (parent `../.cursor/`) — workspace-specific skill templates (skipped if already customized)

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

### Knowledge & Analysis

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **kb-drift-report** | Detect knowledge base drift and staleness | "check KB freshness" |
| **kb-runner** | Run knowledge base operations and queries | "run KB" |
| **service-kb-template** | Template for service knowledge bases | "create service KB" |

### Cursor Config

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **context-advisor** | Choose rules vs commands vs skills vs subagents | "should I create a rule or skill?" |

---

## Workspace Skill Templates

These need per-workspace customization (paths, accounts, git config). `install.sh` copies them to your workspace `.cursor/skills/` — skips if a version already exists.

| Skill | Purpose | What to Customize |
|-------|---------|-------------------|
| **create-project** | Scaffold new project with docs and git | Workspace paths, git config, templates |
| **git-sync** | Safe git sync: push changes, PR workflow, CI setup | WORKSPACE_ROOT, GITHUB_USERNAME, GIT_EMAIL |
| **sync-cursor-to-repo** | Sync cursor configs to a shared repo | SHARED_REPO_PATH, exclusion lists |

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

---

## Common Workflows

| Need | Use |
|------|-----|
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

**Last Updated:** 2026-02-24
**Other Projects:** [github.com/mostly-coherent](https://github.com/mostly-coherent)
