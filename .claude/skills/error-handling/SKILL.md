# Error Handling

## Why This Skill Exists
Inconsistent error handling leads to swallowed errors, unhelpful messages, and debugging nightmares. These patterns ensure errors are caught at the right level, logged with context, and surfaced appropriately.

## Core Principles

### 1. Fail Fast, Fail Loud
Detect errors at the earliest possible point. Don't let invalid state propagate.

```typescript
// Bad — silent corruption
function processOrder(order: Order) {
  const total = order.items?.reduce((sum, i) => sum + i.price, 0) ?? 0
  // continues with total=0 if items is undefined — wrong!
}

// Good — fail fast
function processOrder(order: Order) {
  if (!order.items?.length) {
    throw new ValidationError('Order must have at least one item')
  }
  const total = order.items.reduce((sum, i) => sum + i.price, 0)
}
```

### 2. User Errors vs System Errors

| Type | Example | Log Level | Show to User | Action |
|------|---------|-----------|-------------|--------|
| **Validation** | Invalid email format | `warn` | Yes, with fix guidance | Return 400 |
| **Business rule** | Insufficient balance | `info` | Yes, explain what happened | Return 422 |
| **Not found** | Invalid resource ID | `info` | Generic "not found" | Return 404 |
| **Auth failure** | Expired token | `warn` | "Please log in again" | Return 401 |
| **System error** | DB connection lost | `error` | "Something went wrong" | Return 500, alert |
| **Programming bug** | Null reference | `error` | "Something went wrong" | Return 500, alert, fix |

### 3. Error Context — The Debugging Lifeline

Always include context when logging errors:

```typescript
// Bad — no context
logger.error('Failed to process payment')

// Good — actionable context
logger.error('Failed to process payment', {
  orderId: order.id,
  userId: order.userId,
  amount: order.total,
  provider: 'stripe',
  stripeError: err.code,
  attempt: retryCount,
})
```

### 4. Error Boundaries

Catch errors at architectural boundaries, not everywhere:

```
Controller (catch → HTTP response)
  └── Service (catch → rethrow with context)
       └── Repository (catch → wrap DB errors)
            └── Database driver (throws raw errors)
```

Don't catch errors in the middle just to log and rethrow — that creates duplicate log entries.

### 5. Custom Error Classes

```typescript
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true,
  ) {
    super(message)
    this.name = this.constructor.name
  }
}

class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 'VALIDATION_FAILED', 400)
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, 'NOT_FOUND', 404)
  }
}
```

### 6. Never Swallow Errors

```typescript
// NEVER do this
try { riskyOperation() } catch (e) { /* ignore */ }

// If you genuinely want to ignore, explain WHY
try {
  await analytics.track(event)
} catch {
  // Analytics failure is non-critical — don't break the user flow
}
```

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| `catch (e) {}` | Swallowed error — silent failure | Log or rethrow |
| `catch (e) { throw e }` | Pointless catch — adds stack noise | Remove the try/catch |
| `catch (e) { log(e); throw e }` | Duplicate logging at each layer | Catch at boundary only |
| String errors: `throw "failed"` | No stack trace, can't instanceof | Use Error subclasses |
| Generic messages: "Error occurred" | Undebuggable | Include context |
