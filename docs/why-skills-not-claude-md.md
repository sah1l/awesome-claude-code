# Decision Framework: What Goes Where?

## The Problem

Claude Code has three places to put instructions:
1. **CLAUDE.md** — always loaded into context
2. **Skills** (`.claude/skills/`) — loaded on demand when relevant
3. **Agents** (`.claude/agents/`) — loaded when explicitly invoked

Putting everything in CLAUDE.md is the #1 mistake teams make. It wastes context window on instructions that aren't relevant to the current task.

## The 150-Line Rule

**CLAUDE.md should be under 150 lines.** If it's longer, you're probably putting skill content in CLAUDE.md.

### What Belongs in CLAUDE.md

| Content | Why CLAUDE.md | Example |
|---------|---------------|---------|
| Project overview | Claude needs this for EVERY task | "TypeScript monorepo with Next.js frontend and Express API" |
| Architecture/structure | Guides where to put new code | "Controllers → Services → Repositories" |
| Hard rules | Must never be forgotten | "Never use `any` type" |
| Build/test commands | Needed frequently | `pnpm test`, `pnpm build` |
| Naming conventions | Applied to every file touched | "Files: kebab-case.ts, Components: PascalCase.tsx" |
| Critical don'ts | Prevent costly mistakes | "Don't modify migration files after they're applied" |

### What Belongs in Skills

| Content | Why Skills | Example |
|---------|-----------|---------|
| Detailed standards | Only needed when relevant | Code review format, commit conventions |
| Domain knowledge | Only needed for that domain | API design patterns, Drizzle migration patterns |
| Checklists | Reference material, not rules | Performance checklist, security audit checklist |
| Templates | Used occasionally | PR template, ADR template |
| How-to guides | Reference when doing that task | Error handling patterns, testing patterns |

### What Belongs in Agents

| Content | Why Agents | Example |
|---------|-----------|---------|
| Specialized workflows | Complete task definition | Debugger's 6-step root cause analysis |
| Tool restrictions | Safety per role | Codebase explorer is read-only |
| Model preferences | Cost optimization | Explorer uses Haiku (cheap, fast) |
| Output formats | Structured reporting | Security audit report format |

## Decision Flowchart

```
Is this needed for EVERY task Claude does?
├── YES → CLAUDE.md
└── NO
    │
    Is this reference knowledge Claude should use when relevant?
    ├── YES → Skill
    └── NO
        │
        Is this a complete workflow with specific tools and output format?
        ├── YES → Agent
        └── NO → Probably doesn't need to be documented for Claude
```

## Real-World Example

**Bad CLAUDE.md** (300+ lines — bloated):
```markdown
# Project
... 20 lines of overview ...

# Commit Conventions
... 40 lines of commit format ...        ← Should be a skill

# Code Review Standards
... 60 lines of review format ...        ← Should be a skill

# Testing Patterns
... 50 lines of testing guide ...        ← Should be a skill

# API Conventions
... 80 lines of API design ...           ← Should be a skill

# Architecture
... 50 lines of patterns ...
```

**Good CLAUDE.md** (80 lines — focused):
```markdown
# Project
... 20 lines of overview ...

# Architecture
... 30 lines of structure and patterns ...

# Rules
... 15 lines of hard rules and don'ts ...

# Commands
... 15 lines of build/test/run commands ...
```

The detailed standards live in skills — loaded only when Claude is actually doing code review, writing commits, or designing APIs.

## Context Window Math

- Claude's context window is large but not infinite
- CLAUDE.md loads every message — 300 lines × 200 messages = 60,000 lines of repeated context
- Skills load once when relevant — 100 lines × 1 = 100 lines
- The savings compound with conversation length

## Migration Guide

Already have a bloated CLAUDE.md? Here's how to slim it down:

1. **Identify sections** that are reference material (not hard rules)
2. **Create a skill** for each section: `.claude/skills/<topic>/SKILL.md`
3. **Remove from CLAUDE.md** — add a one-line reference if needed
4. **Test**: Ask Claude to do a task that uses the skill — verify it loads correctly
5. **Iterate**: Check CLAUDE.md line count — target under 150 lines
