---
name: create-project
description: Scaffolds a new Next.js project with documentation, git, optional AI/LLM structure. Use when user says "create a new project", "scaffold project", "new app", "create project called X", or wants to start a new web app with proper structure.
---

# Create Project

Creates a new project folder with canonical documentation (README, CLAUDE.md, PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md), .env.example, .gitignore, and optional Next.js AI scaffolding. Agent runs the script—user never touches terminal.

## When to Use

- User says "create a new project", "scaffold a project", "new app called [name]"
- User wants to start a web app with proper structure and docs
- User asks for a Next.js project with AI/chat features

## Invocation

**User says:** "Create a new project called my-chat-app" or "Scaffold project feedback-widget"

**Agent actions:**
1. Confirm project name with user if ambiguous
2. Run the script from workspace root: `./scripts/create-project.sh <project-name> [options]`
3. Report success and next steps

## Script Location & Execution

The script is at `scripts/create-project.sh` inside this skill. Agent must:

1. **Change to user's workspace root** (where the new project folder should appear)
2. **Run the script** with full path. Examples:
   - User-level skill: `bash ~/.cursor/skills/create-project/scripts/create-project.sh my-app --skip-github`
   - Workspace skill: `bash .cursor/skills/create-project/scripts/create-project.sh my-app --skip-github`
3. **Use --skip-github** when running non-interactively (no prompts)

## Options

| Option | Effect |
|--------|--------|
| (none) | AI-ready project: docs + .env.example + Next.js hints |
| `--basic` | Basic web app (no AI/LLM scaffolding) |
| `--scaffold` | Full Next.js AI app: Vercel AI SDK, Prisma, Langfuse, Playwright |
| `--skip-github` | Skip GitHub repo creation (use for non-interactive/agent runs) |

## Non-Interactive (Agent) Usage

When the agent runs this script, use `--skip-github` by default so no prompts block execution. User can create the GitHub repo later manually.

Example:
```bash
./scripts/create-project.sh my-app --skip-github
```

For full scaffold:
```bash
./scripts/create-project.sh my-app --scaffold --skip-github
```

## Customization (End Users)

Users can set before running:
- `GITHUB_USER` — GitHub username for repo creation (when not using --skip-github)
- Script runs from current directory; project is created as subfolder

## Output

Creates:
- `<project-name>/` with README, CLAUDE.md, PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md
- `.env.example`, `.gitignore`, `git init`
- With `--scaffold`: Full Next.js app with chat API, Prisma, Playwright E2E

## Next Steps (Report to User)

After creation:
1. `cd <project-name>`
2. With scaffold: `npm install` → `cp .env.example .env.local` → `npm run dev`
3. Without scaffold: Run `npx create-next-app@latest .` then add dependencies
4. `git add .` → `git commit` → `git push` (after creating repo if --skip-github was used)
