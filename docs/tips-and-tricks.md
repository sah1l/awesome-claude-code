# Tips & Tricks — Power-User Techniques

Quick-reference tips. For detailed explanations of commands, see the [commands guide](claude-commands-guide.md). For context management strategy, see [context optimization](context-optimization.md).

## Context & Sessions

1. **`/memory` at session start** — audit what's loaded; stale CLAUDE.md files from parent directories eat context silently
2. **`/compact` when switching tasks** — old context is noise for the new task
3. **`/fork` before risky experiments** — your original session stays untouched; resume it in another terminal
4. **`/add-dir` for cross-repo work** — work on an API and its SDK in one session
5. **Target 60-80% cache hits** — stable, unchanged CLAUDE.md across a session means faster responses and lower cost

## Getting Better Output

6. **Enable explanatory mode** via `/config` — Claude shares micro-insights every response; compounds into real learning over a week
7. **Use `/insights` after a week** — Claude analyzes your patterns and suggests workflow improvements
8. **Say "think harder"** for complex problems — activates extended thinking for deeper analysis
9. **`/plan` before making changes** — Claude explores first, presents a plan, writes code only after your approval

## Browser & Visual Workflows

10. **Claude in Chrome for visual QA** — take screenshots of pages and compare against Figma designs via MCP
11. **Screenshot-driven debugging** — tell Claude to screenshot the page and trace the visual issue back to CSS/component code
12. **Verify implementations match mockups** — screenshot Figma (via MCP) and the deployed app, Claude identifies differences

## Developer Productivity

13. **`$ARGUMENTS` in skills** — skills receive arguments dynamically: `/commit add email verification` passes the description to the commit skill
14. **`Ctrl+B` to background tasks** — start a long build/test, press Ctrl+B, keep working; you'll get notified when it completes
15. **`Ctrl+S` to stash input** — halfway through typing a prompt and need to do something else? Press Ctrl+S to stash it, handle the interruption, then Ctrl+S again to restore
16. **Worktrees for parallel features** — use `claude --worktree feature-name` (or `-w`) to create an isolated worktree in `.claude/worktrees/`; run two Claude sessions on different branches simultaneously
17. **Agent teams for parallel review** — launch 3 review agents (style, logic, architecture) simultaneously for better coverage than one sequential review
18. **MCP servers extend Claude** — GitHub, Slack, database, log queries — all without leaving the terminal. See [mcp.json.example](../examples/mcp.json.example)

## Configuration

19. **Explore `/config` thoroughly** — model selection, output mode, notifications, theme, permissions — most users only scratch the surface
20. **Notifications are built-in** — use `/config` to enable desktop notifications when tasks complete; no custom hook needed
21. **Auto-memory persists learnings** — Claude remembers project-specific patterns across sessions
22. **Custom slash commands are your superpower** — create `.claude/commands/<name>.md` for repeated workflows; every team should have at least a PR review and an onboarding command

## Workflow Patterns

23. **Start every feature with `/plan`** — 5 min planning saves 30 min rework; Claude explores the codebase and proposes an approach before writing code
24. **Debugger's 6-step process** — don't say "fix this bug"; instead: reproduce → isolate → identify root cause → fix → verify → check for similar patterns
25. **Commit early, squash at merge** — let Claude commit frequently on feature branches; squash merge to main for clean history
