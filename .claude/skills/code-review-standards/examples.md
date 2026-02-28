# Code Review Examples

## Blocker

```
blocker: SQL injection via string interpolation

`db.query(`SELECT * FROM users WHERE id = ${userId}`)` allows arbitrary SQL.
Use parameterized queries:

  db.query('SELECT * FROM users WHERE id = $1', [userId])

This is exploitable in production — must fix before merge.
```

## Issue

```
issue: race condition in concurrent balance updates

Two simultaneous transfers can both read the same balance, then both write,
causing one transfer to be silently lost. Wrap in a transaction with
SELECT ... FOR UPDATE or use optimistic locking with a version column.
```

## Suggestion

```
suggestion: extract retry logic into a shared utility

This is the third place we've implemented retry-with-backoff. Consider
extracting to a `withRetry(fn, { maxAttempts, backoff })` utility to
keep retry policies consistent and testable.
```

## Nitpick

```
nitpick: prefer `const` over `let` for `maxRetries`

It's never reassigned, so `const` communicates intent better.
```

## Question

```
question: is the 30-second timeout intentional?

The API docs suggest the upstream P99 is ~5s. A 30s timeout means users
could wait 6x longer than expected before seeing an error. Was this
chosen for a specific reason, or should we tighten it?
```

## Praise

```
praise: excellent error boundary implementation

The way this catches rendering errors and falls back to a cached version
while logging to Sentry is exactly the pattern we should use everywhere.
Really well done.
```

## Thought

```
thought: this module might benefit from the strategy pattern

Right now the if/else chain handles 4 payment providers. If we're adding
Stripe next quarter, a strategy pattern would make each provider independently
testable and deployable. Not blocking this PR — just planting a seed.
```
