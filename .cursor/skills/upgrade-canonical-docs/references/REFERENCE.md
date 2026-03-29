# Upgrade Canonical Docs Agent

> **Purpose:** Upgrade existing project documentation to latest standards  
> **Scope:** Renames files + updates formats to match CONSOLIDATED_USER_RULES.md  
> **Prerequisite:** Run `Cleanup-folder.md` first if project has scattered `.md` files  
> **Usage:** Run on any app project folder

## Quick Reference: Standardized File Names

| Canonical Name | Common Variants to Rename |
|----------------|---------------------------|
| `PLAN.md` | Plan.md, PLANS.md, REQUIREMENTS.md |
| `BUILD_LOG.md` | BUILD-LOG.md, BUILDLOG.md, BUILD.md, PROGRESS.md |
| `PIVOT_LOG.md` | PIVOTS.md, PIVOT-LOG.md, DECISIONS.md |
| `ARCHITECTURE.md` | Architecture.md, DESIGN.md, STRUCTURE.md |
| `CLAUDE.md` | Claude.md, AI_CONTEXT.md |
| `README.md` | Readme.md, readme.md |

---

## Execution Workflow

### Phase 1: Rename Files

**Step 1.1: Check for variant names**

```bash
ls -la *.md | grep -iE "(plan|build|pivot|architecture|claude|readme)"
```

**Step 1.2: Rename to standardized names**

| If found... | Rename to... |
|-------------|--------------|
| `PIVOTS.md` | `PIVOT_LOG.md` |
| `BUILD-LOG.md` | `BUILD_LOG.md` |
| Any case variant | UPPERCASE with underscores |

**Step 1.3: Update cross-references**

Search for references to old filenames and update them.

---

### Phase 2: Upgrade PLAN.md Format

**Required format (from CONSOLIDATED_USER_RULES.md):**

Every requirement/use case MUST have:
- **Verification method**: How to test it
- **Code paths**: Which files/functions implement it (for multi-mode features)

**Template:**

```markdown
## Requirements / Use Cases

| ID | Requirement | Verification Method | Code Paths |
|----|-------------|---------------------|------------|
| R1 | [What the feature does] | [How to test it works] | [Files/functions] |
| R2 | Custom date range produces exactly N items total | CLI: `--days 7 --item-count 25` should produce 25 items | `generate.py:main()`, `process_aggregated_range()` |
```

**Upgrade steps:**

1. Read existing PLAN.md
2. Identify requirements/use cases/features section
3. If table format exists but missing columns → Add Verification Method + Code Paths columns
4. If bullet format → Convert to table with all columns
5. If no requirements section → Add template section

---

### Phase 3: Upgrade BUILD_LOG.md Format

**Required format:**

Each "Done" item MUST reference:
- **PLAN.md requirement ID** (e.g., R1, R2)
- **Verification result** (tested, passed/failed)

**Template:**

```markdown
## Progress - YYYY-MM-DD

**Done:**
- [R1] Feature description — verified via [test method]
- [R2] Another feature — tested: [result]

**In Progress:**
- [R3] Current work — X% complete

**Next:**
- [R4] Upcoming priority

**Blockers:**
- [Issue] — [mitigation]
```

**Upgrade steps:**

1. Read existing BUILD_LOG.md
2. For each "Done" item without PLAN.md reference → Add `[RX]` prefix
3. For each "Done" item without verification → Add verification note
4. If format is significantly different → Restructure to template

---

### Phase 4: Upgrade PIVOT_LOG.md Format

**Required format for architecture/refactor decisions:**

Must include:
- **Code Paths Affected**: Which files/functions changed
- **Verification**: How the change was tested

**Template:**

```markdown
## Decision: [Name] - YYYY-MM-DD

**Decision:** [What we chose]
**Rationale:** [Why this approach]
**Alternatives:** [What we rejected and why]
**Status:** [Implemented/Blocked/Deferred]
**DRI:** [Owner]

### Code Paths Affected
- `file1.py:function_name()` — [what changed]
- `file2.ts:ComponentName` — [what changed]

### Verification
- [ ] Unit test: [test name/command]
- [ ] E2E test: [test scenario]
- [ ] Manual test: [steps performed]
```

**Upgrade steps:**

1. Read existing PIVOT_LOG.md (or PIVOTS.md before rename)
2. For each decision entry:
   - If missing Code Paths → Add section (can be `TBD` if unknown)
   - If missing Verification → Add section (can be `TBD` if unknown)
3. Add `### Code Paths Affected` and `### Verification` headers to template

---

### Phase 5: Verification Checklist

**After upgrade, verify:**

- [ ] All 6 files use standardized names (UPPERCASE, underscores)
- [ ] PLAN.md has requirements table with Verification Method + Code Paths columns
- [ ] BUILD_LOG.md entries reference PLAN.md IDs
- [ ] PIVOT_LOG.md decisions have Code Paths + Verification sections
- [ ] No broken cross-references to old filenames

---

## Report Template

```markdown
# Canonical Docs Upgrade Report - [Project Name]

**Date:** YYYY-MM-DD  
**Target Folder:** [path]

## Files Renamed
- [old name] → [new name]

## PLAN.md Updates
- [ ] Added Verification Method column
- [ ] Added Code Paths column
- [ ] Converted from bullet list to table
- [ ] No changes needed

## BUILD_LOG.md Updates
- [ ] Added PLAN.md ID references to Done items
- [ ] Added verification notes
- [ ] No changes needed

## PIVOT_LOG.md Updates
- [ ] Added Code Paths Affected sections
- [ ] Added Verification sections
- [ ] No changes needed

## Cross-Reference Updates
- [file] — updated reference to [old → new]

## Summary
- Files renamed: [N]
- Format upgrades applied: [N]
- Result: Project documentation now matches latest standards.
```

---

## Execution Checklist

When running this agent:

1. [ ] Confirm target is an app project folder
2. [ ] Check for file name variants → Rename to standard
3. [ ] Update cross-references to renamed files
4. [ ] Read PLAN.md → Add/update requirements table format
5. [ ] Read BUILD_LOG.md → Add PLAN.md ID references + verification
6. [ ] Read PIVOT_LOG.md → Add Code Paths + Verification sections
7. [ ] Verify no broken references
8. [ ] Generate summary report

---

## When to Use Which Agent

| Situation | Agent |
|-----------|-------|
| Project has scattered `.md` files to consolidate | `Cleanup-folder.md` |
| Project has 6 canonical files but outdated format | `Upgrade-canonical-docs.md` (this one) |
| New project setup | Neither — use CONSOLIDATED_USER_RULES.md templates |

**Typical workflow:**
1. Run `Cleanup-folder.md` (consolidate many → 6)
2. Run `Upgrade-canonical-docs.md` (standardize 6 → latest format)

---

**Last Updated:** 2026-01-05  
**Reference:** MyPrivatePrompts/CONSOLIDATED_USER_RULES.md

