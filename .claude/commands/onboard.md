# /onboard — New Developer Codebase Onboarding

## Description
Generates a personalized "project cheat sheet" for a developer new to the codebase. Analyzes the project structure, tech stack, conventions, and key files to produce a guide that answers the first 20 questions a new dev would ask.

## Usage
```
/onboard
```

## Workflow

### Step 1: Project Overview
Gather high-level information:
- Read `README.md`, `CLAUDE.md`, `CONTRIBUTING.md` (if they exist)
- Read `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` (detect stack)
- Run `ls` on root directory to understand structure
- Check `.env.example` for required environment variables

### Step 2: Architecture Analysis
Use the codebase-explorer agent to understand:
- Directory structure and organization pattern (feature-based, layer-based, etc.)
- Entry points (main files, server startup, CLI entry)
- Key abstractions (base classes, shared utilities, middleware)
- Data layer (ORM, database, migrations)
- API layer (routes, controllers, handlers)

### Step 3: Development Workflow
Detect from config files:
- Package manager (`npm`, `yarn`, `pnpm`, `bun`, `pip`, `cargo`)
- Test runner and how to run tests
- Build command
- Dev server command
- Linter and formatter
- CI/CD pipeline (`.github/workflows/`, `Jenkinsfile`, etc.)

### Step 4: Generate Cheat Sheet

```markdown
# Project Cheat Sheet: [Project Name]

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5.x |
| Runtime | Node.js 22 |
| Framework | Express 4 |
| Database | PostgreSQL 16 + Drizzle ORM |
| Testing | Vitest |
| CI/CD | GitHub Actions |

## Quick Start
\`\`\`bash
[detected setup commands]
\`\`\`

## Project Structure
\`\`\`
[annotated directory tree — only key directories, max 20 lines]
\`\`\`

## Key Files You'll Touch Often
| File | Purpose |
|------|---------|
| `src/routes/index.ts` | API route registration |
| `src/db/schema.ts` | Database schema definitions |
| `src/middleware/auth.ts` | Authentication middleware |

## Common Tasks
| Task | Command |
|------|---------|
| Run dev server | `npm run dev` |
| Run tests | `npm test` |
| Run single test | `npm test -- --testPathPattern="user"` |
| Generate migration | `npx drizzle-kit generate` |
| Lint | `npm run lint` |

## Conventions
- [Detected naming conventions]
- [Detected file organization patterns]
- [Detected error handling approach]

## Architecture Decisions
[Key patterns found in the codebase — e.g., "Repository pattern for DB access", "Controller → Service → Repository layers"]

## Environment Setup
[Required env vars from .env.example with descriptions]

## Where to Find Things
| "I need to..." | Look in... |
|----------------|-----------|
| Add an API endpoint | `src/routes/` |
| Add a DB table | `src/db/schema.ts` |
| Add middleware | `src/middleware/` |
| Add a test | `src/__tests__/` or co-located `*.test.ts` |
```

## Why This Command?
- Onboarding a new developer typically takes 1-2 days of exploration
- This command produces the guide in minutes
- The cheat sheet answers real questions, not abstract architecture descriptions
- It detects the actual project setup rather than assuming conventions
