---
name: plan-review-gate
description: Reviews a PLAN.md (or any plan doc) for concreteness and completeness before coding starts. Checks that tasks are specific enough to implement without guessing, requirements are covered, and acceptance criteria are testable. Use when user says "review my plan", "is this plan ready?", "check my plan before we build", or "plan review".
---

# Plan Review Gate

**Purpose:** Catch vague, incomplete, or untestable plans before a build session starts — when fixing the plan is cheap, not mid-build when it's expensive.

**Not a code review.** This reviews the plan document only. Run it before writing any code.

---

## When to Use

- Before starting any build session
- After updating PLAN.md with new milestones or scope
- When handing a plan to another agent or collaborator
- User says "review my plan", "is this plan ready?", "plan review", "check my plan before we build"

---

## What to Review

User provides either:
- `@PLAN.md` — the project plan file
- A specific section or milestone description
- Any planning document (Builder Brief, PRD, milestone list)

If no file is specified, look for `PLAN.md` in the current project root.

---

## Review Checklist

For each task or milestone in the plan, check:

### 1. Specificity
- [ ] Are file paths exact? ("create `src/components/PriceCard.tsx`" not "create a component")
- [ ] Are actions concrete? ("add Prisma schema for `Operation` table" not "set up the database")
- [ ] Could an engineer start immediately with no follow-up questions?

### 2. Completeness
- [ ] Do the tasks cover all stated goals and requirements?
- [ ] Are dependencies between tasks noted?
- [ ] Is there a clear "done" state for each milestone?

### 3. Testability
- [ ] Does each milestone have a verifiable acceptance criterion?
- [ ] Is there a way to confirm it's working without relying on "it feels right"?
- [ ] Are test commands or verification steps mentioned where needed?

### 4. Scope Hygiene
- [ ] No tasks marked "TBD" or "figure out later"
- [ ] No open questions that would block implementation
- [ ] No tasks that are really multiple tasks collapsed into one

---

## Output Format

```markdown
## Plan Review — [filename or milestone name]

**Verdict:** ✅ Approved | ❌ Issues Found

---

### Issues (if any)

| # | Location | Issue | Why It Matters | Suggested Fix |
|---|----------|-------|---------------|---------------|
| 1 | Milestone 2, Task 3 | "Set up auth" — no file paths or library specified | Implementer will have to guess; leads to inconsistency | Specify: "Add NextAuth.js config in `app/api/auth/[...nextauth]/route.ts`" |

---

### Summary

[2–3 sentences: overall quality of the plan, what's strong, what's missing]

**Recommended action:** [Approve and start building / Revise X items first / Major rework needed]
```

---

## Verdict Criteria

| Verdict | Criteria |
|---------|----------|
| ✅ **Approved** | All tasks are concrete, completeness looks solid, acceptance criteria exist |
| ⚠️ **Minor Issues** | 1–3 small gaps; safe to start building with noted caveats |
| ❌ **Issues Found** | Vague tasks, missing acceptance criteria, or open questions that would block implementation |

**Only flag real blockers.** Style preferences and minor wording don't block approval. The test: "Would an engineer get stuck or go in the wrong direction without this being clearer?"

---

## Example

**Vague task (flags as issue):**
> "Implement the pricing logic"

Issue: No file path, no data source specified, no acceptance criterion. An engineer has to make multiple guesses.

**Concrete task (passes):**
> "Add `calculatePrice()` in `lib/pricing.ts` — takes `operationId` + `quantity`, looks up rate from `rate_cards` table, returns `{ unitPrice, total }`. Test: `calculatePrice('op_123', 10)` returns correct total based on seed data."

---

## Integration with Workflow

This skill is the gate between `PLAN.md` and your first build session.

**Typical flow:**
1. Create or update `PLAN.md` (use `requirement-agent` or `create-project`)
2. Run `plan-review-gate` → get Approved or Issues Found
3. If issues: revise PLAN.md, re-run until Approved
4. Start build session with confidence

**After approval:** Update `BUILD_LOG.md` with "Plan approved [date], starting build."
