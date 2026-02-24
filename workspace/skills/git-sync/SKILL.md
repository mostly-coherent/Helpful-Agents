# GitSync — Push Local Changes to GitHub

Autonomous git sync workflow for Cursor. Pushes uncommitted changes across all project folders in a multi-repo workspace to GitHub with safety checks (account verification, remote validation, PII scanning).

## When to Use

- User says "sync to GitHub", "push my changes", "git sync", or "@git-sync"
- User says "sync [folder name]" for single-folder sync
- User says "set up CI for [project]" for GitHub Actions setup
- User says "create PR for [changes]" for PR workflow
- After completing work that should be pushed to GitHub

## Setup (Customize Before Use)

**Before using this skill, configure these values for your environment:**

```yaml
# Edit these to match your setup
WORKSPACE_ROOT: "/path/to/your/workspace"        # Absolute path to workspace root
GITHUB_USERNAME: "your-github-username"           # Your GitHub username
GIT_EMAIL: "your-email@example.com"               # Git commit email
GIT_NAME: "Your Name"                             # Git commit author name
GH_CLI_USER: "your-github-username"               # gh CLI account name
PRIVATE_FOLDER_PREFIX: "Private"                  # Prefix for private repo folders (skip PII scan)
EXCLUDED_FOLDERS: ["Production_Clones/"]          # Folders to never push from
FORBIDDEN_REMOTES: ["other-org"]                  # Remote patterns that should block pushes
```

## Quick Decision Tree

| User Intent | Workflow | Section |
|-------------|----------|---------|
| "Sync to GitHub" / "@git-sync" | Batch sync all folders | Batch Sync |
| "Sync [folder name]" | Single folder sync | Quick Sync |
| "Set up CI for [project]" | Add GitHub Actions | See [CI_SETUP.md](references/CI_SETUP.md) |
| "Create PR for [changes]" | PR workflow | See [PR_WORKFLOW.md](references/PR_WORKFLOW.md) |

**Default:** Batch sync all folders with uncommitted changes.

## Critical Safety Rules

| Rule | Action |
|------|--------|
| Remote contains a forbidden pattern | **STOP IMMEDIATELY** — fix remote |
| Folder is in excluded list | **Skip** — never push |
| PUBLIC repo with PII in diff | **Abort** — report findings, wait for fix |
| Any push operation | Verify remote shows your GitHub username first |
| Force push | **NEVER** — always use `git push` (not `-f`) |

## Pre-Flight (REQUIRED)

Run before any git operation:

```bash
gh auth switch --user <GH_CLI_USER>
```

**If workflow scope needed** (repos with `.github/workflows/*` changes): Check `gh auth status` for `workflow` scope. If missing, see [ERROR_HANDLING.md](references/ERROR_HANDLING.md).

## Batch Sync (Default)

**When:** User says "sync all", "batch sync", or invokes without specifying a folder.

**Steps:**
1. Switch gh CLI account (pre-flight)
2. Scan for folders with uncommitted changes (skip excluded folders)
3. Verify remotes for each folder
4. Run PII scan for PUBLIC repos (skip private-prefix folders)
5. Stage → Commit → Push to main
6. Report summary

**Command:**

```bash
gh auth switch --user <GH_CLI_USER> && \
cd "<WORKSPACE_ROOT>" && \
for dir in */; do
  if [ -d "$dir/.git" ]; then
    # Skip excluded folders
    SKIP=false
    for excluded in <EXCLUDED_FOLDERS>; do
      if [ "$dir" = "$excluded" ]; then SKIP=true; fi
    done
    if [ "$SKIP" = "false" ]; then
      cd "$dir"
      if [ -n "$(git status --porcelain)" ]; then
        echo "📁 Syncing $dir..."
        REMOTE=$(git remote -v | grep origin | grep <GITHUB_USERNAME> | head -1)
        if [ -z "$REMOTE" ]; then
          echo "❌ $dir - Wrong remote or missing, skipping"
        else
          git add -A
          git commit -m "chore: sync local changes"
          git push origin main && echo "✅ $dir synced" || echo "❌ $dir failed"
        fi
      fi
      cd "<WORKSPACE_ROOT>"
    fi
  fi
done
```

**Report Template:**

```
📊 Batch Sync Complete

Synced (✅):
- <folder1> - <commit SHA>
- <folder2> - <commit SHA>

Skipped (no changes):
- <folder3>

Failed (❌):
- <folder5> - <error reason>

Total: X synced, Y skipped, Z failed
```

## Quick Sync (Single Folder)

**When:** User specifies a single folder to sync.

**Steps:**
1. Extract folder name from user message
2. If NOT a private-prefix folder, run PII scan
3. Verify remote, stage, commit, push
4. Report with commit SHA

**Command:**

```bash
gh auth switch --user <GH_CLI_USER> && \
cd "<WORKSPACE_ROOT>/<FOLDER_NAME>" && \
git remote -v && \
git add -A && \
git commit -m "chore: sync" && \
git push origin main
```

**Report:**

```
✅ <FOLDER_NAME> synced to GitHub
- Commit: <SHA>
- Remote: <GITHUB_USERNAME>/<FOLDER_NAME>
- Branch: main
```

## PII Scan (PUBLIC Repos Only)

**Decision:**
- Private-prefix folder → Skip scan (PRIVATE repo, personal info allowed)
- All other folders → Run scan before push

**Command:**

```bash
cd "<WORKSPACE_ROOT>/<FOLDER_NAME>" && \
git add -A && \
echo "🔍 Scanning for PII..." && \
PII_MATCHES=$(git diff --cached | grep -iE "<YOUR_PII_PATTERNS>") && \
if [ -n "$PII_MATCHES" ]; then
  echo "❌ PII FOUND - DO NOT PUSH"
  echo "$PII_MATCHES"
  exit 1
else
  echo "✅ No PII detected - Safe to push"
  exit 0
fi
```

**Customize `<YOUR_PII_PATTERNS>`** with pipe-separated patterns to detect:
- Your real name, username, email addresses
- Workspace paths (e.g., `/Users/yourname/...`)
- Organization names you want to keep private
- Internal project references

**If PII found:** Stop, report matches, suggest generic replacements, wait for user fix.

**Safe alternatives:**
- `/path/to/project` instead of real workspace paths
- `user@example.com` instead of real emails
- `your-github-username` instead of real username

## Private Repos — Special Handling

Private-prefix folders (e.g., `Private*/`) are PRIVATE repos used for cloud backup.

**Rules:**
- Sync like any other folder
- Skip PII scan (PRIVATE visibility, personal info allowed)
- **NEVER** change visibility to public

## Verification After Sync

```bash
cd "<WORKSPACE_ROOT>"
for dir in */; do
  if [ -d "$dir/.git" ]; then
    cd "$dir"
    STATUS=$(git status --porcelain)
    if [ -z "$STATUS" ]; then
      echo "✅ $dir - clean"
    else
      echo "⚠️  $dir - has changes"
    fi
    cd ..
  fi
done
```

## Auth Setup

**Required:**
- Git config: `<GIT_EMAIL>` in all repos
- GitHub CLI: `<GH_CLI_USER>` account
- Remote: SSH (`git@github.com:<GITHUB_USERNAME>/<repo>.git`) or HTTPS (`https://github.com/<GITHUB_USERNAME>/<repo>.git`)

**Verify:**

```bash
gh auth status
git config user.email
git remote -v
```

**Fix if wrong:**

```bash
git config user.email "<GIT_EMAIL>"
git config user.name "<GIT_NAME>"
git remote set-url origin https://github.com/<GITHUB_USERNAME>/<repo>.git
```

## Tool Usage

- Use `run_terminal_cmd` for ALL git operations (autonomous execution)
- Execute commands without asking for approval
- Batch independent commands in parallel
- Include full absolute paths
- Capture and report output (commit SHAs, error messages)

## Additional References

- [ERROR_HANDLING.md](references/ERROR_HANDLING.md) — Error resolution, troubleshooting, workflow scope fixes
- [CI_SETUP.md](references/CI_SETUP.md) — GitHub Actions CI/CD setup
- [PR_WORKFLOW.md](references/PR_WORKFLOW.md) — Alternative PR workflow for major features

---

**Version:** 3.0 (Skill format — public, PII-free)
**Last Updated:** 2026-02-12
**Customization:** Replace all `<PLACEHOLDER>` values with your own before use
