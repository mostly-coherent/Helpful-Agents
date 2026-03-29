# Workspace Privacy Optimization

> **Prepare a workspace for GitHub sharing while protecting private content** — org-agnostic; works for personal repos (`mostly-coherent`), solo builders, or any team.

---

## Why This Matters

When you push code to GitHub, **everything in the repository can become visible** (public repos are world-readable; private repos still expose content to collaborators). Common mistakes:

- Absolute paths like `/Users/you/...` leak usernames
- Hardcoded emails, org URLs, or alternate GitHub identities in templates
- API keys or tokens committed by accident
- Private notes mixed with shareable code

Use this flow to **audit and fix** before sharing — target remote should match what you intend (e.g. `github.com/<your-org>/<repo>`).

---

## Prerequisites

**Private folder pattern:** Folders named `MyPrivate*` (e.g. `MyPrivatePrompts/`) are **private by convention** in this lab — keep them out of public repos or ensure they are gitignored.

| Pattern | Example |
|---------|---------|
| `MyPrivate*/` | `MyPrivateNotes/`, `MyPrivatePrompts/`, `MyPrivateTools/` |

Adjust the pattern in `.gitignore` to match how *you* separate private vs shareable material.

---

## The Prompt

Copy and paste into your AI tool:

```
Optimize this workspace for sharing while protecting private content.

## My Organization Pattern
- Any folder named `MyPrivate*` is PRIVATE
- Everything else should be shareable (no personal paths, secrets, or wrong-account GitHub URLs in templates)

## Tasks

### 1. Update .gitignore Files
Ensure they include:

# Private folders
MyPrivate*/

# Environment files with secrets
.env
.env.local
.env.*.local
*.env

# OS and IDE files
.DS_Store
Thumbs.db
.idea/
.vscode/settings.json

### 2. Audit for Personal Information
Search non-private files for:

**File paths:** `/Users/...`, `C:\Users\...`, `/home/...`

**Accounts & identity:** personal GitHub users, personal emails, deploy URLs tied to the wrong account

**Cross-environment leakage:** paths or git remotes from a *different machine* (e.g. work laptop) that should not appear in this repo

**Secrets:** API keys, tokens, passwords, connection strings with credentials

Report findings. Replace templates with placeholders (`<YOUR_EMAIL>`, `git remote -v`). Move sensitive config to `.env` or `MyPrivate*`.

### 3. Fix stale references
Update pointers if files moved under `MyPrivate*`.

### 4. Verify workspace config
Check `.cursorrules`, `CLAUDE.md`, `README.md`, `package.json` for consistency.

## Output
1. Summary of changes
2. Files needing manual review
3. Secrets found (if any)
4. Confirmation that private patterns are enforced
```

---

## Quick Verification Commands

```bash
grep -rn "/Users/" . --include="*.md" --include="*.json" --include="*.ts" --include="*.js" | grep -v "node_modules" | grep -v "MyPrivate"
```

```bash
grep "MyPrivate" .gitignore
git status --ignored
```

---

## Checklist

- [ ] `.gitignore` covers `MyPrivate*/` and `.env*` as needed
- [ ] No personal absolute paths in shareable files
- [ ] No wrong-account GitHub org or host in docs meant for this repo
- [ ] No secrets in tracked files
- [ ] `package.json` / README author fields appropriate for visibility

---

## Common Patterns to Replace

| Avoid | Prefer |
|-------|--------|
| Hardcoded `/Users/you/...` | Relative paths or `$(pwd)` / project-root references |
| Wrong `github.com/<org>/...` in templates | Placeholder or `git remote -v` |
| Real emails in examples | `<YOUR_EMAIL>` or `git config user.email` |
| Raw API keys | `process.env.*` + `.env.example` |

---

**Purpose:** Workspace privacy before GitHub (personal or team)  
**Convention:** `MyPrivate*/` for material that must not ship publicly  
**Last Updated:** 2026-03-29
