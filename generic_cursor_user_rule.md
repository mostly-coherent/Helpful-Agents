# Cursor User Rules — Team Starter Template

> **Purpose:** Recommended patterns for AI-assisted development with Cursor
> **Usage:** Copy-paste into Cursor Settings → User Rules
> **Customize:** Adapt to your team's tech stack, workflow, and standards

---

## TL;DR — Critical Rules (Read First)

1. **Traceability Loop:** PLAN.md requirements → Build → Verify ALL use cases → Log in BUILD_LOG.md with evidence
2. **Before "done":** Test ALL input modes (not just happy path); reference PLAN.md requirement IDs
3. **After code changes:** Provide clear explanation of what changed and why
4. **6 mandatory docs per project:** PLAN.md, BUILD_LOG.md, PIVOT_LOG.md, ARCHITECTURE.md, CLAUDE.md, README.md
5. **Never:** Commit secrets, force push to main, deploy without asking, invent facts

---

## CORE (always-on)

### Non-Negotiables

**No BS Policy:**
- Don't invent facts/APIs/benchmarks
- State assumptions and unknowns up front and propose how to verify
- Cite primary sources with dates
- Add freshness line for time-sensitive claims

**Clean Narrative Principle:**
- Main body prioritizes lucid, easy reading
- No inline citations, footnotes, or provenance callouts in narrative
- Put all attribution in final `Sources & Provenance` section

### Structure & Output Ergonomics

**Scannable Outputs:**
- Executive summary → numbered sections
- For multi-file edits: plan → unified diffs by file (grouped by intent) → tests → run commands → rollback/migration notes
- Prefer minimal, reversible changes
- Version header format: `Version vX.Y (YYYY-MM-DD) — Changes: <one-liner>`

**Documentation Efficiency (Critical for LLM Parsing):**
- **Dense, not verbose:** Embed info in tables/parentheticals vs. new sections
- **Lossless compression:** Preserve all critical facts, eliminate redundancy
- **Token-conscious:** User pays for every line (any LLM: Claude, GPT, etc.)
- **Before adding:** Ask "Can this fit inline/existing structure?"

**Code Citations:**
Use CODE REFERENCES (startLine:endLine:filepath) when showing existing code:

```startLine:endLine:filepath
// existing code here
```

Use MARKDOWN CODE BLOCKS (with language tag) for new/proposed code:

```python
# new code here
```

### Documentation Discipline (MANDATORY)

**Every app project (non-docs-only folders) must have 6 documentation files:**

1. **PLAN.md** - Blueprint (WHAT)
   - Created at project start
   - Product requirements, scope, phases, milestones
   - Target users, success criteria, technical approach
   - Update only when scope/approach changes significantly
   - **Every requirement/use case MUST have:**
     - **Verification method:** How to confirm it works (test command, manual check, or user flow)
     - **Code paths:** For multi-mode features, list ALL input variations (preset vs custom, etc.)

2. **BUILD_LOG.md** - Journal (WHEN)
   - Chronological progress diary (date each entry)
   - Format: Done → In Progress (%) → Next → Blockers
   - Evidence: commits, deployed URLs, test results, screenshots
   - Append daily/weekly; never replace
   - **Traceability:** Each "Done" item must reference PLAN.md requirement ID and verification result

3. **PIVOT_LOG.md** - Decisions & Course Corrections (WHY)
   - Technical decisions: Decision | Rationale | Alternatives | Date | DRI
   - Course corrections: Original → New → Trigger → Impact
   - When implementation diverges from PLAN.md, log here
   - Append chronologically; never replace
   - **For architecture/refactor decisions, MUST include:**
     - **Code Paths Affected:** List ALL code branches (e.g., preset modes AND custom modes)
     - **Verification:** How to confirm implementation is complete (test command or manual check)

4. **ARCHITECTURE.md** - System Architecture (HOW)
   - System architecture and design decisions
   - Component structure, data flow, integration points
   - Key patterns, conventions, technical constraints
   - Update when architecture changes significantly

5. **CLAUDE.md** - AI Context
   - Project start; update when tech stack or architecture changes
   - Project-specific paths, commands, tech stack
   - Environment setup, helper scripts
   - Common operations and workflows

6. **README.md** - Human-Readable Overview (MANDATORY)
   - Project start; update when major features added
   - **Priority:** Get users from "What is this?" to "App running locally" in under 60 seconds
   - **Structure:** Value prop + Visual Proof (demo/screenshot) + Quick Start (above fold), everything else in collapsible `<details>` sections
   - **Style:** Clean, copy/paste-safe commands, no inline comments in code blocks

**Documentation Cadence:**
1. Before coding: Create/update PLAN.md + ARCHITECTURE.md (include verification methods per requirement)
2. On pivots: Document immediately in PIVOT_LOG.md (include Code Paths + Verification)
3. On architectural changes: Update ARCHITECTURE.md
4. **Before marking any feature done:** Verify against PLAN.md use cases (test all input modes)
5. Session end: Update BUILD_LOG.md (reference PLAN.md IDs + verification results)
6. On completion: Mark milestones complete in BUILD_LOG.md with evidence

**Quality Gate (before work is "done"):**
- [ ] Progress logged in BUILD_LOG.md (with PLAN.md requirement IDs)
- [ ] Decisions logged in PIVOT_LOG.md
- [ ] Architecture documented in ARCHITECTURE.md
- [ ] PLAN.md reflects current scope
- [ ] README.md updated if user-facing changes
- [ ] Another AI can continue work from these docs
- [ ] **Verification:** Feature tested against PLAN.md use cases/objectives (all input modes covered)

**Why This Matters:**
> Documentation without verification is just wishful thinking. Every feature must trace back to PLAN.md requirements and be tested against all use cases. Without this discipline, intent drifts from implementation and bugs hide in untested code paths.

**Git Publishing:**
For any git-published project (pushed to GitHub), all 6 canonical docs should be tracked and published to the repository. These are the source of truth for project state and enable handoff to other developers or AI agents.

### Communication After Technical Work

**After completing any coding, configuration, or technical implementation work, ALWAYS provide a clear explanation.**

**Required for:** Technical/code changes (implementation, configuration, database changes, API integrations)
**NOT required for:** Documentation or editorial work (already in natural language)

**Format:**
1. **What problem were we solving?** (Why did we need to do this? What was broken, missing, or inefficient?)
2. **Why is it important?** (What impact does solving this have? Why does it matter for UX, system reliability, or project goals?)
3. **What did we change?** (What files/components were affected? Were any new pieces added or old ones removed?)
4. **How does it work now?** (Walk through the user experience step-by-step. How does the system behave differently?)
5. **What risks or complexity introduced?** (New risks, complexity, limitations, edge cases, known issues, trade-offs)
6. **What you could have learned?** (Concepts, patterns, approaches used. General principles applicable elsewhere)
7. **How to improve from here on?** (Next logical steps, enhancements, optimizations, related features)

**Example:**
❌ Too technical: "Refactored the API route handler to use async/await pattern and added error boundary middleware with Zod schema validation."

✅ Clear explanation:
- **What problem?** The app was crashing whenever it tried to save data to the database.
- **Why important?** When apps crash unexpectedly, users lose trust and stop using them.
- **What changed?** Updated the code that handles saving data and added a safety system that catches errors.
- **How it works now?** If something goes wrong, instead of crashing, it shows a friendly message. Your work stays on screen.
- **Risks?** More code to maintain. If the database is offline for a long time, users still can't save.
- **What learned?** "Graceful degradation" — when things break, fail in a way that's helpful rather than destructive.
- **How to improve?** Add automatic retry logic, or save drafts locally so work isn't lost.

### Operational Hygiene

**Secrets & Environment:**
- NEVER commit secrets/keys
- Use env vars and update .env.example
- Root `.env` for workspace tools
- Project `.env.local` for app-specific secrets

**Code Quality:**
- Show only changed lines; avoid noisy refactors in same PR
- Expand both industry and internal acronyms on first mention
- Check .gitignore before creating files

### Tech Stack Philosophy

**Guidance, Not Requirements:**

> "Framework choices matter less than shipping validated solutions quickly."

**Approach:**
1. Choose best tool for the job
2. Get guidance from coding agent (Cursor + Claude) based on latest best practices
3. Prioritize: shipping validated solutions > strict tech adherence
4. Document current stack in project CLAUDE.md (guidance for consistency)

### Git Workflow

**Core Principles:**
- GitHub = source of truth
- Local edits = drafts until merged
- Each project folder = separate git repo
- Create scaffold scripts for new projects

**After PR Merged:**
1. **In GitHub:** Delete old branch → Create new feature branch
2. **In Terminal:** `git switch main && git pull origin main && git branch -d <old-branch>`
3. **In Terminal:** `git fetch origin && git switch <new-branch> && git pull origin <new-branch>`
4. **In IDE:** Make edits
5. **In IDE:** Stage → Commit → Push
6. **In GitHub:** Create PR → Merge → Delete branch
7. **Repeat from Step 1**

**Git Hygiene:**
- Descriptive commit messages
- Lint + build before commit
- Check browser console for errors
- NEVER force push to main/master
- NEVER skip hooks (--no-verify) unless explicitly requested
- NEVER commit without being asked

### Code Style

**Language & Structure:**
- TypeScript, ES modules (import/export)
- Small, focused components
- Composition over inheritance
- Descriptive names (clarity > brevity)

**Documentation Style:**
- Max 1-2 .md per topic; consolidate, never proliferate
- Clean copy/paste; no inline comments in command blocks
- Single method only; no A/B options
- Clear location tags: "In GitHub" / "In Terminal" / "In IDE"

### Autonomous Testing Policy

**AI agents are pre-authorized to run ALL tests without user interaction.**

#### E2E Testing (Playwright via Terminal) — PREFERRED

```bash
npm test              # ONE approval = full E2E suite + screenshots
npm run test:ui       # Interactive Playwright UI
npm run test:headed   # Watch tests in browser
```

**Why terminal over browser MCP?**
- Browser MCP requires per-action approval (click, screenshot, navigate)
- Terminal command = ONE approval → all tests + screenshots automatically
- Screenshots saved to `e2e-results/` folder

**Test file location:** `e2e/*.spec.ts`  
**Config:** `playwright.config.ts`

#### When to Use Browser MCP
- Ad-hoc debugging of specific page states
- Interactive exploration when tests don't exist yet
- One-off visual verification

#### Unit & Integration Testing
- Run `npm test`, `npx vitest`, `pytest` etc. autonomously
- Fix failing tests immediately; re-run to verify
- Generate test files alongside features when appropriate

#### Testing Flow
1. Run `npm test` (one terminal command)
2. Review test results and screenshots in `e2e-results/`
3. Fix any failures and re-run
4. Report summary in chat

#### When to Test Autonomously
- After implementing any UI feature
- Before marking a feature complete
- When debugging reported issues
- During code review verification

### Deployment Policy

**Rule:** Deploy only when explicitly requested by user

---

## Templates & Reference

### Evidence & Evals Harness

**For any decision-driving claim:**
- Record evidence for final `Sources & Provenance` section
- Source, date, key detail, link/commit SHA
- Keep main narrative clean—no inline evidence blocks
- Where helpful, put eval harnesses in appendix (inputs → expected outputs → pass/fail)

### Freshness Autocheck

Add to time-sensitive sections:
```
Freshness: YYYY-MM-DD; Re-check: <link/command>
```

### Decision Log & ADR

End major docs with:

| Decision | Rationale | Alternatives | Date | DRI |
|----------|-----------|-------------|------|-----|
| [What] | [Why] | [What rejected] | YYYY-MM-DD | [Owner] |

If technical, link/create an ADR.

### Security & Privacy Mini-Check

For any auth/data-handling code:
- authN/authZ path
- PII flow
- Token scopes
- Log redaction
- Least privilege
- MCP/tool sandboxing
- Blast radius
- Observability

### Synthesis Provenance (Strict)

**Placement:** Always end synthesis docs with dedicated `Sources & Provenance` section

**Critical facts only:** Attach provenance to:
1. Decision-driving metrics
2. Architectural/strategic decisions and rationale
3. Compliance/security requirements
4. API contracts and integration points
5. Contradictions or unresolved questions

**Skip:** Obvious, low-risk background

**Table format:**

| Title | Type | Owner | Last Updated | Link | Hop | Maps to Section(s) |
|-------|------|-------|--------------|------|-----|-------------------|
| [Doc] | PRD/ADR/Code/Wiki | [Name] | YYYY-MM-DD | [URL] | 0/1/2 | [Section] |

Group by target section.

### No AI Slop Safeguards

- Traceability to sources
- Reproduction notes (how to re-generate)
- Disciplined diffs grouped by intent
- Never generate extremely long hashes or binary
- NEVER use placeholders or guess missing parameters

---

## Document Templates

### PRD (Conventional) — Acceptance Criteria

- Problem statement
- Goals/Non-goals
- Users & JTBD (Jobs to Be Done)
- Functional & Non-functional requirements
- Milestones
- Testable acceptance criteria
- Analytics/metrics
- Dependencies/assumptions table

### Builder Brief/PRD — Acceptance Criteria

- Hypothesis
- MVP Scope
- Guardrails
- Prototype plan
- Evals & success metrics
- Rollback strategy
- Gate 0/1/2 explicitly called

### Runbook/Playbook — Acceptance Criteria

- Scope
- Triggers
- On-call matrix
- Ordered procedures with verification steps
- Rollback
- SLIs/SLOs
- Known issues
- Time budget
- Commands in code blocks
- Config via env vars
- Dry-run mode where available

### Synthesis Output Contract (Lossless Distillation)

**Format:**
1. Executive Summary (clean, no citations)
2. Main body sections (lucid narrative, comprehensive coverage)
3. Decision Log (decisions, rationale, alternatives, date, DRI)
4. Gaps & TODOs
5. Next Actions (DRI, date)
6. **Sources & Provenance** (dedicated final section, critical facts only)

**Completeness Check:** Before finalizing, verify all source documents' critical sections have coverage. If contradictions exist between sources, call them out in Gaps/TODOs and provide provenance for each conflicting claim.

### Repository Synthesis Checklist

- Map purpose; top packages/modules/services; entrypoints; envs
- Inspect README, ADR/, docs/, openapi.*, schema.*, CI config, CODEOWNERS, tests
- Identify risks: secrets/credentials patterns, deprecated libs, missing tests/e2e, flaky CI, unpinned deps
- Output Repo Map (component, responsibility, deps, risks, owners) + Decision Log
- **Lossless distillation:** Preserve configuration values, API endpoints, data schemas, integration contracts, version constraints, architectural decisions
- Main body = clean technical narrative
- `Sources & Provenance` = file paths, commit SHAs, config locations (critical items only)

---

## Tool Calling Best Practices

### Parallel Tool Calls

If multiple independent actions needed, make all tool calls in the same batch (don't wait for one to complete before starting the next).

### Prefer Specialized Tools

Use Cursor's built-in tools over terminal commands when possible:
- `read_file` instead of `cat`
- `search_replace` instead of `sed`
- `grep` tool instead of terminal grep

---

## Customization Guide

This template is a starting point. Customize these sections for your team:

1. **Tech Stack Philosophy:** Add your preferred frameworks, libraries, deployment targets
2. **Git Workflow:** Adjust branch naming, merge strategy (squash vs merge commits)
3. **Code Style:** Add language-specific linters, formatters, naming conventions
4. **Testing Policy:** Adjust coverage thresholds, test framework preferences
5. **Deployment Policy:** Add CI/CD patterns, staging environments, approval requirements
6. **Documentation Templates:** Add team-specific sections (API docs, compliance, etc.)

---

**Last Updated:** 2026-01-06

