# Component Refactoring

## Why This Skill Exists
Large UI components are the #1 source of frontend maintenance pain. They accumulate state, mix concerns, and resist testing. This skill provides concrete heuristics for when to refactor and extraction patterns that work across React, Vue, and Svelte — turning monolithic components into composable pieces.

## When to Refactor

### Hard Thresholds
| Signal | Threshold | Why |
|--------|-----------|-----|
| File length | >300 lines | Too much to hold in your head |
| Cyclomatic complexity | >50 | Too many branches to test reliably |
| Prop drilling depth | >3 levels | Sign of missing abstraction |
| Number of `useState`/`ref()` calls | >7 | State is scattered, not colocated |
| Number of responsibilities | >2 | Violates single responsibility |

### Soft Signals
- You scroll past unrelated code to find what you need
- A bug fix in one section breaks another section
- Two developers frequently conflict in the same file
- You copy-paste logic between components instead of sharing it
- Tests require mocking 10+ things to render the component

## Extraction Patterns

### 1. Extract Custom Hooks / Composables
**When**: Logic is reusable or testable independently of the UI.

```typescript
// Before — logic mixed into component
function OrderPage() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [page, setPage] = useState(1)

  useEffect(() => {
    setLoading(true)
    fetchOrders(page)
      .then(setOrders)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [page])

  // ... 200 more lines of UI
}

// After — logic extracted to a hook
function useOrders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [page, setPage] = useState(1)

  useEffect(() => {
    setLoading(true)
    fetchOrders(page)
      .then(setOrders)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [page])

  return { orders, loading, error, page, setPage }
}

function OrderPage() {
  const { orders, loading, error, page, setPage } = useOrders()
  // UI only — clean and focused
}
```

**Test benefit**: `useOrders` can be tested without rendering any UI.

### 2. Extract Sub-Components
**When**: A section of JSX/template has its own visual identity or interaction logic.

```typescript
// Before — one giant render
function Dashboard() {
  return (
    <div>
      {/* 40 lines of header with nav, search, notifications */}
      {/* 60 lines of stats cards with charts */}
      {/* 80 lines of activity feed with infinite scroll */}
      {/* 30 lines of footer */}
    </div>
  )
}

// After — composed from focused pieces
function Dashboard() {
  return (
    <div>
      <DashboardHeader />
      <StatsCards />
      <ActivityFeed />
      <DashboardFooter />
    </div>
  )
}
```

**Rule of thumb**: If you'd give it a name when explaining the UI to someone, it should be its own component.

### 3. Compound Components
**When**: Multiple components share implicit state and must be used together.

```typescript
// Compound pattern — components share context internally
<Select value={selected} onChange={setSelected}>
  <Select.Trigger>Choose a fruit</Select.Trigger>
  <Select.Options>
    <Select.Option value="apple">Apple</Select.Option>
    <Select.Option value="banana">Banana</Select.Option>
  </Select.Options>
</Select>
```

**Use this when**: The parent owns state, children render parts of it, and the API should feel like a single cohesive unit.

### 4. Render Props / Slots
**When**: The component controls behavior but the consumer controls presentation.

```typescript
// Render prop — component provides data, consumer provides UI
<DataTable
  data={users}
  columns={columns}
  renderRow={(user) => (
    <tr key={user.id}>
      <td>{user.name}</td>
      <td><StatusBadge status={user.status} /></td>
    </tr>
  )}
/>
```

## State Colocation

Move state as close as possible to where it's used.

```
App                          App
├── state: theme ✓           ├── state: theme ✓
├── state: cartItems ✗       ├── CartProvider
├── state: searchQuery ✗     │   └── state: cartItems ✓
│                            │
├── Header                   ├── Header
│   └── SearchBar            │   └── SearchBar
│       (needs searchQuery)  │       └── state: searchQuery ✓
├── ProductList              ├── ProductList
└── Cart                     └── Cart
    (needs cartItems)            (reads from CartProvider)
```

### Rules
1. **Start local** — state lives in the component that uses it
2. **Lift only when shared** — move up only when a sibling needs it
3. **Use context for distant consumers** — skip prop drilling for theme, auth, locale
4. **Never global by default** — global state is a last resort, not a starting point

## Fixing Prop Drilling

| Depth | Fix |
|-------|-----|
| 2 levels | Acceptable — just pass the props |
| 3 levels | Consider composition (pass children instead of data) |
| 4+ levels | Use context, a state manager, or restructure the tree |

### Composition over prop drilling
```typescript
// Before — drilling `user` through 3 components
<Page user={user}>
  <Sidebar user={user}>
    <UserProfile user={user} />
  </Sidebar>
</Page>

// After — composition (Page doesn't need to know about user)
<Page sidebar={<Sidebar><UserProfile user={user} /></Sidebar>}>
  {children}
</Page>
```

## The "One Reason to Change" Test

For each component, ask: *"What would cause this component to change?"*

If the answer includes multiple unrelated reasons, split it:

| Component | Reasons to Change | Verdict |
|-----------|-------------------|---------|
| `UserDashboard` | User data changes, chart library updates, notification logic changes | Split into 3 |
| `LoginForm` | Auth flow changes | Keep as one |
| `ProductCard` | Product schema changes, cart logic changes | Split: `ProductCard` + `AddToCartButton` |

## Refactoring Sequence

1. **Identify boundaries** — draw boxes around sections with different reasons to change
2. **Extract hooks/composables first** — logic is safer to move than UI
3. **Extract sub-components** — start from the leaves (deepest nesting), work outward
4. **Verify behavior** — every extraction should be invisible to the user
5. **Colocate state** — after splitting, move state down to where it's actually used
6. **Delete dead code** — remove props, state, and imports that are no longer needed

## $ARGUMENTS
When invoked with arguments, treat them as a description of the component to refactor. Analyze the component against these heuristics, identify extraction opportunities, and provide a step-by-step refactoring plan with before/after code.
