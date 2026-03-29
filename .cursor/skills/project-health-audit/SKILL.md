---
name: project-health-audit
description: Audits a project folder for conflicts, open questions, unresolved risks, requirements vs build gaps, hygiene, and consistency. Use when user says "audit project", "project health check", "find conflicts", "scan for gaps", "project coherence", "unresolved questions", or "project hygiene".
---

# Project Health Audit

**Purpose:** Scan a project's PM, Design, and Engineering artifacts and surface conflicts, gaps, risks, and hygiene issues.

## When to Use

- User says "audit project", "project health check", "find conflicts", "scan for gaps"
- User says "project coherence", "unresolved questions", "project hygiene"
- User says "what's missing in this project", "requirements vs build gaps"

## Project Root

- **Explicit:** User provides `@folder` or path (e.g. `@Commerce_AI_Assistant`)
- **Default:** Current workspace or open file's project root

## Process

### 1. Discover Artifact Structure

Scan the project folder for typical locations. Adapt if project uses different conventions.

| Role | Typical Folders/Files | What to Look For |
|------|------------------------|------------------|
| **PM** | `Requirements/`, `Product Brief.md`, `PRD`, `*.md` in root | Product Brief, PRD, meeting notes, transcripts, research, competitor analysis |

| **Design** | `Designs/`, `design/`, `mockups/`, `wireframes/` | Mocks, wireframes, style guides, design principles |

| **Engineering** | `app/`, `src/`, `.cursor/`, `README.md`, `CLAUDE.md` | Code, rules, skills, agents, README, build docs |

### 2. Run Audit Checklist

For each category below, search and cross-reference. See [AUDIT_CHECKLIST.md](references/AUDIT_CHECKLIST.md) for detailed checks.

**Conflicts:**
- PM says X, Design says Y, or Engineering built Z — contradictions
- Requirements vs implementation (e.g. "must use design system X" vs Tailwind-only)
- Version mismatches (doc says v1, code says v2)

**Open / Unresolved:**
- Tables with "Open Questions", "TBD", "❓", "Decision needed"
- Meeting notes with "Action: TBD" or "Follow up"
- TODO/FIXME without resolution

**Risks Without Mitigation:**
- Risks table with empty mitigation
- "High impact" with no owner or plan
- Risks mentioned in prose but not in Risks section

**Requirements vs Build:**
- P0/P1 requirements in Product Brief or PRD
- Grep codebase for implementation
- List requirements with no implementation

**Hygiene:**
- Broken internal links (e.g. `[Link](path)` to missing file)
- Dead references (doc cites deleted folder)
- Stale dates (Last Updated > 1 year old)
- Outdated file names (doc references old filename)

**Consistency:**
- Terminology mismatch (e.g. "checkout" vs "purchase flow")
- Naming (Product Brief vs PRD vs product-brief.md)
- Version numbers across docs

### 3. Overall Status (Green / Yellow / Red)

Assign one status based on findings:

| Status | Criteria |
|--------|----------|
| **Green** | No P0s; P1s are few and non-blocking; project in good shape |
| **Yellow** | Some P1s or minor P0s with clear mitigation path; needs attention soon |
| **Red** | P0s present; critical requirements not met; blocking conflicts; high-impact risks unmitigated |

### 3.1 % Completion (Code vs. Docs)

Estimate build completion by comparing requirements (docs) to implementation (code):

1. **Extract total requirements** from Product Brief or PRD — count P0/P1 items in UX, BE, INT tables (or equivalent). If no structured requirements table, use milestones/scope from PLAN.md or README.
2. **Count implemented** — for each requirement, grep or SemanticSearch the codebase. Mark as Met, Partial, or Not Met.
3. **Compute %:** `(Met + 0.5 × Partial) / Total × 100`. Round to nearest 5%.
4. **Fallback:** If requirements are unclear, use "Current State vs Brief" or "Build Gap" section if present; otherwise state "N/A — no structured requirements."

**Note:** % completion reflects code vs. docs only. It does not account for quality, tests, or production readiness.

### 4. Output Format

Produce a structured report. **Lead with Overall Status and Summary & Recommendation.** Then detail tables.

```markdown
# Project Health Audit — [Project Name]

**Audited:** [date] | **Root:** [path]

---

## Overall Status: [Green | Yellow | Red]

**% Completion (code vs. docs):** [X%] — [one-line rationale, e.g. "12 of 18 P0 requirements implemented"]

[One-line status rationale]

---

## Summary & Recommendation

**Summary:** [2–3 sentences: key counts, overall health, trend if applicable]

**Top priority for project team:** [Category/aspect] — [Why it needs attention: impact, blast radius, who is affected]. [1–2 concrete next steps.]

**Other areas to watch:** [Brief list of secondary concerns, if any]

---

## Conflicts
| Location | Issue | Evidence |
|----------|-------|----------|
| ... | ... | ... |

## Open / Unresolved Questions
| Source | Question | Owner | Due |
|--------|----------|-------|-----|
| ... | ... | ... | ... |

## Risks Without Mitigation
| Risk | Impact | Gap |
|------|--------|-----|
| ... | ... | ... |

## Requirements Not Met
| Req ID | Requirement | Status |
|--------|-------------|--------|
| ... | ... | ... |

## Hygiene Issues
| File | Issue |
|------|-------|
| ... | ... |

## Consistency Issues
| Type | Location | Detail |
|------|----------|--------|
| ... | ... | ... |
```

**Choosing "Top priority for project team":** Rank by impact and blast radius. Typical order:
1. **Requirements Not Met** (P0) — blocks delivery, affects PM + Eng
2. **Conflicts** — teams work at cross-purposes; doc vs build mismatch
3. **Risks Without Mitigation** (high impact) — compliance, ASC 606, security
4. **Open Questions** (past due, blocking) — decisions needed before next milestone
5. **Hygiene** — dead links, missing files (lower blast radius)
6. **Consistency** — terminology, naming (lowest blast radius)

### 5. Prioritization

- **P0:** Blocking conflicts, critical requirements not met, compliance risks
- **P1:** Open questions past due, risks with no mitigation, broken links
- **P2:** Hygiene, consistency, stale dates

## Tool Usage

- Use `grep` for patterns: "Open Question", "TBD", "❓", "TODO", "FIXME", "Risk", "Mitigation"
- Use `Glob` to find files: `**/*.md`, `Requirements/**/*`, `Designs/**/*`
- Use `Read` for key docs: Product Brief, PRD, README, CLAUDE.md
- Use `SemanticSearch` for cross-references ("Where is requirement X implemented?")

## Notes

- Projects vary. If a folder doesn't exist (e.g. no `Designs/`), note "N/A" and move on.
- Prefer evidence over inference. Quote file paths and line numbers.
- If the project has a critique doc (e.g. `Product_Brief_Critique.md`), include its findings in the report.
