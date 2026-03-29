# Unused Files Cleanup Reference

## Scope

After fixing bugs and applying optimizations, identify and delete unused files **excluding documentation** (documentation cleanup is handled separately).

## Files to Identify for Deletion

| Category | Examples | Action |
|----------|----------|--------|
| **Unused Code Files** | Unused components, utilities, deprecated modules | Delete if not imported anywhere |
| **Backup Files** | `*.backup`, `*.bak`, `*_backup.*`, `*.old` | Delete if content preserved in git |
| **Temporary Files** | `temp_*`, `tmp_*`, `*.tmp`, test output files | Delete |
| **Build Artifacts** | `*.log`, `*.cache` (if not in .gitignore) | Delete |
| **Duplicate Files** | `*_copy`, `*_old`, `*_v1`, `*_v2` suffixes | Delete if superseded |
| **Unused Config** | Unused config files, empty directories | Delete if not referenced |
| **Legacy Code** | Deprecated modules marked for removal | Delete if migration complete |

## Files to NEVER Delete

| Category | Examples | Reason |
|----------|----------|--------|
| **Documentation** | All `.md` files | Handled separately |
| **Git Files** | `.git/`, `.gitignore`, `.gitattributes` | Version control |
| **Config Files** | `package.json`, `tsconfig.json`, `.env.example` | Project setup |
| **Test Files** | `*.spec.ts`, `*.test.ts`, `e2e/` | Testing |
| **Build Config** | `next.config.ts`, `tailwind.config.ts` | Build system |
| **Dependencies** | `node_modules/`, `package-lock.json` | Dependencies |
| **IDE Config** | `.cursor/`, `.vscode/` | Editor settings |

## Verification Before Deletion

Before deleting any file:

1. **Check imports/references**
   ```bash
   # Search for imports of the file
   rg "from ['\"].*filename" --type ts --type tsx
   rg "require.*filename" --type js
   ```

2. **Check git history**
   ```bash
   # Verify content is in git history
   git log --oneline -- path/to/file
   ```

3. **Check documentation**
   - Search for references in README, docs
   - Check comments mentioning the file

4. **Check build/test**
   - Verify deletion won't break builds
   - Run tests after deletion

5. **High confidence only**
   - Only delete files with high confidence they're unused
   - When in doubt, report but don't delete

## Execution Steps

### 1. Scan for Patterns

```bash
# Backup files
find . -name "*.backup" -o -name "*.bak" -o -name "*_backup.*" -o -name "*.old"

# Temporary files
find . -name "temp_*" -o -name "tmp_*" -o -name "*.tmp"

# Duplicate files
find . -name "*_copy.*" -o -name "*_old.*" -o -name "*_v[0-9].*"
```

### 2. Check for Unused Exports

```bash
# Find exports that are never imported
npx ts-unused-exports tsconfig.json
```

### 3. Verify Each File

For each candidate file:
- Search codebase for references
- Check if in active use
- Verify git history preserves content

### 4. Delete with Logging

Log each deletion:
```
🗑️ src/components/OldButton.tsx — Replaced by Button.tsx
🗑️ data/config.json.backup — Content in git history
```

## Report Format

### Unused Files Deleted

```
🗑️ src/components/OldButton.tsx — Unused component (replaced by Button.tsx)
🗑️ src/lib/deprecated.ts — Unused utility file (no imports found)
🗑️ data/config.json.backup — Backup file (content preserved in git)
🗑️ temp_test_output.json — Temporary test file
```

### Files Reviewed but Kept

```
⏸️ src/utils/legacy.ts — Referenced in comments, may be needed
⏸️ scripts/migrate.sh — One-time migration, keep for reference
```

**Note:** Documentation files (`.md`) are excluded from this process.
