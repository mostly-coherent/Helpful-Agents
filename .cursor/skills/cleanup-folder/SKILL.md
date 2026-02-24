# Documentation Cleanup Agent

Harmonizes scattered project documentation into the 6 canonical files. Analyzes non-canonical `.md` files, categorizes content, merges into the right canonical file, and deletes originals. Use when a project has too many documentation files, scattered docs, or needs doc consolidation. Triggers on "cleanup docs", "consolidate docs", "merge documentation", "too many md files".

## Canonical Documentation Files

Every app project should have exactly these 6 documentation files:

| File | Purpose | Content Type |
|------|---------|--------------|
| `README.md` | Human-facing overview | User guides, project intro |
| `CLAUDE.md` | AI assistant context | Commands, patterns, setup |
| `PLAN.md` | Blueprint (WHAT) | Requirements, features, phases |
| `BUILD_LOG.md` | Journal (WHEN) | Progress diary, completion |
| `PIVOT_LOG.md` | Decisions (WHY) | Course corrections, rationale |
| `ARCHITECTURE.md` | System design (HOW) | Components, data flow, patterns |

**Excludes:** Application-dependent markdown files (content, templates, data files in `src/`, `app/`, `components/`, `lib/`).

## Decision Tree

For each non-canonical documentation `.md` file in project root:

1. Is it part of the application's functionality? → **EXCLUDE** (don't process)
2. Is it empty/trivial/auto-generated/duplicate? → **Delete** (if verified useless) or **Archive** (if uncertain)
3. Does it fit a single canonical category? → **Merge** to that file → Delete
4. Does it span multiple categories? → **Split** content → Merge to multiple files → Delete
5. Is categorization uncertain? → **Preserve** original, tentatively merge, ask user

## Categorization Map

| If file contains... | Map to... | Example filenames |
|---------------------|-----------|-------------------|
| Vision, requirements, features, milestones | `PLAN.md` | FEATURES.md, ROADMAP.md |
| Progress, completion status, timeline | `BUILD_LOG.md` | PROGRESS.md, TODO.md |
| Decisions, choices, pivots, rationale | `PIVOT_LOG.md` | DECISIONS.md, MIGRATION.md |
| System design, components, data flow | `ARCHITECTURE.md` | DESIGN.md, STRUCTURE.md |
| Setup, commands, config, troubleshooting | `CLAUDE.md` | SETUP.md, CONFIG.md |
| User guides, getting started, overview | `README.md` | QUICK_START.md, OVERVIEW.md |

## Execution Phases

### Phase 1: Discovery
- List all `.md` files in project root
- Exclude: `node_modules/`, `.next/`, `dist/`, subdirectories, application-dependent markdown
- Identify canonical (keep) vs non-canonical (candidates for cleanup)

### Phase 2: Categorization
For each candidate, follow the decision tree:
- **Useless check:** Duplicate? Obsolete? Empty? Temporary? Auto-generated?
- **Single category?** Map and merge
- **Multi-category?** Split content across canonical files
- **Uncertain?** Use conservative heuristics (default: `CLAUDE.md`), add attribution comment, preserve original

### Phase 3: Merge Content
1. Read and extract relevant content
2. Format for target canonical file (dated entries for BUILD_LOG/PIVOT_LOG)
3. Append with attribution: `<!-- Merged from [filename] on YYYY-MM-DD -->`
4. Check for duplicates before merging

### Phase 4: Cleanup
- Delete merged files (only if content verified merged)
- Keep uncertain files until user confirms
- Log all actions

### Phase 5: Verification
- [ ] Only 6 canonical `.md` files remain in project root
- [ ] All content properly formatted and dated
- [ ] All merges have attribution comments
- [ ] Summary report generated

## Key Principles

1. **Documentation files only** — never touch app-dependent markdown
2. **Preserve over delete** — when uncertain, preserve
3. **Never lose information** — extract all content before deleting
4. **Document everything** — attribution comments, deletion rationale
5. **Maintain chronology** — preserve date order in BUILD_LOG and PIVOT_LOG

## Special Cases

| File Type | Action |
|-----------|--------|
| Version-specific (`V1_*.md`) | Split: decisions → PIVOT_LOG, architecture → ARCHITECTURE, progress → BUILD_LOG |
| Feature-specific (`FEATURE_X.md`) | Split: requirements → PLAN, status → BUILD_LOG |
| Migration/Deployment | Split: decisions → PIVOT_LOG, technical → ARCHITECTURE/CLAUDE |
| Summary files | Split: progress → BUILD_LOG, decisions → PIVOT_LOG |

## Report Template

After cleanup, generate:
- Files Merged and Deleted (with target canonical file)
- Files Deleted (confirmed useless, with rationale)
- Files Requiring Review (uncertain, with recommendation)
- Summary: Total processed, merged, deleted, needs review

## Related Skills

| Skill | Purpose |
|-------|---------|
| `cleanup-folder` (this) | Consolidate scattered docs → 6 canonical files |
| `upgrade-canonical-docs` | Standardize filenames + upgrade format |

**Workflow:** Run `cleanup-folder` first (consolidate) → then `upgrade-canonical-docs` (standardize).
