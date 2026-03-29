# Update Upstream Fork

Pulls latest changes from an upstream repository into a local fork or clone. Useful for keeping read-only reference copies or forked repos up to date.

## When to Use

- User says "update fork", "pull upstream", "sync from upstream"
- User wants to update a cloned repo with the latest upstream changes
- Keeping a local reference copy in sync with the original repository

## Instructions

### 1. Identify the Target Repo

Ask the user (or infer from context) which repo to update:

```bash
cd "<path-to-forked-or-cloned-repo>"
git remote -v
```

Verify:
- `origin` = user's fork (or the clone source)
- `upstream` = original repo (if configured)

### 2. Add Upstream Remote (if missing)

If `upstream` isn't configured:

```bash
git remote add upstream <original-repo-url>
git fetch upstream
```

### 3. Pull Latest from Upstream

```bash
git switch main
git pull upstream main
```

If there are local uncommitted changes:

```bash
git stash
git pull upstream main
git stash pop
```

### 4. Report Status

```bash
git log --oneline -5
```

Report:
- Whether new commits were pulled (or "Already up to date")
- Recent commit history
- Any merge conflicts (if applicable)

## Read-Only Clones

For repos cloned purely for reference (not for contributing):

- Pull from upstream only — never push
- Don't modify files (read-only reference)
- If the clone has no `upstream` remote but `origin` points to the source, pull from `origin`:

```bash
git switch main
git pull origin main
```

## Handling Conflicts

If `git pull` reports merge conflicts:

1. Report the conflicted files to the user
2. For read-only clones: suggest `git reset --hard upstream/main` (discards local changes)
3. For active forks: help resolve conflicts file by file

## Tool Usage

- Use `run_terminal_cmd` for all git operations
- Execute autonomously
- Report pull results and recent commits to user
