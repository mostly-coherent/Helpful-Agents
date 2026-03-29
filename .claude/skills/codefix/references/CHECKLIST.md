# Complete Review Checklist

Detailed checklist for all 22 review categories.

## Critical Issues (Fix Immediately)

### 1. Syntax & Compilation Errors

| Check | Examples |
|-------|----------|
| Syntax Errors | Missing brackets, semicolons, typos in keywords |
| Type Errors | TypeScript type mismatches, missing types |
| Import Errors | Missing imports, circular dependencies, wrong paths |
| Compilation Failures | Code that doesn't compile/build |

### 2. Logic Bugs & Edge Cases

| Check | Examples |
|-------|----------|
| Null/Undefined Access | `obj.property` without null check → `obj?.property` |
| Array Bounds | Accessing `array[index]` without length check |
| Division by Zero | `value / divisor` without checking divisor |
| Off-by-One Errors | Loop boundaries, array indexing |
| Incorrect Conditionals | Wrong comparison operators (`=` vs `===`), inverted logic |
| Missing Default Cases | Switch statements without default, missing else clauses |
| Uninitialized Variables | Using variables before assignment |

### 3. Race Conditions & Async Issues

| Check | Examples |
|-------|----------|
| Unhandled Promises | `fetch()` without `.catch()` or `await` |
| Race Conditions | Multiple async operations modifying shared state |
| Missing Await | Forgetting `await` on async function calls |
| Promise Chains | `.then()` chains without error handling |
| State Updates After Unmount | React state updates after component unmounts |
| Stale Closures | Using old values in async callbacks |
| Concurrent Modifications | Multiple operations modifying same resource without locks |

### 4. Error Handling & Resilience

| Check | Examples |
|-------|----------|
| Missing Try-Catch | Operations that can throw without error handling |
| Silent Failures | Errors caught but not logged or handled |
| Generic Error Messages | Unhelpful error messages without context |
| Missing Validation | User input not validated before processing |
| API Error Handling | API calls without error handling or retry logic |
| Resource Cleanup | File handles, connections not closed in finally blocks |

## High Priority Issues

### 5. Integration & API Issues

| Check | Examples |
|-------|----------|
| Missing API Calls | Features that require API calls but don't make them |
| Wrong Endpoints | Incorrect API URLs or paths |
| Missing Headers | API calls without required auth headers |
| Response Parsing | Not parsing JSON responses, assuming response format |
| Missing Error Responses | Not handling API error status codes (4xx, 5xx) |
| Database Queries | SQL/ORM queries without error handling |
| Missing Transactions | Multi-step operations without transaction handling |

### 6. React/Next.js Specific Issues

| Check | Examples |
|-------|----------|
| Missing Dependencies | `useEffect` dependencies array incomplete |
| State Mutation | Direct mutation of state (`array.push()` instead of new array) |
| Missing Keys | Lists without unique `key` prop |
| Infinite Loops | `useEffect` causing infinite re-renders |
| Server/Client Mismatch | Using browser APIs in Server Components |
| Hydration Errors | Mismatch between server and client rendering |
| Missing Loading States | Async operations without loading indicators |
| Memory Leaks | Event listeners, subscriptions not cleaned up |

### 7. Type Safety & TypeScript Issues

| Check | Examples |
|-------|----------|
| Missing Types | `any` types, untyped function parameters |
| Type Assertions | Unsafe `as` casts without validation |
| Interface Mismatches | Objects not matching declared interfaces |
| Generic Constraints | Missing constraints on generic types |
| Optional Chaining | Not using `?.` for potentially undefined properties |

### 8. Security Issues

| Check | Examples |
|-------|----------|
| XSS Vulnerabilities | Rendering user input without sanitization |
| SQL Injection | Raw SQL queries with user input |
| Exposed Secrets | API keys, tokens in client-side code |
| Missing CSRF Protection | Forms without CSRF tokens |
| Insecure Dependencies | Using packages with known vulnerabilities |

## Medium Priority Issues

### 9. Performance Issues

| Check | Examples |
|-------|----------|
| N+1 Queries | Database queries inside loops |
| Unnecessary Re-renders | Object/array literals in props causing re-renders |
| Missing Memoization | Expensive computations without `useMemo`/`useCallback` |
| Large Bundle Imports | Importing entire libraries instead of specific functions |
| Blocking Operations | Synchronous operations blocking main thread |

### 10. Code Quality & Best Practices

| Check | Examples |
|-------|----------|
| Dead Code | Unused functions, variables, imports |
| Code Duplication | Repeated logic that should be extracted |
| Magic Numbers | Hardcoded values without constants |
| Long Functions | Functions exceeding reasonable length |
| Poor Naming | Unclear variable/function names |
| Missing Comments | Complex logic without explanation |

## Expert Level (PM UAT Readiness)

### 11. Test Coverage & UAT Readiness

| Check | Examples |
|-------|----------|
| Missing Tests | No tests for new functionality |
| Happy Path Only | Tests only cover success scenarios |
| Missing Edge Cases | No tests for empty data, null values, boundary conditions |
| Missing Error Path Tests | No tests for error scenarios, API failures |
| Incomplete Coverage | Critical paths not tested |
| Test Quality | Tests that don't actually verify behavior |

**PM UAT Readiness Checklist:**
- ✅ Happy path works (basic functionality)
- ✅ Error states handled gracefully (user-friendly messages)
- ✅ Loading states present (users know something is happening)
- ✅ Empty states handled (no data scenarios)
- ✅ Success feedback provided (confirmation of actions)
- ✅ Edge cases tested (boundary conditions, null values)
- ✅ Validation works (invalid input rejected with clear messages)

### 12. User Experience Completeness

| Check | Examples |
|-------|----------|
| Missing Loading States | Async operations without loading indicators |
| Missing Error States | Errors shown as blank screens or console errors |
| Missing Empty States | No data scenarios show broken UI |
| Missing Success Feedback | Actions complete silently without confirmation |
| Poor Error Messages | Technical error messages shown to users |
| Missing Validation Feedback | Invalid input not clearly marked |
| Accessibility Gaps | Missing ARIA labels, keyboard navigation issues |

**UX Checklist:**
- ✅ Loading: Spinner, skeleton, or progress indicator
- ✅ Error: User-friendly message with actionable next steps
- ✅ Empty: Helpful message explaining why (no data, filtered out, etc.)
- ✅ Success: Confirmation toast, success message, or visual feedback
- ✅ Validation: Inline errors, clear field highlighting, helpful hints

### 13. Edge Cases & Boundary Conditions

| Check | Examples |
|-------|----------|
| Zero/Length Checks | Empty arrays, empty strings, zero values |
| Null/Undefined Handling | Missing data, optional fields |
| Boundary Values | Min/max values, array limits, pagination edges |
| Concurrent Actions | Multiple rapid clicks, double submissions |
| Network Failures | Offline scenarios, timeout handling |
| Large Data Sets | Performance with 1000+ items |
| Special Characters | Unicode, emojis, SQL injection attempts |
| Date/Time Edge Cases | Timezone issues, leap years, DST transitions |

### 14. Data Validation & Sanitization

| Check | Examples |
|-------|----------|
| Missing Input Validation | User input not validated before processing |
| Client-Only Validation | No server-side validation (can be bypassed) |
| Insufficient Validation | Only checking format, not business rules |
| Missing Sanitization | User input rendered without escaping |
| Type Validation | Not checking data types (string vs number) |
| Range Validation | Not checking min/max values |
| Format Validation | Email, phone, date formats not validated |

### 15. Observability & Debugging

| Check | Examples |
|-------|----------|
| Missing Logging | No logs for critical operations |
| Poor Log Quality | Logs without context, timestamps, or request IDs |
| Missing Error Tracking | Errors not sent to error tracking service |
| Missing Metrics | No performance or business metrics |
| Missing Request Tracing | Can't trace requests across services |
| Sensitive Data in Logs | Passwords, tokens, PII logged |

**Observability Checklist:**
- ✅ Critical operations logged (with context)
- ✅ Errors tracked (with stack traces and context)
- ✅ Performance metrics (response times, query times)
- ✅ User actions tracked (for debugging user issues)
- ✅ Request IDs for tracing (correlate logs across services)

### 16. Backward Compatibility & Migration Safety

| Check | Examples |
|-------|----------|
| Breaking Changes | API changes breaking existing clients |
| Data Migration Issues | Database migrations without rollback plan |
| Missing Versioning | API changes without versioning |
| Schema Changes | Database schema changes breaking existing data |
| Config Changes | Environment variable changes breaking deployments |
| Dependency Updates | Package updates with breaking changes |

### 17. Feature Flags & Rollback Readiness

| Check | Examples |
|-------|----------|
| Risky Changes Without Flags | Major changes not behind feature flags |
| Missing Rollback Plan | No way to disable feature if issues arise |
| Hardcoded Feature State | Can't toggle features without code changes |
| Missing Gradual Rollout | All-or-nothing deployments |

**For Risky Changes:**
- ✅ Feature flag to enable/disable
- ✅ Gradual rollout (percentage of users)
- ✅ Easy rollback (disable flag, revert code)
- ✅ Monitoring before full rollout

### 18. Documentation & Code Comments

| Check | Examples |
|-------|----------|
| Missing Code Comments | Complex logic without explanation |
| Missing API Documentation | New endpoints not documented |
| Missing Changelog | Changes not logged for PM/release notes |
| Outdated Comments | Comments don't match code |
| Missing README Updates | New features not documented in README |
| Missing Type Documentation | Complex types without JSDoc/TSDoc |

### 19. Integration Completeness

| Check | Examples |
|-------|----------|
| Incomplete Integrations | Partial API integration (missing endpoints) |
| Missing Webhooks | Events not propagated to external systems |
| Missing Sync Logic | Data not synced between systems |
| Missing Retry Logic | Failed API calls not retried |
| Missing Circuit Breakers | No protection against cascading failures |
| Missing Rate Limiting | No protection against API abuse |

### 20. State Management & Data Consistency

| Check | Examples |
|-------|----------|
| Stale State | UI showing outdated data |
| State Synchronization | Multiple sources of truth |
| Missing Cache Invalidation | Cached data not invalidated on updates |
| Race Conditions in State | Concurrent updates causing inconsistencies |
| Missing Optimistic Updates | UI not updated optimistically |
| Transaction Safety | Multi-step operations not atomic |

### 21. Performance Under Load

| Check | Examples |
|-------|----------|
| Missing Pagination | Loading all data at once |
| Missing Debouncing | Rapid user input causing excessive API calls |
| Missing Caching | Repeated expensive operations not cached |
| Missing Lazy Loading | Loading unnecessary data upfront |
| Missing Compression | Large payloads not compressed |
| Missing CDN | Static assets not served from CDN |
| Missing Database Indexes | Slow queries without indexes |

### 22. Security Hardening

| Check | Examples |
|-------|----------|
| Missing Authorization Checks | Not verifying user permissions |
| Missing Rate Limiting | No protection against abuse |
| Missing Input Sanitization | XSS vulnerabilities |
| Missing CSRF Protection | Forms vulnerable to CSRF attacks |
| Missing HTTPS | Sensitive data over HTTP |
| Missing Secure Headers | Missing security headers (CSP, HSTS, etc.) |
| Exposed Sensitive Data | API keys, tokens in client code |
