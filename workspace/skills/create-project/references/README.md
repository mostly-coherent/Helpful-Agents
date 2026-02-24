# Create Project — Reference

## Customization for End Users

| Variable | Purpose |
|----------|---------|
| `GITHUB_USER` | GitHub username for repo creation. Set before running if not using `--skip-github`. |

## Options Summary

- `--basic` — Web app structure only (no AI/LLM patterns)
- `--scaffold` — Full Next.js AI app (Vercel AI SDK, Prisma, Langfuse, Playwright)
- `--skip-github` — Omit GitHub repo creation (recommended for agent runs)

## What Gets Created

**All modes:** README.md, CLAUDE.md, PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md, .env.example, .gitignore, git init

**--scaffold:** package.json, Next.js app structure, /api/chat, /api/feedback, Prisma schema, Playwright E2E setup
