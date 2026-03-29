# Documentation Cleanup — Full Reference

> Full workflow extracted from Cleanup-folder.md. See SKILL.md for summary.

## Quick Reference: Canonical Documentation Files

**IMPORTANT:** These 6 files are **user-desired documentation files** — user-authored documentation about the project, not markdown files that the application relies on for functionality.

Every app project should contain **only** these 6 **documentation** files:

| File | Purpose | Content Type |
|-----|---------|--------------|
| `README.md` | Human-facing overview | User guides, project intro, getting started |
| `CLAUDE.md` | AI assistant context | Technical details, commands, patterns, setup |
| `PLAN.md` | Blueprint (WHAT) | Product vision, requirements, features, phases |
| `BUILD_LOG.md` | Journal (WHEN) | Chronological progress diary, completion status |
| `PIVOT_LOG.md` | Decisions (WHY) | Course corrections, rationale, alternatives |
| `ARCHITECTURE.md` | System design (HOW) | Components, data flow, patterns, technical structure |

**DO NOT touch:** Markdown files that are part of the application's functionality (content files, templates, data files, etc.)

## Decision Tree

For each non-canonical DOCUMENTATION .md file in project root:

0. **Application-dependent?** → EXCLUDE
1. **Useless?** (duplicate, obsolete, empty) → Delete or archive
2. **Single category?** → Merge → Delete
3. **Multi-category?** → Split, merge → Delete
4. **Uncertain?** → Preserve, document, ask

## Execution Workflow (Phases 1–5)

### Phase 1: Discovery
List .md files in project root. Exclude: node_modules, .next, src/, app/, application-dependent files. Identify candidates.

### Phase 2: Categorization
- Decision Point 1: Useless? (duplicate, obsolete, empty, temporary, auto-generated)
- Decision Point 2: Map to PLAN/BUILD_LOG/PIVOT_LOG/ARCHITECTURE/CLAUDE/README
- Decision Point 3: Uncertainty → preserve, document, ask

### Phase 3: Merge
Read, extract, format for target, merge with attribution `<!-- Merged from [filename] -->`, check duplicates.

### Phase 4: Cleanup
Verify merge, handle uncertain files, delete merged files, log actions.

### Phase 5: Verification
Only 6 canonical files remain; summary report generated.

## Categorization Keywords

- **PLAN.md**: plan, roadmap, features, requirements, vision, scope, milestone
- **BUILD_LOG.md**: log, progress, status, implementation, completion, done, todo
- **PIVOT_LOG.md**: decision, pivot, change, migration, evolution, refactor, why
- **ARCHITECTURE.md**: architecture, design, structure, components, flow, patterns
- **CLAUDE.md**: setup, install, commands, config, troubleshooting, dev
- **README.md**: getting started, quick start, overview, intro, guide

## Report Template

```markdown
# Documentation Cleanup Report - [Project Name]
**Date:** YYYY-MM-DD | **Target:** [path]
## Canonical Preserved
✓ README, CLAUDE, PLAN, BUILD_LOG, PIVOT_LOG, ARCHITECTURE
## Merged and Deleted
- [file] → [canonical]
## Deleted (Useless)
- [file] → [rationale]
## Requiring Review
- [file] → [recommendation]
```

## Key Principles

1. Documentation files only — never application-dependent markdown
2. Preserve over delete; when uncertain, archive first
3. Never lose information; document everything
4. Ask when needed; preserve chronology in BUILD_LOG and PIVOT_LOG
