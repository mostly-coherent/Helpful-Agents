---
description: Harmonizes project documentation to canonical 6-file structure. Use when user says "cleanup docs", "harmonize documentation", "consolidate md files", or wants to reduce scattered .md files in an app project to README, CLAUDE, PLAN, BUILD_LOG, PIVOT_LOG, ARCHITECTURE.
---

# Cleanup Docs

Harmonize user-authored project documentation to the canonical 6-file structure. Only processes documentation files (not application-dependent markdown like content, templates, or data files).

## When to Use

- User says "cleanup docs", "harmonize documentation", "consolidate md files"
- Project has scattered .md files (FEATURES.md, PROGRESS.md, etc.) in root
- Target: app project folder (not Docs_*, Helpful Agents, MyPrivate*)

## Canonical 6 Files

| File | Purpose |
|------|---------|
| README.md | Human overview, getting started |
| CLAUDE.md | AI context, commands, setup |
| PLAN.md | Blueprint (WHAT) |
| BUILD_LOG.md | Journal (WHEN) |
| PIVOT_LOG.md | Decisions (WHY) |
| ARCHITECTURE.md | System design (HOW) |

## Decision Tree (Summary)

For each non-canonical **documentation** .md in project root:

0. **Application-dependent?** (content, templates, data) → EXCLUDE
1. **Useless?** (duplicate, obsolete, empty) → Delete or archive
2. **Single category?** → Merge to that canonical file → Delete
3. **Multi-category?** → Split, merge to multiple → Delete
4. **Uncertain?** → Preserve, document, ask user

**Key rule:** Never touch application-dependent markdown. Only user-authored documentation.

## Instructions

1. List .md files in project root (exclude node_modules, .next, src/, app/, etc.)
2. Exclude application-dependent files (content, templates, data)
3. For each documentation candidate: apply decision tree
4. Merge content with attribution; delete after merge
5. Generate summary report

For full workflow, decision criteria, merge format, and report template, see [REFERENCE.md](references/REFERENCE.md).
