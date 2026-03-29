# Project Health Audit — Detailed Checklist

Use this when running the project-health-audit skill. Check each category systematically.

**Report structure:** Lead with Overall Status (Green/Yellow/Red) and % Completion (code vs. docs), then Summary & Recommendation (unified section). Top priority = category with highest impact/blast radius. Detail tables follow.

---

## 0. % Completion (Code vs. Docs)

| Step | How to Verify |
|------|----------------|
| Total requirements | Count P0/P1 items in Product Brief UX, BE, INT tables (or PRD equivalent) |
| Implemented | For each: grep/SemanticSearch codebase. Mark Met / Partial / Not Met |
| Formula | `(Met + 0.5 × Partial) / Total × 100`; round to nearest 5% |
| Fallback | Use "Current State vs Brief" or "Build Gap" if present; else "N/A" |

---

## 1. Conflicts

| Check | How to Verify |
|-------|----------------|
| PM vs Design | Requirements say "must use [named design system]" but mocks use something else? |
| PM vs Engineering | Product Brief says "usage limit trigger" but no code implements it? |
| Design vs Engineering | Design spec says "max 320px" but code uses different value? |
| Doc vs Doc | Product Brief says "immediate sign-in" but Demo Plan says "delayed OK"? |
| Version drift | README says "v1.0" but Product Brief says "v1.1"? |

**Grep patterns (tune to stack):** design-system package names, `usage limit`, `trigger`, `sign-in`

---

## 2. Open / Unresolved Questions

| Check | How to Verify |
|-------|----------------|
| Open Questions table | Search for "Open Question", "Open Questions" section |
| TBD markers | `grep -r "TBD"` |
| Question markers | `grep -r "❓"` or `"QUESTION:"` |
| Decision needed | `grep -r "Decision needed"` |
| Action items | Meeting transcripts with "Action:" and no "Done" |
| TODO/FIXME | `grep -r "TODO\|FIXME"` in docs (not just code) |

**Common locations:** Product Brief, PRD, meeting notes, transcripts, PIVOT_LOG.md

---

## 3. Risks Without Mitigation

| Check | How to Verify |
|-------|----------------|
| Risks table | Find Risks section; each row has non-empty Mitigation column? |
| High impact | Any "High" impact with "TBD" or empty mitigation? |
| Orphan risks | Risks mentioned in prose but not in Risks table? |
| Owner missing | Risk has no owner? |

**Grep patterns:** `Risk`, `Mitigation`, `Impact`, `Owner`

---

## 4. Requirements vs Build

| Check | How to Verify |
|-------|----------------|
| P0 requirements | Extract from Product Brief / PRD requirements table |
| Implementation | For each P0: `grep` or `SemanticSearch` for implementation |
| Build gap section | If doc has "Current State vs Brief" or "Build Gap", use it |
| Acceptance criteria | Requirements have acceptance criteria? Can they be verified? |

**Example:** Product Brief says "BE-04: Entitlement provisioning API". Search codebase for provisioning, entitlement, provision. If none found → not met.

---

## 5. Hygiene

| Check | How to Verify |
|-------|----------------|
| Broken links | Check `[text](path)` — does path exist? |
| Dead references | Doc cites `Requirements/Context/` but folder was deleted? |
| Stale dates | "Last Updated" > 6 months? |
| Renamed files | Doc cites `Commerce_Agent_Content_Standards.md` but file is now `Content_Standards.md`? |
| Orphan files | File exists but nothing references it? |

**Grep patterns:** `](`, `@`, `Last Updated`, `Reference:`

---

## 6. Consistency

| Check | How to Verify |
|-------|----------------|
| Terminology | "Checkout" vs "purchase flow" vs "commerce flow" — same term used? |
| File naming | `Product Brief.md` vs `product-brief.md` — consistent? |
| Version numbers | All docs show same version? |
| Section names | "Requirements" vs "Functional Requirements" — aligned? |

---

## 7. Canonical Doc Checklist

If project follows 6-doc structure (README, CLAUDE, PLAN, BUILD_LOG, PIVOT_LOG, ARCHITECTURE):

| Doc | Present? | Up to date? |
|-----|----------|-------------|
| README.md | | |
| CLAUDE.md | | |
| PLAN.md | | |
| BUILD_LOG.md | | |
| PIVOT_LOG.md | | |
| ARCHITECTURE.md | | |

---

## 8. Role-Specific Checks

**PM artifacts:**
- Product Brief has Evidence Log?
- Open Questions have owners and due dates?
- Requirements have acceptance criteria?

**Design artifacts:**
- Design specs reference Product Brief or requirements?
- Design tokens / style guide match implementation?

**Engineering artifacts:**
- README matches current setup?
- CLAUDE.md has correct file paths?
- .cursor/rules reference existing files?
