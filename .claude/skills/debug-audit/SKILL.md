---
name: debug-audit
description: Performs comprehensive project debugging audit for bugs, performance, and accessibility issues. Use when user asks for debug audit, code review, comprehensive project scan, or mentions finding bugs, performance issues, or accessibility problems.
---

# Debug Audit

Automated debugging audit that identifies bugs, performance bottlenecks, and accessibility issues, then auto-fixes high-confidence problems.

## When to Use

- User requests a project audit or code review
- User mentions bugs, performance issues, or accessibility problems
- Before deployment or major release
- After significant refactoring

## Path Scoping (CRITICAL)

**Always scope file operations to the explicitly specified project directory.**

When user says "@debug-audit on [project-name]", audit ONLY files within:
- `<WORKSPACE_PATH>/[project-name]/` (or relative equivalent)

**Explicitly EXCLUDE:**
- Workspace-level folders that aren't part of the target project
- Cloned reference repositories (e.g., `Production_Clones/`)
- Documentation-only folders
- Symlinked directories that may create duplicate paths
- Any path outside the target project directory

**Why:** Workspace may contain symlinks or duplicate directories that create "ghost files" if not excluded.

## Audit Scope

### 1. Bugs & Issues (Critical Priority)
- Runtime errors, unhandled exceptions
- Logic errors, incorrect conditionals
- Null/undefined reference risks
- Race conditions, async issues
- Memory leaks, broken imports
- Type mismatches, API contract violations

### 2. Optimization (High Priority)
- Performance bottlenecks (N+1 queries, unnecessary re-renders)
- Inefficient algorithms, redundant/dead code
- Missing memoization, unoptimized queries
- Bundle size bloat, missing lazy loading

### 3. Accessibility (High Priority)
- Color contrast (WCAG AA: 4.5:1 text, 3:1 UI)
- Missing alt text, ARIA labels
- Keyboard navigation gaps, focus indicators
- Missing semantic HTML, form labels

For detailed checklists, see [references/](references/).

## Output Format

For each issue found:

| Field | Description |
|-------|-------------|
| **File** | Path to affected file |
| **Line(s)** | Line number(s) |
| **Category** | Bug / Optimization / Accessibility |
| **Severity** | Critical / High / Medium / Low |
| **Issue** | Clear description |
| **Confidence** | High / Medium / Low |
| **Fix** | Proposed solution |

## Action Rules

### ✅ AUTO-FIX (High Confidence)
Apply immediately when:
- Fix is straightforward and well-understood
- No risk of breaking existing functionality
- Issue is clearly a bug (not design decision)
- Examples: typos, missing null checks, obvious type errors, missing alt text

### ⚠️ REPORT ONLY (Medium/Low Confidence)
Do NOT auto-fix when:
- Change could affect business logic
- Multiple valid solutions exist
- Requires understanding of user intent
- Could break dependent code
- Involves architectural decisions

## Execution Phases

### Phase 0: Pre-Flight Compilation (CRITICAL - Run First)

**Rule:** Code must compile before it can be analyzed. Stop if compilation fails.

1. Scope audit to target project directory only
2. Run compilation checks:

```bash
# Use the compile-check script
./scripts/compile-check.sh
```

Or manually:

**TypeScript/JavaScript:**
```bash
npx tsc --noEmit
npm run lint
```

**Python:**
```bash
find . -name "*.py" -not -path "./node_modules/*" -not -path "./.venv/*" \
  -exec python3 -m py_compile {} \;
```

**If compilation fails:** Fix syntax/import errors before proceeding.

### Phase 1: Static Analysis

3. Read source files (src/, app/, components/, lib/, pages/)
4. Check configuration files (package.json, tsconfig, eslint, tailwind)
5. Analyze styles for accessibility
6. Review API routes and data fetching

### Phase 2: Test Validation

7. Check test coverage gaps
8. Run E2E tests (verify they exercise modified code paths)
9. Run unit tests

### Phase 3: Reporting

10. Generate report and apply high-confidence fixes
11. Identify and delete unused files (see [UNUSED_FILES.md](references/UNUSED_FILES.md))

## Confidence Calibration

### Zero Tolerance (Fix Immediately)
- Syntax errors
- Import errors
- Compilation failures

**Rule:** If code doesn't compile, stop and fix immediately.

### High Confidence (Auto-Fix)
- Missing null checks on obviously nullable values
- Unused imports/variables
- Missing TypeScript types (simple cases)
- Missing alt="" on decorative images
- Obvious typos

### Medium Confidence (Report + Suggest)
- Performance optimizations that change behavior
- Refactoring suggestions
- Accessibility improvements requiring design input

### Low Confidence (Report Only)
- Architectural changes
- Business logic modifications
- Trade-offs between competing concerns

## Deliverables

1. **Summary Table** — All issues, grouped by category
2. **Auto-Fixed** — Changes already applied (with file paths)
3. **Pending Review** — Issues requiring human decision
4. **Recommendations** — Improvements beyond scope
5. **Unused Files Deleted** — Files removed (excluding documentation)

## Example Output

### Summary

| # | File | Category | Severity | Issue | Status |
|---|------|----------|----------|-------|--------|
| 1 | `src/components/Button.tsx` | Accessibility | High | Missing aria-label | ✅ Fixed |
| 2 | `src/lib/api.ts` | Bug | Critical | Unhandled fetch rejection | ✅ Fixed |
| 3 | `src/pages/index.tsx` | Optimization | Medium | Large component not memoized | ⚠️ Review |

### Auto-Fixed Changes

```
✅ src/components/Button.tsx:15 — Added aria-label="Submit form"
✅ src/lib/api.ts:23 — Added .catch() handler for fetch
```

### Pending Human Review

```
⚠️ src/pages/index.tsx:45
   Issue: HeroSection re-renders on every parent render
   Suggestion: Wrap with React.memo()
   Reason: May affect intentional re-render behavior
```

## Quick Usage

**Full audit:**
```
Run full debug audit on this project
```

**Targeted:**
```
Focus on accessibility issues only
```

```
Audit only the /src/components folder
```

## Key Principle

**"Code must compile before it can be analyzed."**

Testing Pyramid for Hybrid Apps:
```
        /\
       /  \  E2E Tests (user journeys)
      /----\
     / Unit \  Function-level logic
    /--------\
   / Compile  \  Syntax + Import checks
   \  FIRST   /  MUST PASS FIRST
    \--------/
```

## References

- [ACCESSIBILITY.md](references/ACCESSIBILITY.md) — WCAG 2.1 AA checklist
- [BUG_PATTERNS.md](references/BUG_PATTERNS.md) — Common bug patterns and test coverage gaps
- [PERFORMANCE.md](references/PERFORMANCE.md) — Performance red flags
- [UNUSED_FILES.md](references/UNUSED_FILES.md) — File cleanup rules
