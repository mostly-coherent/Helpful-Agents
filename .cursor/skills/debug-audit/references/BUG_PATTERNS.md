# Bug Patterns Reference

## Common Bug Patterns

| Pattern | Example | Fix |
|---------|---------|-----|
| **Unhandled Promise** | `fetch()` without `.catch()` | Add error handling |
| **Optional Chaining Missing** | `user.profile.name` | `user?.profile?.name` |
| **State Mutation** | `array.push()` in React state | `[...array, newItem]` |
| **useEffect Deps** | Missing dependencies in array | Add all dependencies |
| **Key Prop Missing** | Lists without unique `key` | Add stable `key` |
| **Event Handler Binding** | Arrow function in render | Move to component level |
| **Stale Closure** | useState value in setTimeout | Use ref or functional update |
| **Race Condition** | Multiple async calls without cleanup | Use AbortController |

## Detailed Patterns

### Unhandled Promise Rejection

```typescript
// ❌ Bad
const data = await fetch('/api/data');

// ✅ Good
try {
  const data = await fetch('/api/data');
} catch (error) {
  console.error('Fetch failed:', error);
  // Handle error appropriately
}
```

### React State Mutation

```typescript
// ❌ Bad - mutates state directly
const addItem = (item) => {
  items.push(item);
  setItems(items);
};

// ✅ Good - creates new array
const addItem = (item) => {
  setItems([...items, item]);
};
```

### useEffect Missing Dependencies

```typescript
// ❌ Bad - missing userId dependency
useEffect(() => {
  fetchUser(userId);
}, []);

// ✅ Good - all dependencies listed
useEffect(() => {
  fetchUser(userId);
}, [userId]);
```

### Stale Closure

```typescript
// ❌ Bad - count is stale
const handleClick = () => {
  setTimeout(() => {
    console.log(count); // Always logs initial value
  }, 1000);
};

// ✅ Good - use ref for latest value
const countRef = useRef(count);
countRef.current = count;

const handleClick = () => {
  setTimeout(() => {
    console.log(countRef.current);
  }, 1000);
};
```

## Test Coverage Reality Check

### What Each Test Type Catches

| Test Type | Catches | Misses |
|-----------|---------|--------|
| **E2E (Playwright)** | UI flows, integration paths, user journeys | Syntax errors in unexercised code, backend logic not called |
| **Unit Tests** | Function-level logic, edge cases | Integration issues, UI bugs, E2E flows |
| **Linters** | Style issues, common patterns | Syntax errors (if not configured), logic errors |
| **TypeScript** | Type errors, interface mismatches | Runtime errors, business logic, Python errors |

### The "Tests Passing" Trap

**Scenario:** Modified Python backend file → 26 Playwright tests pass → App crashes on first real use

**Why tests passed:**
- Tests mock backend responses
- Tests only exercise frontend
- Modified code path not covered
- Syntax error in module that tests don't import

**Solution:** Always run backend smoke tests independently of E2E tests.

### Smoke Test Checklist

For any backend changes (Python, Node.js API routes):

- [ ] Run syntax check: `python3 -m py_compile <modified_file>`
- [ ] Try importing the module: `python3 -c "from module import Class"`
- [ ] Run dry-run test if available: `python3 script.py --dry-run`
- [ ] Run unit tests for that module: `pytest tests/test_module.py`
- [ ] THEN run E2E tests

**Never assume "tests passing" means "code works"** without verifying the specific code path was exercised.

## TypeScript-Specific Bugs

| Pattern | Issue | Fix |
|---------|-------|-----|
| **Type assertion abuse** | `as any` hides errors | Use proper types or type guards |
| **Missing return type** | Implicit `any` return | Add explicit return type |
| **Non-null assertion** | `value!` bypasses checks | Use proper null handling |
| **Index signature** | `obj[key]` returns `any` | Define proper index type |

## Async/Await Bugs

| Pattern | Issue | Fix |
|---------|-------|-----|
| **Forgotten await** | `const x = asyncFn()` returns Promise | Add `await` |
| **Parallel vs Sequential** | Unintentional sequential calls | Use `Promise.all()` |
| **Error swallowing** | Empty catch block | Log or handle error |
| **Missing cleanup** | No abort on unmount | Return cleanup function |
