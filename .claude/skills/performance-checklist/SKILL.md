# Performance Checklist

## Why This Skill Exists
Performance issues rarely come from algorithmic complexity — they come from repeated patterns: N+1 queries, missing indexes, uncached computations, and synchronous blocking. This checklist catches the common 90%.

## Database

### N+1 Queries
The most common performance killer. Symptoms: page load time scales linearly with data size.

```typescript
// N+1 — 1 query for orders + N queries for users
const orders = await db.query('SELECT * FROM orders')
for (const order of orders) {
  order.user = await db.query('SELECT * FROM users WHERE id = $1', [order.userId])
}

// Fixed — 2 queries total with a JOIN or IN clause
const orders = await db.query(`
  SELECT o.*, u.name as userName
  FROM orders o
  JOIN users u ON o.user_id = u.id
`)
```

### Missing Indexes
- Every `WHERE` clause column should have an index
- Every `JOIN` column should have an index
- Composite indexes for multi-column queries (leftmost prefix rule)
- Check: `EXPLAIN ANALYZE` on slow queries

### Pagination
- Use cursor-based pagination for large tables (offset skips are O(n))
- Always `LIMIT` unbounded queries
- Never `SELECT *` in production code — select only needed columns

## Caching

### When to Cache
| Signal | Cache? |
|--------|--------|
| Read-heavy, write-rare data | Yes |
| Expensive computation (>100ms) | Yes |
| Data changes per-request | No |
| User-specific data with low reuse | Usually no |

### Cache Invalidation
- **TTL-based**: simplest, set expiry (5 min for API responses, 1h for config)
- **Write-through**: update cache on write (consistent but complex)
- **Event-driven**: invalidate on change event (best for distributed systems)

### Cache Key Design
```
{service}:{entity}:{id}:{version}
user-service:profile:12345:v2
```

## Async & Concurrency

### Don't Block the Event Loop
```typescript
// Bad — sequential when independent
const users = await getUsers()
const products = await getProducts()
const orders = await getOrders()

// Good — parallel when independent
const [users, products, orders] = await Promise.all([
  getUsers(),
  getProducts(),
  getOrders(),
])
```

### Batch Operations
```typescript
// Bad — N individual inserts
for (const item of items) {
  await db.insert('items', item)
}

// Good — single batch insert
await db.batchInsert('items', items)
```

## Frontend Performance

### Lazy Loading
- Route-based code splitting for SPA pages
- `loading="lazy"` for below-fold images
- Dynamic imports for heavy libraries (charts, editors, PDF renderers)

### Bundle Size
- Audit with `npx bundlephobia <package>` before adding dependencies
- Tree-shake: use ESM imports (`import { map } from 'lodash-es'`)
- Avoid importing entire libraries for one function

### Rendering
- Virtualize long lists (>100 items)
- Debounce search inputs (300ms)
- Memoize expensive computations
- Avoid layout thrashing (batch DOM reads/writes)

## Quick Audit Checklist

- [ ] No N+1 queries (check ORM eager loading)
- [ ] Indexes on all filtered/joined columns
- [ ] All unbounded queries have LIMIT
- [ ] Independent async operations run in parallel
- [ ] Expensive computations are cached with TTL
- [ ] Images are lazy-loaded and properly sized
- [ ] Bundle size checked for new dependencies
- [ ] Long lists are virtualized
- [ ] Search inputs are debounced
