# /review-pr — Parallel Multi-Agent PR Review

## Description
The showpiece command. Launches 3 review agents in parallel for comprehensive PR review: style, logic, and architecture. Combines findings into a unified report with severity-ranked feedback.

This demonstrates Claude Code's most powerful pattern: **agent team orchestration with wave-based parallel execution.**

## Usage
```
/review-pr [PR number or branch name]
```

## Workflow

### Wave 1: Gather Context (Sequential)
1. Identify the PR diff:
   - If a PR number is given: `gh pr diff $ARGUMENTS`
   - If a branch is given: `git diff main...$ARGUMENTS`
   - If nothing is given: `git diff main...HEAD`
2. Identify all changed files and read them in full for context

### Wave 2: Parallel Review (3 Agents)
Launch all three reviews simultaneously using the Task tool:

**Agent 1 — Style Review** (subagent_type: "code-reviewer")
```
Review these changes for code style, naming, formatting, and readability.
Use Conventional Comments format. Focus on: nitpick and suggestion labels.
Skip issues covered by linters/formatters.
```

**Agent 2 — Logic Review** (subagent_type: "code-reviewer")
```
Review these changes for correctness, edge cases, error handling, and potential bugs.
Use Conventional Comments format. Focus on: blocker and issue labels.
Check for: null handling, race conditions, off-by-one, missing error cases.
```

**Agent 3 — Architecture Review** (subagent_type: "architect")
```
Review these changes for architectural concerns: coupling, abstraction level,
separation of concerns, API design, and scalability implications.
Focus on: how this change fits into the broader codebase.
```

### Wave 3: Synthesize (Sequential)
Combine the three agent reports into a unified review:

```markdown
## PR Review: [title]

### Summary
[One paragraph — overall assessment: approve, request changes, or needs discussion]

### Stats
- Files changed: X
- Blockers: X | Issues: X | Suggestions: X | Nitpicks: X

### Blockers (must fix)
[Combined from all agents, deduplicated]

### Issues (should fix)
[Combined from all agents, deduplicated]

### Suggestions (consider)
[Combined from all agents, deduplicated]

### Architecture Notes
[From the architecture agent — broader implications]

### Praise
[Good patterns worth highlighting]

### Verdict
- [ ] Approve
- [ ] Request Changes
- [ ] Needs Discussion
```

## Why 3 Agents?
- **Specialization**: Each agent focuses on its domain — no concern gets shallow coverage
- **Parallelism**: 3 reviews happen simultaneously — faster than one sequential deep review
- **No blind spots**: Style reviewers miss logic bugs; logic reviewers miss architecture drift. Covering all three catches more issues.

## Adaptation Notes
- For small PRs (<50 lines), consider using a single code-reviewer agent in deep mode instead
- For security-sensitive changes, add a 4th wave with the security-auditor agent
- The command works with both GitHub PRs (`gh` CLI) and local branches
