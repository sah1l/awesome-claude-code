# Agent Team Orchestration — Wave-Based Parallel Workflows

## Why This Pattern?

Single-agent workflows are sequential: plan → implement → test → review → commit. But many of these steps are independent and can run in parallel. Agent team orchestration uses **waves** — groups of tasks that run simultaneously — to dramatically reduce total time.

This pattern is adapted from a production setup with 16 specialized agents running in coordinated waves.

## The Wave Pattern

```
Wave 1: Plan         (sequential — must complete before implementation)
    │
    ▼
Wave 2: Implement    (parallel — independent files/features)
    ├── Agent: implement feature A
    ├── Agent: implement feature B
    └── Agent: implement feature C
    │
    ▼
Wave 3: Test         (sequential — needs implementation complete)
    │
    ▼
Wave 4: Review       (parallel — independent review perspectives)
    ├── Agent: code style review
    ├── Agent: logic/correctness review
    └── Agent: security review
    │
    ▼
Wave 5: Commit       (sequential — needs all reviews passed)
```

## Implementation in Claude Code

### Using the Task Tool with Parallel Agents

```markdown
<!-- In a command file (e.g., .claude/commands/implement-feature.md) -->

## Step 1: Plan (Wave 1 — Sequential)
Use the architect agent to create an implementation plan.
Wait for user approval before proceeding.

## Step 2: Implement (Wave 2 — Parallel)
Launch multiple agents simultaneously using the Task tool:

Task 1 (subagent_type: "general-purpose"):
  "Implement the database schema changes as described in the plan"

Task 2 (subagent_type: "general-purpose"):
  "Implement the API endpoints as described in the plan"

Task 3 (subagent_type: "general-purpose"):
  "Implement the frontend components as described in the plan"

All three run in parallel. Wait for all to complete.

## Step 3: Test (Wave 3 — Sequential)
Use the test-writer agent to write and run tests.

## Step 4: Review (Wave 4 — Parallel)
Launch review agents simultaneously (see /review-pr command).

## Step 5: Commit (Wave 5 — Sequential)
Commit changes following the commit skill conventions.
```

### Key Principles

1. **Sequential waves, parallel agents within waves** — each wave depends on the previous wave completing
2. **Agent specialization** — each agent has a narrow focus (don't ask one agent to do everything)
3. **Shared context via files** — agents communicate through the codebase, not through messages
4. **Deterministic ordering** — wave dependencies are explicit, not implicit

## Real-World Example: Feature Development

```
Feature: Add email notifications for order status changes

Wave 1 — Plan
└── architect agent
    Output: Implementation plan with 4 files to create, 2 to modify

Wave 2 — Implement (parallel)
├── Agent A: Create email templates (packages/email/templates/)
├── Agent B: Create notification service (apps/api/src/services/notification.ts)
└── Agent C: Add event listeners for order status changes (apps/api/src/events/)

Wave 3 — Wire & Test
├── Integrate the three components
└── Write and run tests

Wave 4 — Review (parallel)
├── Code review agent: style, conventions, patterns
├── Security agent: email injection, PII in logs
└── Architecture agent: event system design, coupling

Wave 5 — Ship
└── Commit with conventional message
```

## When to Use This Pattern

| Scenario | Recommended? |
|----------|-------------|
| Large feature with 5+ files | Yes — parallel implementation saves time |
| Small bug fix | No — single agent is faster |
| PR review | Yes — parallel review perspectives catch more issues |
| Refactoring across many files | Yes — parallel file changes |
| Security audit | Partially — secrets scan + code audit can run in parallel |

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Too many agents in one wave | Context overhead exceeds parallelism benefit | Max 3-4 agents per wave |
| Agents modifying the same file | Merge conflicts between agents | Assign files to agents exclusively |
| No wave dependencies | Agents depend on incomplete work | Explicitly define wave ordering |
| Skipping the plan wave | Implementation without direction | Always plan first |
