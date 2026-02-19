# Common Pitfalls to Avoid

Critical mistakes to avoid when auto-fixing code.

## 🚨 Critical Pitfalls (Will Break Code)

### Pitfall 1: Adding `await` to Non-Async Functions

**❌ Wrong:**
```typescript
// Function is not async
const result = await syncFunction(); // ❌ BREAKS: syncFunction is not async
```

**✅ Correct:**
```typescript
// Check if function is async first
const result = syncFunction(); // ✅ Correct, no await needed
```

**Detection Rule:** Always check function signature before adding `await`.

### Pitfall 2: Adding `await` in useEffect (Cannot Be Async)

**❌ Wrong:**
```typescript
useEffect(() => {
  await fetchData(); // ❌ BREAKS: useEffect callback cannot be async
}, []);
```

**✅ Correct:**
```typescript
useEffect(() => {
  fetchData().then(data => {
    // Handle data
  });
}, []);
// OR
useEffect(() => {
  (async () => {
    const data = await fetchData();
    // Handle data
  })();
}, []);
```

**Detection Rule:** Never add `await` directly in useEffect callback.

### Pitfall 3: Adding Dependencies That Cause Infinite Loops

**❌ Wrong:**
```typescript
useEffect(() => {
  fetchData({ filter: 'active' }); // Object literal recreated every render
}, [{ filter: 'active' }]); // ❌ INFINITE LOOP: new object every render
```

**✅ Correct:**
```typescript
// Use stable value or memoize
const filter = useMemo(() => ({ filter: 'active' }), []);
useEffect(() => {
  fetchData(filter);
}, [filter]); // ✅ Safe: filter is memoized
```

**Detection Rule:** Check if dependency is object/array literal before adding to deps.

### Pitfall 4: Masking Real Bugs with Generic Error Handling

**❌ Wrong:**
```typescript
// Generic catch hides the real issue
try {
  const user = users.find(u => u.id === userId);
  const name = user.name; // ❌ user might be undefined
} catch (error) {
  console.error('Error'); // ❌ Masks the real bug
}
```

**✅ Correct:**
```typescript
// Fix the root cause, not mask it
const user = users.find(u => u.id === userId);
if (!user) {
  throw new Error(`User ${userId} not found`);
}
const name = user.name; // ✅ Safe: user is guaranteed to exist
```

**Detection Rule:** Don't add generic try-catch that masks real bugs. Fix root cause.

### Pitfall 5: Breaking Intentional Patterns

**❌ Wrong:**
```typescript
// Code has intentional comment - don't "fix" it
// Fire and forget - allow null
fireAnalyticsEvent(user?.id); // ✅ Intentional, skip fix
// CodeFix incorrectly "fixes" to: await fireAnalyticsEvent(user?.id);
```

**✅ Correct:**
```typescript
// Respect intentional patterns
// Fire and forget - allow null
fireAnalyticsEvent(user?.id); // ✅ Skip fix, pattern is intentional
```

**Detection Rule:** Check for comments explaining intentional patterns before fixing.

## ⚠️ Medium-Risk Pitfalls (May Break Code)

### Pitfall 6: Changing Function Signatures

**❌ Wrong:**
```typescript
// Fixing "missing error handling" changes return type
function fetchUser(id: string) {
  return fetch(`/api/users/${id}`).then(r => r.json());
}
// CodeFix adds try-catch, but changes return type to Promise<User | null>
```

**✅ Correct:**
```typescript
// Preserve return type, handle errors appropriately
async function fetchUser(id: string): Promise<User> {
  try {
    const res = await fetch(`/api/users/${id}`);
    if (!res.ok) throw new Error(`Failed to fetch user: ${res.status}`);
    return await res.json();
  } catch (error) {
    // Handle error without changing return type
    throw error; // Or return default value if function signature allows
  }
}
```

**Detection Rule:** Don't change function signatures when adding error handling.

### Pitfall 7: Over-Optimizing with Optional Chaining

**❌ Wrong:**
```typescript
// Already safe, don't add unnecessary optional chaining
if (user && user.profile) {
  const name = user?.profile?.name; // ❌ Redundant, already guarded
}
```

**✅ Correct:**
```typescript
// Keep existing guard, don't add redundant optional chaining
if (user && user.profile) {
  const name = user.profile.name; // ✅ Safe, guard already exists
}
```

**Detection Rule:** Check for existing guards before adding optional chaining.

## 📋 Best Practices to Follow

1. **Always verify context** before fixing (check parent scope, comments, function signatures)
2. **Preserve function signatures** when adding error handling
3. **Respect intentional patterns** (check for comments explaining why code is written a certain way)
4. **Test after each fix** (incremental verification prevents cascading failures)
5. **Rollback immediately** if verification fails (don't try to fix the fix)
6. **Document why** each fix was made (provenance tracking helps debugging)

## Common Pattern Examples

### Pattern 1: Context-Aware Null Check

**❌ False Positive (Don't Fix)**:
```typescript
// Already guarded - don't add optional chaining
if (user) {
  const name = user.profile.name; // ✅ Safe, already checked
}

// Early return guard - don't fix
if (!user) return;
const name = user.profile.name; // ✅ Safe, early return protects this

// Intentional pattern - don't fix
// Fire and forget - allow null
fireAnalyticsEvent(user?.id); // ✅ Intentional, skip fix
```

**✅ True Positive (Fix with Verification)**:
```typescript
// No guard - fix this
const name = user.profile.name; // ❌ Unsafe, fix to:
const name = user?.profile?.name; // ✅ Safe
```

### Pattern 2: Context-Aware Async/Await

**❌ False Positive (Don't Fix)**:
```typescript
// Fire and forget - intentional
useEffect(() => {
  fireAnalyticsEvent(); // ✅ Intentional, no await needed
}, []);

// Non-async function - don't add await
const result = syncFunction(); // ✅ Not async, skip fix
```

**✅ True Positive (Fix with Verification)**:
```typescript
// Missing await on async function
const data = fetchData(); // ❌ Should be awaited, fix to:
const data = await fetchData(); // ✅ Correct
```

### Pattern 3: Context-Aware useEffect Dependencies

**❌ False Positive (Don't Fix)**:
```typescript
// Intentional empty deps - don't fix
useEffect(() => {
  // eslint-disable-next-line react-hooks/exhaustive-deps
  fetchData(); // ✅ Intentional, skip fix
}, []);

// Object literal - might cause loop, report only
useEffect(() => {
  fetchData({ filter: 'active' }); // ⚠️ Report only, don't auto-fix
}, []); // Adding { filter: 'active' } would cause infinite loop
```

**✅ True Positive (Fix with Verification)**:
```typescript
// Safe primitive dependency - fix this
const [userId, setUserId] = useState(0);
useEffect(() => {
  fetchUser(userId); // ✅ Safe to add userId to deps
}, []); // ❌ Missing userId, fix to: }, [userId]);
```
