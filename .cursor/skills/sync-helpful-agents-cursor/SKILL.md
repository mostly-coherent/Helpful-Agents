---
name: sync-helpful-agents-cursor
description: Syncs workspace .cursor/skills and .cursor/commands to Helpful Agents repo for public sharing on GitHub. Use when you need to mirror cursor configs, sync skills to Helpful Agents, update public configs, or when user mentions "sync skills", "mirror commands", or "update Helpful Agents cursor configs".
---
# Sync Helpful Agents Cursor Configs

Syncs user-level `~/.cursor/skills/` and workspace `.cursor/skills/` + `.cursor/commands/` to `Helpful Agents/.cursor/` for public sharing on GitHub. Universal skills live at user-level; workspace contributes sync-helpful-agents-cursor and public-only skills.

## When to Use

Use this skill when:

- User wants to sync cursor configs to Helpful Agents
- User mentions "mirror skills", "sync commands", "update Helpful Agents"
- User says "sync cursor configs" or "mirror .cursor folder"
- Before pushing Helpful Agents to GitHub (to ensure latest configs)
- After creating/modifying skills or commands (to publish changes)

## Context

**Purpose:** Keep public Helpful Agents repo synchronized with actual cursor configurations

**Direction:** One-way sync: `~/.cursor/skills/` + workspace `.cursor/` → `Helpful Agents/.cursor/`

**What gets synced:**

- **Phase 2a:** User-level `~/.cursor/skills/` (universal skills)
- **Phase 2b:** Workspace `.cursor/skills/` (sync-helpful-agents-cursor; excludes private skills)
- **Phase 3:** Workspace `.cursor/commands/` (command markdown files)

**What gets excluded:**

- `.DS_Store` files (macOS metadata)
- `git-sync/` (contains PII; symlink to MyPrivatePrompts; public template maintained in Helpful Agents)
- `update-lenny/` (private skill; symlink to MyPrivatePrompts)
- `update-lenny.md` from commands (converted to skill; private)

## Execution Flow

### Phase 1: Pre-Flight Checks

**Verify workspace structure:**

1. Check workspace root exists:

   ```bash
   pwd  # Should be your workspace root
   ```
2. Verify source directories exist:

   ```bash
   ls -d .cursor/skills 2>/dev/null && echo "✅ Skills found" || echo "⚠️ No skills"
   ls -d .cursor/commands 2>/dev/null && echo "✅ Commands found" || echo "⚠️ No commands"
   ```
3. Verify Helpful Agents exists and is a git repo:

   ```bash
   ls -d "Helpful Agents/.git" 2>/dev/null && echo "✅ Helpful Agents repo found" || echo "❌ Not a git repo"
   ```

**If any check fails:**

- Report to user which component is missing
- Provide guidance on resolving the issue
- Do not proceed with sync

### Phase 2a: Sync User-Level Skills

**Command:**

```bash
rsync -av --exclude='.DS_Store' --exclude='.*' \
  ~/.cursor/skills/ \
  "Helpful Agents/.cursor/skills/"
```

**What this does:**

- Copies universal skills from `~/.cursor/skills/` to Helpful Agents
- No `--delete` — merge only; prevents accidental removal
- Skips hidden files/dirs

### Phase 2b: Sync Workspace Skills

**Command:**

```bash
rsync -av --exclude='.DS_Store' --exclude='git-sync' --exclude='git-sync/' --exclude='update-lenny' --exclude='update-lenny/' \
  ".cursor/skills/" \
  "Helpful Agents/.cursor/skills/"
```

**What this does:**

- Copies workspace public skills (e.g. sync-helpful-agents-cursor)
- Excludes git-sync and update-lenny (private; symlinks to MyPrivatePrompts)
- No `--delete` — merge only

### Phase 3: Sync Commands

**Commands:**

```bash
mkdir -p "Helpful Agents/.cursor/commands"
test -d .cursor/commands && rsync -av --exclude='.DS_Store' --exclude='update-lenny.md' \
  ".cursor/commands/" \
  "Helpful Agents/.cursor/commands/" || true
```

**What this does:**

- Ensures Helpful Agents has .cursor/commands/
- Copies command markdown files from workspace (if dir exists)
- Excludes update-lenny.md (converted to private skill)
- No `--delete` — merge only

### Phase 4: Verify Sync

**Check what changed:**

```bash
cd "Helpful Agents"
git status --short
```

**Interpret results:**

- `A` (added): New files synced
- `M` (modified): Existing files updated
- `D` (deleted): Files removed from Helpful Agents (cleaned up)
- No output: Already in sync (no changes)

### Phase 5: Report Summary

**Generate report:**

Count changes by type:

- New files added
- Files modified
- Files deleted
- Total files synced

**Report format:**

```
✅ Cursor configs synced to Helpful Agents

Skills synced: X files
Commands synced: Y files

Changes detected:
  • Added: A files
  • Modified: M files  
  • Deleted: D files

Status: Ready for git commit in Helpful Agents/
Next: Run @git-sync to push changes to GitHub
```

## Output Examples

### Success: Changes Synced

```
✅ Cursor configs synced to Helpful Agents

Syncing skills...
✅ Skills synced: 8 skill folders
  • codefix/
  • context-advisor/
  • debug-audit/
  • extract-sitemap/
  • extract-webpage-content/
  • git-sync/
  • production-clone/
  • sync-helpful-agents-cursor/
  • sync-production-data/

Syncing commands...
✅ Commands synced: 0 files (directory empty)

Git status in Helpful Agents:
 M .cursor/skills/sync-helpful-agents-cursor/SKILL.md (new)

Next steps:
1. Review changes: cd "Helpful Agents" && git diff
2. Commit and push: @git-sync Helpful_Agents
```

### Success: Already in Sync

```
✅ Cursor configs synced to Helpful Agents

Syncing skills...
✅ Skills synced: 8 skill folders (no changes)

Syncing commands...
✅ Commands synced: 0 files (no changes)

Git status in Helpful Agents:
  (working tree clean)

Status: Helpful Agents already up to date
```

### Error: Missing Directory

```
❌ Sync failed: Source directory not found

Missing: .cursor/skills/
Location: <workspace-root>

Solutions:
1. Verify you're in the correct workspace
2. Check if .cursor/skills exists: ls -la .cursor/
3. Create skills directory if needed: mkdir -p .cursor/skills
```

### Error: Helpful Agents Not Found

```
❌ Sync failed: Helpful Agents repo not found

Expected: Helpful Agents/.git
Location: <workspace-root>

Solutions:
1. Verify Helpful Agents folder exists: ls -d "Helpful Agents"
2. Check if it's a git repo: ls "Helpful Agents/.git"
3. Clone if missing: See workspace CLAUDE.md for setup
```

## Critical Rules

### Sync Direction

| Source                       | Destination                    | Direction  |
| ---------------------------- | ------------------------------ | ---------- |
| ✅ `~/.cursor/skills/`       | `Helpful Agents/.cursor/skills/` | One-way → |
| ✅ workspace `.cursor/skills/` | `Helpful Agents/.cursor/skills/` | One-way → |
| ✅ workspace `.cursor/commands/` | `Helpful Agents/.cursor/commands/` | One-way → |
| ❌ NEVER reverse             | Merge only, no --delete        | Never ←   |

**Why one-way:**

- User-level + workspace = working copy
- Helpful Agents = publication copy (for GitHub sharing)
- No --delete on phases — merge only; manual cleanup if retiring a skill

### After Sync

**Always review changes before pushing:**

1. **Check git status:**

   ```bash
   cd "Helpful Agents" && git status
   ```
2. **Review diffs:**

   ```bash
   cd "Helpful Agents" && git diff
   ```
3. **Commit and push** (if changes look correct):

   ```bash
   @git-sync Helpful_Agents
   ```

### What Gets Synced

| Item                 | Synced? | Reason                    |
| -------------------- | ------- | ------------------------- |
| ✅ Skills (SKILL.md) | Yes     | Core skill definitions    |
| ✅ References/       | Yes     | Supporting documentation  |
| ✅ Scripts/          | Yes     | Executable helpers        |
| ✅ Assets/           | Yes     | Templates, configs        |
| ✅ Commands (.md)    | Yes     | Command definitions       |
| ❌ .DS_Store         | No      | macOS metadata (excluded) |
| ❌ Temp files        | No      | Not tracked in source     |
| ❌ git-sync/         | No      | Contains PII; public version maintained separately in Helpful Agents |

### PII-Excluded Skills

Some skills contain personal information or are workspace-specific. Excluded from sync:

| Skill         | Reason                         |
| ------------- | ------------------------------ |
| `git-sync/`   | PII (paths, emails); symlink to MyPrivatePrompts |
| `update-lenny/` | Workspace-specific; symlink to MyPrivatePrompts |

**git-sync public template:** Maintained in Helpful Agents with placeholders (WORKSPACE_ROOT, etc.). Update manually when logic changes.

## Integration with Git-Sync

**Git-sync already includes this:**

The `@git-sync` skill automatically runs this sync as a pre-sync step before pushing any folder. So this skill is useful when you want to:

- **Manually sync** without pushing to GitHub
- **Preview changes** before committing
- **Sync-only** without full git workflow
- **Debug sync issues** in isolation

**Relationship:**

```
Manual: @sync-helpful-agents-cursor → Review → @git-sync
Auto:   @git-sync → (runs this sync automatically) → Push
```

## Troubleshooting

### Sync Shows Many Deletions

**Symptom:** `rsync` reports many `D` (deleted) files

**Cause:** Files exist in `Helpful Agents/.cursor/` but not in workspace `.cursor/`

**Solutions:**

1. Check if files were intentionally deleted from workspace
2. If accidental deletion: Restore files from git history
3. If intentional cleanup: Proceed with sync (mirrors cleanup)

### Sync Fails: Permission Denied

**Symptom:** `rsync: permission denied`

**Solutions:**

1. Check file permissions: `ls -la .cursor/skills/`
2. Verify write access to Helpful Agents: `touch "Helpful Agents/test" && rm "Helpful Agents/test"`
3. Run with appropriate permissions

### No Changes Detected After Edit

**Symptom:** Made changes to skills but sync shows no changes

**Solutions:**

1. Verify you edited files in workspace `.cursor/` (not `Helpful Agents/.cursor/`)
2. Check file was saved: `ls -lt .cursor/skills/your-skill/SKILL.md`
3. Re-run sync with verbose output to see what's being compared

### Helpful Agents Has Uncommitted Changes

**Symptom:** Sync works but `git status` shows unexpected changes

**Solutions:**

1. Review changes: `cd "Helpful Agents" && git diff`
2. If changes are from previous unsynced work: Commit them first
3. If changes are unexpected: Use `git checkout -- .cursor/` to reset
4. Re-run sync after resolving

## Usage Examples

### Example 1: Manual Sync After Creating New Skill

**User:**

```
I just created a new skill. Sync it to Helpful Agents.
```

**Agent Actions:**

1. Run pre-flight checks
2. Sync skills directory
3. Sync commands directory (no changes)
4. Report new skill detected in git status
5. Suggest reviewing and pushing

### Example 2: Sync Before Publishing

**User:**

```
@sync-helpful-agents-cursor
```

**Agent Actions:**

1. Verify source and destination
2. Run rsync for skills (8 folders synced, 1 modified)
3. Run rsync for commands (0 files, no changes)
4. Report summary with git status
5. Suggest next steps

### Example 3: Cleanup Deleted Skills

**User:**

```
I deleted production-clone command. Mirror that to Helpful Agents.
```

**Agent Actions:**

1. Run sync with `--delete` flag
2. Remove production-clone.md from Helpful Agents/.cursor/commands/
3. Report deletion in git status
4. Confirm deletion was intentional
5. Suggest committing cleanup

## Technical Details

### Rsync Strategy

**Why rsync over cp:**

- **Incremental**: Only copies changed files (faster)
- **Mirror**: `--delete` ensures exact replica
- **Preserves**: Maintains timestamps, permissions, structure
- **Reliable**: Battle-tested tool for synchronization

**Alternative approaches considered:**

- `cp -r`: No incremental updates, no deletion of removed files
- `git submodule`: Too complex for simple mirroring
- Manual copy: Error-prone, no automation

### Directory Structure

**Source (Workspace):**

```
.cursor/
├── skills/
│   ├── skill-name/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── scripts/
│   └── ...
└── commands/
    └── command.md
```

**Destination (Helpful Agents):**

```
Helpful Agents/
└── .cursor/
    ├── skills/
    │   ├── skill-name/
    │   │   ├── SKILL.md
    │   │   ├── references/
    │   │   └── scripts/
    │   └── ...
    └── commands/
        └── command.md
```

**Exact mirror**: Structure, filenames, subdirectories all identical

## Related Skills

- **@git-sync**: Includes this sync automatically before pushing
- **@context-advisor**: Helps decide when to create new skills/commands

## Key Principles

1. **One-way sync**: User-level + workspace → Helpful Agents (never reverse)
2. **Merge only**: No --delete; prevents accidental removal of skills
3. **Pre-push step**: Always sync before pushing Helpful Agents to GitHub
4. **Review changes**: Always check git diff before committing
5. **Idempotent**: Safe to run multiple times (no side effects if already synced)

---

**Created:** 2026-02-03
**Purpose:** Mirror workspace cursor configs to public Helpful Agents repo
**Integration:** Used by @git-sync as pre-sync step
