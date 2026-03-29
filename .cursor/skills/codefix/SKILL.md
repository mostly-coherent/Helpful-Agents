---
name: codefix
description: Reviews code for bugs, race conditions, missing error handling, type safety issues, and PM UAT readiness. Use when reviewing code written by other agents, checking for bugs, preparing for deployment, or when user mentions code review, bugs, errors, or UAT.
---

# CodeFix

Automated code review and fix for code written by LLMs or coding agents.

## When to Use

- After implementing new features or bug fixes
- Before creating pull requests
- When preparing code for PM UAT review
- When debugging issues in AI-generated code
- When user requests code review or mentions bugs/errors

## Instructions

### Step 1: Load Project Context

Read project configuration files to understand conventions and requirements:

```bash
# Load these files if they exist
.cursorrules
CLAUDE.md
package.json
tsconfig.json
.eslintrc* or eslint.config.*
```

Respect project-specific rules, style guides, and conventions throughout the review.

### Step 2: Check Compilation

Code must compile before proceeding with review:

```bash
npx tsc --noEmit
npm run lint
```

**If compilation fails:** Fix syntax and import errors immediately before any other analysis.

### Step 3: Determine Scope

Based on user's invocation:
- No parameters → Review entire project
- `on [path]` → Review specific file(s) or directory
- `focus on [category]` → Review specific issue category

List files to be reviewed and confirm scope.

### Step 4: Review Against Checklist

Systematically check for issues across these categories:

**Critical (Fix Immediately):**
1. Syntax & compilation errors
2. Logic bugs & edge cases (null access, array bounds, division by zero)
3. Race conditions & async issues (unhandled promises, missing await)
4. Error handling & resilience (missing try-catch, no validation)

**High Priority:**
5. Integration & API issues (missing endpoints, wrong URLs, no error handling)
6. React/Next.js issues (missing dependencies, state mutation, infinite loops)
7. Type safety (missing types, unsafe assertions)
8. Security issues (XSS, SQL injection, exposed secrets)

**Medium Priority:**
9. Performance issues (N+1 queries, unnecessary re-renders)
10. Code quality (dead code, duplication, magic numbers)

**Expert Level (PM UAT Readiness):**
11. Test coverage (happy path + edge cases + error scenarios)
12. User experience completeness (loading/error/empty/success states)
13. Edge cases & boundary conditions
14. Data validation & sanitization
15. Observability & debugging (logging, error tracking)
16. Additional categories (see [CHECKLIST.md](references/CHECKLIST.md) for complete list)

### Step 5: Apply Fixes Incrementally

For each issue found, apply fixes one at a time with immediate verification.

**Always Auto-Fix (Safe):**
- Syntax errors (missing brackets, typos)
- Unused imports/variables
- Missing `key` props in React lists
- Obvious TypeScript type errors

**Auto-Fix with Verification (Test After Each):**
- Missing null checks (`obj.property` → `obj?.property`)
- Missing `await` on async calls
- Missing error handling (add try-catch)
- Missing dependencies in `useEffect`
- Direct state mutations
- Missing `.catch()` on promises

**Before applying fixes, check for context:**
- Is there already a guard (if statement, early return)?
- Is this pattern intentional (check for comments)?
- For `useEffect` deps: Is it an object/array literal that would cause infinite loop?

**Never Auto-Fix (Report Only):**
- Business logic changes
- Architectural decisions
- API/database schema changes
- Changes affecting multiple files
- Complex refactoring

**After each fix:**
```bash
npx tsc --noEmit && npm run lint
```

If verification fails, rollback immediately and report the issue.

### Step 6: Run Tests (If Exist)

```bash
npm test
```

If tests fail after fixes, stop immediately and report which fix broke tests.

### Step 7: Final Verification

Run comprehensive checks:

```bash
# Compilation
npx tsc --noEmit
npm run lint

# Tests (if exist)
npm test

# Runtime check (optional)
npm run dev &
# Check browser console for errors
```

Verify:
- ✅ Compilation passes
- ✅ Tests pass (or equal to baseline)
- ✅ No new console errors
- ✅ Dependent files still work

### Step 8: Assess PM UAT Readiness

Evaluate production readiness:

| Category | Check |
|----------|-------|
| **Test Coverage** | Happy path + edge cases + error scenarios covered? |
| **User Experience** | Loading/error/empty/success states present? |
| **Error Handling** | All errors caught with user-friendly messages? |
| **Performance** | No obvious bottlenecks (pagination, debouncing)? |
| **Security** | Input validation + sanitization in place? |
| **Observability** | Logging and error tracking configured? |

Rate overall readiness: ✅ Ready | ⚠️ Conditional | ❌ Not Ready

## Output Format

**Present results in chat response only. Do NOT create documentation files.**

### Summary Table

| # | File | Line(s) | Category | Severity | Issue | Status |
|---|------|---------|----------|----------|-------|--------|
| 1 | `src/api.ts` | 23 | Race Condition | High | Unhandled promise | ✅ Fixed |

### Auto-Fixed Issues

```
✅ src/api.ts:23 — Added .catch() handler for fetch promise
✅ src/components/List.tsx:15 — Added key={item.id} to list items
```

### Issues Requiring Review

```
⚠️ src/api/users.ts:45
   Issue: API endpoint hardcoded
   Suggestion: Use environment variable
   Reason: May be intentional for development
```

### Verification Results

```
✅ Compilation: PASSED
✅ Type Check: PASSED
✅ Linting: PASSED
✅ Tests: PASSED
✅ Runtime: PASSED
```

### PM UAT Readiness

| Category | Status | Notes |
|----------|--------|-------|
| Test Coverage | ✅ Ready | Happy path + edge cases tested |
| User Experience | ⚠️ Needs Work | Missing empty state |
| Error Handling | ✅ Ready | All errors handled |

**Overall**: ⚠️ Conditional Approval — Address empty state before PM UAT

## Key Principles

1. **Safety First**: All checks must pass before proceeding
2. **Context-Aware**: Check if "bug" is intentional before fixing
3. **Incremental**: Apply one fix at a time, verify immediately
4. **Conservative**: Only auto-fix truly safe issues
5. **Rollback on Failure**: Stop immediately if verification fails
6. **Respect Project Rules**: Follow project conventions

## Additional Resources

- [CHECKLIST.md](references/CHECKLIST.md) - Complete 22-category checklist with examples
- [PITFALLS.md](references/PITFALLS.md) - Common mistakes to avoid when auto-fixing
