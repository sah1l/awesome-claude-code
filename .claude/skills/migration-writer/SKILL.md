# Migration Writer — Drizzle ORM

## Why This Skill Exists
Database migrations are high-stakes operations — a bad migration can cause downtime, data loss, or irreversible schema corruption. This skill codifies production-tested patterns for Drizzle ORM with PostgreSQL, covering schema definitions, migration generation, and safety practices.

## Schema Definition Patterns

### Table with Audit Columns
```typescript
import { pgTable, text, timestamp, uuid } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  // Audit columns — include on every table
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
})
```

### Enum Pattern
```typescript
import { pgEnum } from 'drizzle-orm/pg-core'

// Define enum separately for reuse
export const orderStatusEnum = pgEnum('order_status', [
  'pending',
  'confirmed',
  'shipped',
  'delivered',
  'cancelled',
])

export const orders = pgTable('orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  status: orderStatusEnum('status').notNull().default('pending'),
  // ...
})
```

### Relations
```typescript
import { relations } from 'drizzle-orm'

export const usersRelations = relations(users, ({ many }) => ({
  orders: many(orders),
}))

export const ordersRelations = relations(orders, ({ one }) => ({
  user: one(users, {
    fields: [orders.userId],
    references: [users.id],
  }),
}))
```

## Migration Workflow

### Generate
```bash
npx drizzle-kit generate    # Generates SQL from schema diff
```

### Review the Generated SQL
**Always review before applying.** Check for:
- Destructive operations (DROP TABLE, DROP COLUMN)
- Lock-heavy operations on large tables (ALTER TABLE with default values)
- Data type changes that might truncate data

### Apply
```bash
npx drizzle-kit migrate     # Applies pending migrations
```

### Concurrent Index Creation
For indexes on large tables, avoid locking writes:

```sql
-- In the generated migration, manually change to:
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders (user_id);
```

**Note**: `CONCURRENTLY` cannot run inside a transaction. You may need to split the migration.

## Safety Checklist

Before applying any migration to production:

- [ ] **Reviewed generated SQL** — no unexpected DROP statements
- [ ] **Backward compatible** — old code can run against new schema (deploy schema first, then code)
- [ ] **Tested on staging** — migration runs cleanly with production-like data volume
- [ ] **Backup verified** — recent backup exists and restore has been tested
- [ ] **Large table check** — if table has >1M rows, check for lock duration
- [ ] **Rollback plan** — know how to reverse the migration if needed
- [ ] **Concurrent indexes** — large table indexes use `CONCURRENTLY`

## Common Patterns

### Adding a NOT NULL Column to Existing Table
```sql
-- Step 1: Add column as nullable
ALTER TABLE users ADD COLUMN phone text;

-- Step 2: Backfill data
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 3: Add NOT NULL constraint
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

Never add `NOT NULL` without a default on a table with existing data — the migration will fail.

### Renaming a Column (Zero-Downtime)
1. Add new column
2. Deploy code that writes to both columns
3. Backfill old data to new column
4. Deploy code that reads from new column
5. Drop old column

## $ARGUMENTS
When invoked with arguments, treat them as the schema change description and generate the appropriate Drizzle schema definition and migration steps following these patterns.
