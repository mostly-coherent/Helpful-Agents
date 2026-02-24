# KB Drift Report

Generates a structured drift report comparing a system's PM-centric Knowledge Base against the canonical `Service_KB_Template`. Identifies structural deviations, missing sections, and provenance gaps, then produces a prioritized remediation plan. Use when auditing a Knowledge Base, checking KB quality, preparing for KB review, or after KB Runner updates. Triggers on "drift report", "KB audit", "KB quality check", "compare KB to template".

## Inputs

1. `<SYSTEM_NAME>` — human-readable system name
2. `<KB_FOLDER>` — path to the system's KB folder
3. The 7 required KB files: `00_Service_Overview.md` through `05_Data_Dictionary.md` + `README.md`
4. Reference: `service-kb-template` skill (canonical information architecture)

## Report Output Structure

### 1. Executive Summary
2-4 sentences: overall drift severity and urgency.

### 2. KB Drift Summary Table

| Doc | Exists? | Structure Drift | Content Drift | Provenance Block? | Notes |
|-----|---------|-----------------|---------------|-------------------|-------|
| 00_Service_Overview.md | Yes/No | None/Minor/Moderate/Severe | None/Minor/Moderate/Severe | Yes/No/Partial | ... |
| (one row per doc) | | | | | |

### 3. Per-Document Drift Details (for each of 7 docs)
- **Template vs Actual Headings** — expected vs found `##` headings
- **Detected Drift** — missing sections, extra sections, reordered, renamed, missing front-matter, missing provenance
- **Severity & Impact** — how it affects PM usability
- **Recommended Fixes** — 3-5 precise, actionable edits

### 4. Cross-KB Consistency Issues
- Terminology inconsistencies across docs
- Version/date misalignment
- Provenance blocks missing in some but not all

### 5. Suggested Remediation Plan
3-7 high-impact tasks to realign KB with template.

## Drift Detection Dimensions

1. **File Presence & Naming** — all 7 files exist with expected names
2. **Front-Matter Consistency** — Version, Purpose, Audience, Service present and consistent
3. **Top-Level Section Structure** — compare `##` headings against template; flag missing, extra, renamed, reordered
4. **Provenance & Freshness Blocks** (docs 00-05) — present with all fields (Codebase Version, Source Repos, Known Gaps)
5. **README Alignment** — has overview, version, documentation navigator, KB Change Snapshot, history
6. **Terminology & Role Layering** — PM-friendly language, consistent entity/system names

## Severity Levels

| Level | Criteria |
|-------|----------|
| **None** | All expected sections present, front-matter and provenance well-formed |
| **Minor** | Few missing/extra sections, naming differences but intent clear |
| **Moderate** | Important sections missing or misplaced, provenance incomplete, README navigator stale |
| **Severe** | Entire doc missing or wrong role, major sections absent, no provenance/versioning |

## Process

1. Load `service-kb-template` skill as the reference architecture
2. Load all 7 KB files from `<KB_FOLDER>`
3. For each doc: extract `##` headings, check front-matter, check provenance block
4. Compare against template expectations
5. Rate severity per doc
6. Check cross-KB consistency
7. Generate remediation plan prioritized by impact
8. Output the drift report

## Related Skills

| Skill | Purpose |
|-------|---------|
| `service-kb-template` | Canonical KB structure (the template being compared against) |
| `kb-runner` | Create/refresh KB content (uses this report to guide updates) |
