# Documentation Standards

## Why This Skill Exists
Documentation rots faster than code because nothing enforces it. These standards define *what* to document, *where* to put it, and *how* to keep it alive — prioritizing docs that stay accurate with minimal maintenance.

## What to Document (and What Not To)

### Document
- **WHY** decisions were made (Architecture Decision Records)
- **HOW** to get started (README quick-start)
- **WHAT** the boundaries are (API contracts, config options)
- **GOTCHAS** that waste time (known issues, non-obvious behavior)

### Don't Document
- **WHAT** the code does line-by-line (the code says this)
- **HOW** to use standard tools (link to their docs)
- **THINGS** that change weekly (they'll be wrong by Friday)

## README Template

```markdown
# Project Name

One-sentence description of what this project does and who it's for.

## Quick Start

\`\`\`bash
# 3 commands or fewer to get running
git clone <repo>
cp .env.example .env
docker compose up
\`\`\`

## Architecture

Brief description + diagram (Mermaid or ASCII) of major components.

## Development

### Prerequisites
- Tool X v1.2+
- Tool Y v3.4+

### Running Locally
Step-by-step instructions.

### Running Tests
\`\`\`bash
npm test
\`\`\`

## Deployment

How to deploy, environment differences, rollback procedure.

## Contributing

Link to CONTRIBUTING.md or brief inline guidelines.
```

## Architecture Decision Records (ADRs)

Use ADRs for decisions that are expensive to reverse. Store in `docs/adr/`.

```markdown
# ADR-001: Use PostgreSQL over MongoDB

## Status
Accepted

## Context
We need a primary database. Our data is highly relational (users → orders → items).

## Decision
Use PostgreSQL with Drizzle ORM.

## Consequences
- Relational queries are natural and efficient
- Schema migrations require more discipline
- Team needs SQL knowledge (most already have it)
- MongoDB's flexible schema advantage is lost (acceptable — our schema is stable)
```

### ADR Rules
- Number sequentially: `ADR-001`, `ADR-002`, ...
- Once accepted, never edit — write a new ADR that supersedes it
- Keep the Context section honest about trade-offs
- Status values: `Proposed`, `Accepted`, `Deprecated`, `Superseded by ADR-XXX`

## Comment Philosophy

```typescript
// BAD — restates the code
// Increment counter by 1
counter++

// BAD — obvious from context
// Get the user from the database
const user = await userRepo.findById(id)

// GOOD — explains WHY
// UTC offset applied because the payment gateway uses merchant's local time,
// not the customer's timezone
const adjustedTime = applyUtcOffset(timestamp, merchant.timezone)

// GOOD — warns about non-obvious behavior
// NOTE: This query intentionally skips the cache because stale inventory
// data causes overselling. The 50ms latency hit is acceptable.
const inventory = await db.query('SELECT ...')
```

### When to Comment
- Non-obvious business rules
- Workarounds for bugs in dependencies
- Performance-critical code with a non-obvious approach
- Regex patterns (always explain the pattern)
- Magic numbers (or better: extract to named constants)
