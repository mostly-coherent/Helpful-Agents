# Helpful Agents

> Reusable AI agents, skills, and commands for Cursor—development, documentation, and project scaffolding.

![Type](https://img.shields.io/badge/Type-AI%20Agents-purple)
![Status](https://img.shields.io/badge/Status-Active-green)
![Stack](https://img.shields.io/badge/Stack-Cursor%20%7C%20Claude-blue)

## What's in This Folder

| Type | Location | How to Use |
|------|----------|------------|
| **Skills** | `.cursor/skills/` | Auto-invoke when relevant, or mention by name (e.g. "run debug-audit on this project") |
| **Commands** | `.cursor/commands/` | Use `/command-name` in Cursor chat |
| **Templates** | Root `*.md` files | `@filename.md` to load as context, or copy-paste |
| **Install script** | `install.sh` | One-time: copies skills + commands to `~/.cursor/` for all projects |

### First-Time Setup

```bash
git clone https://github.com/mostly-coherent/Helpful-Agents.git
cd Helpful-Agents
./install.sh
```

This copies `.cursor/skills/` and `.cursor/commands/` into `~/.cursor/`, making them available in every Cursor workspace.

---

## Skills

Skills are domain-specific workflows. Cursor invokes them when your message matches their trigger terms, or you can request them explicitly.

### Code & Development

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **debug-audit** | Full project audit: bugs, performance, accessibility | "audit this project", "find bugs", "check accessibility" |
| **codefix** | Code review for bugs, race conditions, error handling, UAT readiness | "review this code", "check for bugs", "prep for UAT" |
| **rearchitecture** | Document component boundaries and architecture patterns | "document architecture", "update ARCHITECTURE.md" |
| **create-project** | Scaffold new Next.js project with docs and git | "create a new project", "scaffold project called X" |
| **app-password-auth** | Add password-gated auth with idle timeout to Next.js apps | "add password protection", "auth gating" |
| **generate-server-scripts** | Generate start/stop/check scripts for multi-service projects | "generate server scripts", "start stop scripts" |

### Documentation

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **cleanup-docs** | Harmonize scattered .md files to canonical 6-file structure | "cleanup docs", "harmonize documentation" |
| **upgrade-canonical-docs** | Standardize doc names and formats to latest templates | "upgrade canonical docs", "standardize doc format" |
| **business-guide** | Translate technical content to business-friendly language | "translate for stakeholders", "explain in non-technical terms" |
| **requirement-agent** | Create or update PRDs and Builder Briefs | "create PRD", "Builder Brief", "requirements document" |
| **critique-requirements** | Structured feedback on requirements docs | "critique requirements", "review PRD" |

### Web Extraction

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **extract-webpage-content** | Extract all content from internal pages (text, images, accordions) | "extract webpage", "archive internal docs" |
| **extract-sitemap** | Map links from a page, check accessibility, generate sitemap | "preview extraction", "discover site structure" |
| **extract-page-shallow** | Extract one page + direct links only (no deep crawl) | "shallow extraction", "one page and its links" |
| **extract-design-system** | Extract colors, typography, spacing from a site | "extract design", "copy styling", "design tokens" |

### Infrastructure & Workflow

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **git-sync** | Safe git sync: push changes, PR workflow, CI setup | "sync to GitHub", "push my changes", "create PR" |
| **workspace-privacy** | Sanitize workspace for sharing (remove PII) | "prep for sharing", "workspace privacy" |
| **dev-environment-setup** | One-time setup: Node, Git, Python, MCP, Vercel, Supabase, Docker | "set up dev environment", "bootstrap my laptop" |

### Cursor Config

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **context-advisor** | Choose rules vs commands vs skills vs subagents | "should I create a rule or skill?", "best way to provide context" |

---

## Commands

Commands are single-purpose actions invoked with `/command-name`. Add context after: `/command-name @filename.md` or describe what to act on.

### Documentation Commands

| Command | Purpose | Usage |
|---------|---------|-------|
| **format-doc** | Style normalization only (headings, bullets, spacing). No content edits. | `/format-doc` or `/format-doc @README.md` |
| **revise-doc** | Lossless distillation for clarity, resequence for flow | `/revise-doc` or `/revise-doc @spec.md` |
| **optimize-doc** | Light-touch refinement, minimal edits, preserve claims | `/optimize-doc` or `/optimize-doc @doc.md` |
| **refine-readme** | Turn default README into best-in-class (value prop, quick start, <60 sec to run) | `/refine-readme` on project README |
| **list-questions** | Extract open questions from a document | `/list-questions` or `/list-questions @doc.md` |
| **list-conflicts** | Extract conflicting facts from a document | `/list-conflicts` or `/list-conflicts @doc.md` |

---

## Templates (@-mention .md Files)

Templates live in the repo root. Use `@filename.md` in Cursor chat to load them as context, or copy-paste into your project.

| File | Purpose | How to Use |
|------|---------|------------|
| **Builder_Template.md** | Lightweight prototype-driven brief (vision, goals, problem, scope) | `@Builder_Template.md` when creating a Builder Brief |
| **PRD_Template.md** | Comprehensive PRD structure (scope, use cases, requirements) | `@PRD_Template.md` when drafting a full PRD |
| **README-project-template.md** | Generic project README structure (quick start, stack, features) | `@README-project-template.md` when creating a new project README |
| **generic_cursor_user_rule.md** | Cursor User Rules starter (traceability, docs discipline, git workflow) | Copy into Cursor Settings → User Rules, then customize |

---

## Common Workflows

| Need | Use |
|------|-----|
| **New project** | README template → `/refine-readme` |
| **Requirements** | `requirement-agent` create Builder Brief → `critique-requirements` review |
| **Doc cleanup** | `/optimize-doc` → `/revise-doc` → `/format-doc` |
| **Code quality** | `debug-audit` on project → `codefix` before PR |
| **Doc harmonization** | `cleanup-docs` on project folder |
| **Extract from web** | `extract-sitemap` first → `extract-webpage-content` |

---

## Contributing

Found a bug? Have a better agent? Open an issue or PR on [GitHub](https://github.com/mostly-coherent/Helpful-Agents).

**Philosophy:** Fast time to value. Straight to execution, minimal ceremony, clear examples.

---

**Last Updated:** 2025-02-14  
**Other Projects:** [github.com/mostly-coherent](https://github.com/mostly-coherent)
