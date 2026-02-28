# Agent Design Patterns

## The Four Patterns

Every agent falls into one of four patterns. Understanding which pattern to use — and which to avoid — determines whether your agent setup helps or hurts productivity.

---

## Pattern 1: Explorer

**Purpose**: Read-only information retrieval. Answers questions about the codebase without modifying anything.

**Characteristics**:
- Tools: Read, Grep, Glob (NO Write, Edit, Bash)
- Model: Haiku (fast, cheap — exploration doesn't need deep reasoning)
- Safety: Cannot modify files — zero risk
- Speed: Fastest pattern due to restricted tools and lightweight model

**Example**: `codebase-explorer` agent
```yaml
model: haiku
tools: [Read, Grep, Glob]
```

**When to use**:
- Onboarding questions ("where is X?", "how does Y work?")
- Quick lookups during development
- Pre-planning exploration

**Anti-patterns**:
- Don't use Explorer when you need to modify files (use Specialist)
- Don't use a heavy model for simple lookups (Haiku is sufficient)

---

## Pattern 2: Specialist

**Purpose**: Deep expertise in one domain. Does one thing extremely well.

**Characteristics**:
- Tools: Domain-appropriate (reviewer = read-only, debugger = read + edit + bash)
- Model: Inherit or specify based on complexity
- Focus: Single responsibility — each specialist owns one concern
- Output: Structured format specific to their domain

**Examples**:
| Specialist | Domain | Tools |
|-----------|--------|-------|
| `code-reviewer` | Code quality | Read, Grep, Glob |
| `security-auditor` | Vulnerability detection | Read, Grep, Glob |
| `test-writer` | Test generation | Read, Write, Grep, Glob, Bash |
| `debugger` | Root cause analysis | Read, Grep, Glob, Bash, Edit |
| `code-simplifier` | Refactoring | Read, Edit, Grep, Glob |

**When to use**:
- The task requires domain expertise (security, testing, performance)
- You want consistent output format across invocations
- Multiple perspectives are needed (launch specialists in parallel)

**Anti-patterns**:
- Don't create a "general-purpose specialist" — that's just Claude with extra steps
- Don't give a specialist tools outside its domain (reviewer shouldn't Edit)
- Don't create one mega-specialist — split into focused agents

---

## Pattern 3: Orchestrator

**Purpose**: Coordinates multiple agents into a workflow. Doesn't do the work itself — it delegates.

**Characteristics**:
- Tools: Task tool (to launch agents), Bash (for git/build commands)
- Model: Inherit (orchestration doesn't need special reasoning)
- Flow: Wave-based — sequential waves with parallel agents within each wave
- Output: Synthesized report combining agent outputs

**Example**: `/review-pr` command (orchestrates 3 review agents)
```
Wave 1: Gather PR diff (sequential)
Wave 2: 3 parallel review agents (style, logic, architecture)
Wave 3: Synthesize into unified report (sequential)
```

**When to use**:
- Task benefits from multiple perspectives (code review, security audit)
- Work can be parallelized (independent file changes)
- Output needs synthesis from multiple sources

**Anti-patterns**:
- Don't orchestrate fewer than 2 agents — single-agent tasks don't need orchestration
- Don't have agents in the same wave modify the same files — merge conflicts
- Don't skip the synthesis step — raw agent outputs need combining

---

## Pattern 4: Pipeline

**Purpose**: Sequential multi-step workflow where each step depends on the previous. Unlike Orchestrator, Pipeline runs steps in strict order.

**Characteristics**:
- Tools: All (different steps need different tools)
- Model: Inherit
- Flow: Strictly sequential — step N must complete before step N+1
- State: Each step builds on the previous step's output

**Example**: `/tdd` command (Red → Green → Refactor)
```
Step 1: Write failing test (Red)
Step 2: Implement minimum code (Green)
Step 3: Refactor (Clean)
Step 4: Verify all tests pass
```

**Example**: `/build-fix` command
```
Step 1: Detect build system
Step 2: Run build
Step 3: Parse errors
Step 4: Fix errors
Step 5: Retry (loop back to step 2, max 3 times)
```

**When to use**:
- Each step depends on the previous step's output
- The workflow has a clear linear progression
- Steps cannot run in parallel

**Anti-patterns**:
- Don't pipeline independent steps — use Orchestrator with parallel waves instead
- Don't create pipelines longer than 5-6 steps — split into sub-pipelines
- Don't skip verification steps — every pipeline should verify its output

---

## Choosing the Right Pattern

```
Does the task need to modify files?
├── NO → Explorer
└── YES
    │
    Does it require multiple perspectives or parallel work?
    ├── YES → Orchestrator
    └── NO
        │
        Is it a multi-step sequence where each step depends on the last?
        ├── YES → Pipeline
        └── NO → Specialist
```

## Common Anti-Patterns (Across All Patterns)

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| Swiss Army Knife agent | Does everything, excels at nothing | Split into focused specialists |
| Chatty agents | Agents talk to each other, not through files | Communicate via the codebase |
| Unverified output | Agent says "done" without checking | Every agent verifies its own work |
| Over-orchestration | 5 agents for a 10-line change | Match complexity to task size |
| Model waste | Opus for file search, Haiku for architecture | Match model to reasoning needs |
