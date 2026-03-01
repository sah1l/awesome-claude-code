# awesome-claude-code

Production-tested Claude Code configuration patterns — agents, skills, commands, and hooks — extracted from real projects and community best practices.

**Not a list of links.** This is a working reference repo you can clone and adapt. Every file includes WHY it exists, not just WHAT it does.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/sahil/awesome-claude-code.git

# Copy the pieces you need into your project
cp -r awesome-claude-code/.claude/agents/code-reviewer.md your-project/.claude/agents/
cp -r awesome-claude-code/.claude/skills/commit your-project/.claude/skills/
cp -r awesome-claude-code/hooks/pre-commit-guard your-project/hooks/
```

Or browse the files and adapt patterns to your stack.

## What's Inside

### Agents (8)

Specialized agents with defined tools, model preferences, and output formats.

| Agent | Model | Purpose |
|-------|-------|---------|
| [codebase-explorer](.claude/agents/codebase-explorer.md) | Haiku | Fast read-only Q&A about the codebase |
| [code-reviewer](.claude/agents/code-reviewer.md) | Inherit | Conventional Comments review, quick or deep mode |
| [architect](.claude/agents/architect.md) | Opus | Structured implementation plans |
| [debugger](.claude/agents/debugger.md) | Inherit | 6-step root cause analysis → fix → verify |
| [security-auditor](.claude/agents/security-auditor.md) | Inherit | OWASP Top 10, severity-ranked findings |
| [test-writer](.claude/agents/test-writer.md) | Inherit | Framework auto-detection, AAA pattern |
| [code-simplifier](.claude/agents/code-simplifier.md) | Inherit | Reduce complexity, preserve behavior |
| [documentation-writer](.claude/agents/documentation-writer.md) | Inherit | Match existing doc style |

### Skills (14)

Knowledge bases loaded on demand — keeps CLAUDE.md lean.

| Skill | Purpose |
|-------|---------|
| [commit](.claude/skills/commit/SKILL.md) | Conventional commit message format |
| [code-review-standards](.claude/skills/code-review-standards/SKILL.md) | Conventional Comments + [examples](.claude/skills/code-review-standards/examples.md) |
| [testing-patterns](.claude/skills/testing-patterns/SKILL.md) | AAA pattern, naming, unit vs integration |
| [api-conventions](.claude/skills/api-conventions/SKILL.md) | REST design, status codes, pagination, errors |
| [git-workflow](.claude/skills/git-workflow/SKILL.md) | Branch naming, PR template, merge strategy |
| [error-handling](.claude/skills/error-handling/SKILL.md) | Fail fast, user vs system errors, context |
| [performance-checklist](.claude/skills/performance-checklist/SKILL.md) | N+1 queries, caching, async, lazy loading |
| [log-analyzer](.claude/skills/log-analyzer/SKILL.md) | MCP-powered production log investigation |
| [migration-writer](.claude/skills/migration-writer/SKILL.md) | Drizzle ORM migration patterns (PostgreSQL) |
| [documentation-standards](.claude/skills/documentation-standards/SKILL.md) | README template, ADR format, comment philosophy |
| [component-refactoring](.claude/skills/component-refactoring/SKILL.md) | UI component decomposition heuristics and extraction patterns |
| [contract-first-api](.claude/skills/contract-first-api/SKILL.md) | Define API contracts before implementation (tRPC, FastAPI, protobuf) |
| [celery-task-patterns](.claude/skills/celery-task-patterns/SKILL.md) | Background job patterns: retries, idempotency, dead letters |
| [rag-pipeline](.claude/skills/rag-pipeline/SKILL.md) | RAG pipeline: chunking, embedding, retrieval, reranking |

### Commands (7)

Workflows that orchestrate agents into multi-step processes.

| Command | Description |
|---------|-------------|
| [/review-pr](.claude/commands/review-pr.md) | **Showpiece** — 3 parallel review agents (style, logic, architecture) |
| [/plan](.claude/commands/plan.md) | Explore codebase → structured implementation plan → approval |
| [/tdd](.claude/commands/tdd.md) | Red-Green-Refactor test-driven development loop |
| [/build-fix](.claude/commands/build-fix.md) | Auto-detect build system → fix errors → retry (max 3) |
| [/onboard](.claude/commands/onboard.md) | Generate personalized project cheat sheet |
| [/changelog](.claude/commands/changelog.md) | Git history → Keep a Changelog format |
| [/security-scan](.claude/commands/security-scan.md) | Security audit + secrets detection |

### Hooks (8 total, 2 enabled by default)

Shell scripts that run automatically on Claude Code events.

| Hook | Event | Purpose |
|------|-------|---------|
| [pre-commit-guard](hooks/pre-commit-guard/) | PreToolUse (Bash) | Block `rm -rf /`, force-push to main, `.env` writes |
| [auto-format](hooks/auto-format/) | PostToolUse (Write/Edit) | Auto-detect & run prettier/black/gofmt/rustfmt |

Plus 6 additional optional hooks in `hooks/` (`auto-lint`, `auto-test`, `block-large-files`, `git-diff-summary`, `secret-guard`, `timestamp-logger`) and [6 hook recipes](docs/hook-recipes.md) ready to copy-paste.

> **Tip**: Claude Code has built-in notification support — run `/config` and look for notification settings. No custom hook needed.

## Three-Tier Architecture

Claude Code has three tiers of instructions — understanding when to use each is the key to an effective setup.

```
┌──────────────────────────────────────────────────┐
│  CLAUDE.md          Always loaded                │
│  Project context, hard rules, build commands     │
│  Target: <150 lines                              │
├──────────────────────────────────────────────────┤
│  Skills              Loaded on demand            │
│  Standards, checklists, domain knowledge         │
│  Only loaded when relevant                       │
├──────────────────────────────────────────────────┤
│  Agents              Loaded when invoked         │
│  Specialized workflows with defined tools        │
│  Complete task definitions with output format    │
└──────────────────────────────────────────────────┘
```

**The common mistake**: Putting everything in CLAUDE.md. This wastes context on every message. Move detailed standards to skills — they load only when needed.

Read more: [Why Skills, Not CLAUDE.md](docs/why-skills-not-claude-md.md)

## Essential Commands Cheatsheet

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/compact` | Compress conversation context | Every 30-40 turns, or when switching tasks |
| `/memory` | Show loaded context files | Start of session — audit what's loaded |
| `/context` | Inspect context window contents | Before complex tasks |
| `/config` | Browse all settings | Once (enable explanatory mode!) |
| `/insights` | Get workflow improvement suggestions | After a week of usage |
| `/fork` | Branch the current session | Before risky experiments |
| `/add-dir` | Work across multiple repos | Cross-repo changes |
| `/clear` | Fresh conversation (aliases: `/new`, `/reset`) | Between unrelated tasks |
| `Ctrl+B` | Send task to background | Long-running builds/tests |
| `Ctrl+S` | Stash current input, restore with `Ctrl+S` again | Quick interruption mid-prompt |
| `/resume` | Browse and continue a previous session | Multi-day features |

## Top 10 Tips

1. **Keep CLAUDE.md under 150 lines** — move details to skills ([guide](docs/why-skills-not-claude-md.md))
2. **Use `/compact` when switching tasks** — old context is noise ([more](docs/context-optimization.md))
3. **Enable explanatory mode** via `/config` — learn passively from Claude's insights
4. **`/fork` before risky experiments** — your original session is safe
5. **Say "think harder"** for complex problems — activates extended thinking
6. **Use agent teams** for parallel work — 3 reviewers catch more than 1 ([example](examples/agent-team-workflow.md))
7. **`Ctrl+B` for background tasks** — keep working while tests run
8. **Worktrees for parallel features** — two Claude sessions, zero stashing ([guide](examples/worktree-guide.md))
9. **MCP servers extend Claude** — GitHub, Slack, DB, logs ([config](examples/mcp.json.example))
10. **Start features with `/plan`** — 5 min planning saves 30 min rework

## Documentation

| Guide | What You'll Learn |
|-------|------------------|
| [Why Skills, Not CLAUDE.md](docs/why-skills-not-claude-md.md) | Decision framework for what goes where |
| [Agent Design Patterns](docs/agent-design-patterns.md) | Explorer, Specialist, Orchestrator, Pipeline |
| [Hook Recipes](docs/hook-recipes.md) | 6 copy-paste hook recipes |
| [Context Optimization](docs/context-optimization.md) | Context window management strategies |
| [Commands Guide](docs/claude-commands-guide.md) | Essential slash commands & workflows |
| [Tips & Tricks](docs/tips-and-tricks.md) | 20+ power-user techniques |

## Examples

| Example | Description |
|---------|------------|
| [CLAUDE.md.example](examples/CLAUDE.md.example) | Annotated CLAUDE.md for a full-stack SaaS app |
| [settings.json.example](examples/settings.json.example) | Every setting explained with comments |
| [mcp.json.example](examples/mcp.json.example) | GitHub, Slack, DB, and search MCP configs |
| [Agent Team Workflow](examples/agent-team-workflow.md) | Wave-based parallel agent orchestration |
| [Worktree Guide](examples/worktree-guide.md) | Git worktrees for parallel development |

## Adapting for Your Stack

This repo is technology-agnostic by design. To adapt it:

1. **Clone or copy** the patterns you need
2. **Customize CLAUDE.md** with your project's tech stack, architecture, and rules
3. **Customize skills** with your project's specific conventions (swap Drizzle for Prisma, Vitest for Jest, etc.)
4. **Create commands** for your team's common workflows
5. **Set up hooks** that match your toolchain (formatter, linter, test runner)

The patterns are the same regardless of language or framework — the specifics are what you adapt.

## License

MIT
