# Common Code Patterns to Detect and Fix

## Pattern 1: Missing Error Handling

**Before:**
```typescript
const data = await fetch('/api/users');
const users = await data.json();
```

**After:**
```typescript
try {
  const data = await fetch('/api/users');
  if (!data.ok) throw new Error(`API error: ${data.status}`);
  const users = await data.json();
} catch (error) {
  console.error('Failed to fetch users:', error);
  // Handle error appropriately
}
```

## Pattern 2: Race Condition

**Before:**
```typescript
const [count, setCount] = useState(0);
useEffect(() => {
  fetchData().then(data => setCount(data.length));
}, []);
```

**After:**
```typescript
const [count, setCount] = useState(0);
useEffect(() => {
  let cancelled = false;
  fetchData().then(data => {
    if (!cancelled) setCount(data.length);
  });
  return () => { cancelled = true; };
}, []);
```

## Pattern 3: Missing Integration

**Before:**
```typescript
// Component expects API call but doesn't make it
function UserList() {
  const [users, setUsers] = useState([]);
  // Missing: fetch users from API
  return <div>{users.map(...)}</div>;
}
```

**After:**
```typescript
function UserList() {
  const [users, setUsers] = useState([]);
  
  useEffect(() => {
    fetch('/api/users')
      .then(res => res.json())
      .then(setUsers)
      .catch(err => console.error('Failed to fetch users:', err));
  }, []);
  
  return <div>{users.map(...)}</div>;
}
```

## Pattern 4: State Mutation

**Before:**
```typescript
const [items, setItems] = useState([]);
const addItem = (item) => {
  items.push(item); // ❌ Direct mutation
  setItems(items);
};
```

**After:**
```typescript
const [items, setItems] = useState([]);
const addItem = (item) => {
  setItems([...items, item]); // ✅ New array
};
```
