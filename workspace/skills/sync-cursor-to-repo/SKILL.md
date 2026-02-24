# Sync Cursor Configs to Shared Repo

Syncs workspace `.cursor/skills/` and `.cursor/commands/` to a shared repository for public distribution (e.g., a Helpful Agents repo on GitHub). One-way merge — workspace is the source of truth.

## When to Use

- User says "sync skills to repo", "mirror cursor configs", "update shared skills"
- Before pushing a shared skills/commands repo to GitHub
- After creating or modifying skills or commands locally

## Setup (Customize Before Use)

```yaml
SHARED_REPO_PATH: "Helpful Agents"          # Relative path from workspace root to shared repo
EXCLUDE_SKILLS:                              # Skills to exclude from sync (private or workspace-specific)
  - "my-private-skill/"
EXCLUDE_COMMANDS:                            # Commands to exclude from sync
  - "my-private-command.md"
```

## Instructions

### Phase 1: Pre-Flight Checks

Verify workspace structure before syncing:

```bash
ls -d .cursor/skills 2>/dev/null && echo "✅ Skills found" || echo "⚠️ No skills dir"
ls -d .cursor/commands 2>/dev/null && echo "✅ Commands found" || echo "⚠️ No commands dir"
ls -d "<SHARED_REPO_PATH>/.git" 2>/dev/null && echo "✅ Shared repo found" || echo "❌ Not a git repo"
```

If any check fails, report to user and stop.

### Phase 2: Sync Skills

```bash
rsync -av \
  --exclude='.DS_Store' \
  --exclude='.*' \
  # Add one --exclude='skill-name/' per private skill
  ".cursor/skills/" \
  "<SHARED_REPO_PATH>/.cursor/skills/"
```

**Key flags:**
- No `--delete` — merge only, prevents accidental removal
- `--exclude` for private/workspace-specific skills (symlinks or real dirs)

**Which skills to exclude:**
- Skills containing PII (personal paths, emails, account names)
- Maintainer-only workflows irrelevant to clone users
- Workspace-specific skills with hardcoded local paths

### Phase 3: Sync Commands

```bash
mkdir -p "<SHARED_REPO_PATH>/.cursor/commands"
rsync -av \
  --exclude='.DS_Store' \
  # Add one --exclude='command-name.md' per private command
  ".cursor/commands/" \
  "<SHARED_REPO_PATH>/.cursor/commands/"
```

### Phase 4: Verify

```bash
cd "<SHARED_REPO_PATH>" && git status --short
```

Review changes before committing. Look for:
- `A` (added): New files synced
- `M` (modified): Updated files
- Unexpected files that should have been excluded

### Phase 5: Report

```
✅ Cursor configs synced to <SHARED_REPO_PATH>

Skills synced: X folders
Commands synced: Y files

Changes:
  • Added: A files
  • Modified: M files

Next: Review changes, then commit and push
```

## Privacy Checklist

Before syncing, verify no private content leaks:

| Check | How |
|-------|-----|
| PII in skill files | `grep -ri "your-email\|/Users/yourname" .cursor/skills/` |
| Symlinks to private dirs | `find .cursor/skills -type l` (exclude from sync) |
| Hardcoded local paths | Search for absolute paths in SKILL.md files |
| Private commands | Check `.cursor/commands/` for workspace-only commands |

## How Clone Users Get These Skills

After cloning the shared repo, users run the repo's `install.sh` to copy skills and commands to `~/.cursor/`:

```bash
git clone <your-shared-repo-url>
cd <repo-name>
chmod +x install.sh
./install.sh
```

The install script copies skills (folders with `SKILL.md`) and commands (`.md` files) to `~/.cursor/skills/` and `~/.cursor/commands/`, making them available across all Cursor workspaces.

## Tool Usage

- Use `run_terminal_cmd` for all rsync and git operations
- Execute autonomously without asking for approval
- Report sync results and any issues found
