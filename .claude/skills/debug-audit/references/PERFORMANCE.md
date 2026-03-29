# Performance Reference

## Red Flags

| Issue | Detection | Impact |
|-------|-----------|--------|
| **N+1 Queries** | Database call inside a loop | Slow page loads, database overload |
| **Large Bundle** | `import _ from 'lodash'` | Slow initial load |
| **Missing Memoization** | Expensive computation in render | Laggy UI |
| **Unnecessary Re-renders** | Object/array literals in props | Wasted CPU cycles |
| **Blocking Operations** | Sync operations on main thread | Frozen UI |
| **No Lazy Loading** | All components loaded upfront | Slow initial load |

## Detailed Patterns

### N+1 Query Pattern

```typescript
// ❌ Bad - N+1 queries
const users = await getUsers();
for (const user of users) {
  user.posts = await getPosts(user.id); // Query per user!
}

// ✅ Good - Single query with join
const users = await getUsersWithPosts();
// Or batch fetch
const posts = await getPostsByUserIds(users.map(u => u.id));
```

### Bundle Size Optimization

```typescript
// ❌ Bad - imports entire library
import _ from 'lodash';
const result = _.debounce(fn, 300);

// ✅ Good - imports only needed function
import debounce from 'lodash/debounce';
const result = debounce(fn, 300);

// ✅ Better - use native or smaller library
import { debounce } from 'lodash-es'; // Tree-shakeable
```

### React Memoization

```typescript
// ❌ Bad - expensive computation every render
const Component = ({ items }) => {
  const sorted = items.sort((a, b) => a.value - b.value);
  return <List items={sorted} />;
};

// ✅ Good - memoized computation
const Component = ({ items }) => {
  const sorted = useMemo(
    () => [...items].sort((a, b) => a.value - b.value),
    [items]
  );
  return <List items={sorted} />;
};
```

### Preventing Unnecessary Re-renders

```typescript
// ❌ Bad - new object every render
<Component style={{ color: 'red' }} />
<Component onClick={() => handleClick(id)} />
<Component items={items.filter(i => i.active)} />

// ✅ Good - stable references
const style = useMemo(() => ({ color: 'red' }), []);
const handleItemClick = useCallback(() => handleClick(id), [id]);
const activeItems = useMemo(() => items.filter(i => i.active), [items]);

<Component style={style} />
<Component onClick={handleItemClick} />
<Component items={activeItems} />
```

### Lazy Loading

```typescript
// ❌ Bad - eagerly loaded heavy component
import HeavyChart from './HeavyChart';

// ✅ Good - lazy loaded
const HeavyChart = lazy(() => import('./HeavyChart'));

// Usage with Suspense
<Suspense fallback={<Loading />}>
  <HeavyChart />
</Suspense>
```

## Database Optimization

| Issue | Fix |
|-------|-----|
| Missing indexes | Add indexes on frequently queried columns |
| SELECT * | Select only needed columns |
| No pagination | Add limit/offset or cursor pagination |
| Unoptimized joins | Review query plans, add indexes |
| Missing connection pooling | Use connection pool |

## Image Optimization

| Issue | Fix |
|-------|-----|
| Unoptimized images | Use Next.js Image component |
| Missing lazy loading | Add `loading="lazy"` |
| No srcset | Provide multiple sizes |
| Large images | Compress and resize |
| No WebP/AVIF | Use modern formats |

## Metrics to Watch

| Metric | Target | Tool |
|--------|--------|------|
| **LCP** (Largest Contentful Paint) | < 2.5s | Lighthouse |
| **FID** (First Input Delay) | < 100ms | Lighthouse |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| **TTFB** (Time to First Byte) | < 200ms | WebPageTest |
| **Bundle Size** | < 200KB gzipped | Webpack Bundle Analyzer |

## Quick Wins

1. **Enable compression** (gzip/brotli)
2. **Add caching headers** (static assets)
3. **Use CDN** for static files
4. **Preconnect** to external origins
5. **Defer non-critical JS** (`async`/`defer`)
6. **Optimize fonts** (subset, swap display)
