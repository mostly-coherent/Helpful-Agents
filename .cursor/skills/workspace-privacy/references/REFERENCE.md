# Workspace Privacy Optimization

> **Prompt for Cursor AI to prepare your Adobe workspace for GitHub sharing while protecting private content**

---

## Why This Matters

When you push code to GitHub, **everything in your repository becomes visible** (unless it's a private repo—but even then, collaborators see it all). Common mistakes:

- Personal file paths like `/Users/yourname/Projects/...` reveal your username
- Hardcoded personal emails and GitHub accounts in config files
- API keys, tokens, or secrets accidentally committed
- Personal notes mixed with shareable code

This prompt helps you **audit and fix** these issues before sharing to `github.com/<your_adobe_user>`.

---

## Prerequisites

**Adobe Convention:** Use `MyPrivate*/` pattern for private folders:

| Pattern | Example | Adobe Standard |
|---------|---------|----------------|
| `MyPrivate*/` | `MyPrivateNotes/`, `MyPrivatePrompts/`, `MyPrivateConfig/` | ✅ Adobe workspace standard |

This convention is used across Adobe workspaces for consistency.

---

## The Prompt

Copy and paste this into Cursor AI:

```
Optimize this workspace for sharing while protecting private content.

## My Organization Pattern
- Any folder named `MyPrivate*` (e.g., MyPrivatePrompts/, MyPrivateNotes/) is PRIVATE
- Everything else should be shareable (no personal paths, accounts, emails, secrets)

## Tasks

### 1. Update .gitignore Files
Find all .gitignore files in this workspace and ensure they include:

# Private folders (Adobe convention)
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

Remove any old specific file/folder entries that are now covered by these patterns.

### 2. Audit for Personal Information
Search ALL non-private files for personal information:

**File Paths (platform-specific):**
- macOS: `/Users/<username>/...`
- Windows: `C:\Users\<username>\...` or `C:/Users/<username>/...`
- Linux: `/home/<username>/...`

**Accounts & Identity:**
- Personal GitHub accounts (e.g., github.com/yourpersonaluser)
- Personal email addresses (e.g., yourpersonal@gmail.com)
- Personal names in maintainer/author/owner fields
- Personal Vercel/Netlify/Heroku account URLs

**Adobe-Specific:**
- Personal Adobe email (e.g., yourname@adobe.com) should be replaced with generic references
- Adobe GitHub username (e.g., github.com/yourname_adobe) should use placeholders in templates
- Vercel team names (e.g., vercel.com/your-team) should use placeholders

**Secrets & Credentials:**
- API keys (patterns like `sk-`, `pk_`, `api_`, `key_`)
- Tokens (patterns like `token_`, `ghp_`, `gho_`)
- Passwords or connection strings
- Private URLs with auth parameters

Report what you find. For each file with personal info:
- If it's a template → replace with generic placeholders (e.g., `<YOUR_ADOBE_USER>`, `<YOUR_EMAIL>`)
- If it's config → suggest what to move to MyPrivate* folder or .env
- If it's a secret → REMOVE immediately and add pattern to .gitignore

### 3. Fix Stale References
Search for any references to files that are now in MyPrivate* folders.
Update those references to point to the correct location.

### 4. Verify Workspace Config Files
Check these files for consistency:
- .cursorrules (if exists)
- CLAUDE.md (if exists)
- README.md
- package.json (author/repository fields)
- Any *.md files at workspace root

Ensure:
- References to private files point to MyPrivate* folder locations
- No personal paths/accounts/emails in shareable files
- .gitignore pattern is documented where relevant
- package.json uses generic or placeholder values for personal fields

## Output
1. Summary table of all changes made
2. List of any files that need manual review
3. List of any secrets found (for immediate action)
4. Confirmation that MyPrivate*/ pattern is enforced everywhere
```

---

## Quick Verification Commands

After optimization, verify with these commands:

### Check for Personal Paths

```bash
# macOS/Linux - check for personal paths
grep -rn "/Users/" . --include="*.md" --include="*.json" --include="*.ts" --include="*.js" | grep -v "node_modules" | grep -v "MyPrivate"

# Windows equivalent (PowerShell)
Get-ChildItem -Recurse -Include *.md,*.json,*.ts,*.js | Select-String "C:\\Users\\" | Where-Object { $_.Path -notmatch "node_modules|MyPrivate" }
```

### Check .gitignore Configuration

```bash
# Verify MyPrivate pattern exists
grep "MyPrivate" .gitignore

# List what's being ignored
git status --ignored

# Check if any secrets are tracked
git ls-files | xargs grep -l "sk-\|pk_\|api_key\|API_KEY" 2>/dev/null
```

### Check for Secrets in History

```bash
# If you've already committed secrets, they're in git history!
# Use git-secrets or trufflehog to scan:
brew install git-secrets  # macOS
git secrets --scan-history
```

---

## Checklist

Use this checklist to confirm optimization is complete:

- [ ] All `.gitignore` files have `MyPrivate*/` pattern
- [ ] `.gitignore` includes `.env*` patterns for environment files
- [ ] No personal file paths in shareable files (checked all platforms)
- [ ] No personal GitHub accounts hardcoded in shareable files
- [ ] No personal emails in shareable files
- [ ] No API keys, tokens, or secrets in shareable files
- [ ] All references to private files point to MyPrivate* folder locations
- [ ] `package.json` has generic author/repository (if applicable)
- [ ] `.cursorrules` and `CLAUDE.md` updated (if they exist)
- [ ] Ran `git status --ignored` to confirm MyPrivate* folders are ignored

---

## Common Patterns to Replace

| Personal Pattern | Generic Replacement (Adobe) |
|-----------------|---------------------|
| `/Users/yourname/Projects/` | Use relative paths `./` or reference via `git config` |
| `github.com/yourname_adobe` | `github.com/<YOUR_ADOBE_USER>` or `$(git remote -v)` |
| `yourname@adobe.com` | `$(git config user.email)` or `<YOUR_EMAIL>` |
| `vercel.com/your-team` | `vercel.com/<YOUR_TEAM>` |
| `sk-abc123...` | Use `.env` file: `process.env.OPENAI_API_KEY` |

---

## Best Practices for Ongoing Privacy

### 1. Use Environment Variables for Secrets

```bash
# Create .env file (already gitignored)
echo "OPENAI_API_KEY=sk-your-key-here" >> .env

# Create .env.example for sharing (no real values)
echo "OPENAI_API_KEY=sk-your-key-here" >> .env.example
```

### 2. Use Dynamic References in Config Files

Instead of hardcoding personal info in `CLAUDE.md` or `.cursorrules`:

```markdown
# Bad
Git remote: github.com/yourname_adobe/my-project

# Good
Git remote: Check with `git remote -v`
Author email: Check with `git config user.email`
```

### 3. Pre-commit Hooks (Advanced)

Prevent accidental commits of secrets:

```bash
# Install git-secrets (macOS)
brew install git-secrets
cd your-repo
git secrets --install
git secrets --register-aws  # Blocks AWS keys
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "I already committed a secret!" | Rotate the secret immediately. Use `git filter-branch` or BFG Repo-Cleaner to remove from history. |
| "MyPrivate folder still showing in git status" | Check `.gitignore` is at repo root. Pattern must match exactly. Try `git rm -r --cached MyPrivate/` then commit. |
| "Cursor AI missing files in search" | Some files may be in `.cursorignore`. Check that file exists and adjust patterns. |
| ".env file is being tracked" | Run `git rm --cached .env` then commit. It was added before .gitignore rule. |

---

**Purpose:** Workspace privacy optimization for Adobe GitHub sharing  
**Audience:** Adobe PMs, UX designers, and developers  
**Convention:** `MyPrivate*/` for private folders  
**Last Updated:** 2025-12-21
