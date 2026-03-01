# Claude Code Commands Guide

A comprehensive guide to Claude Code's built-in commands and workflows.

## Session Management

### `/compact` — Compress Context
The most important command for long sessions. Compresses conversation history while preserving key information.

**When to use**:
- Switching between tasks (old context is noise)
- Claude starts making mistakes or hallucinating
- After a long exploration phase, before implementation
- Proactively every 30-40 turns

**Pro tip**: Add a summary message before compacting — "I'm about to compact. Key context: we're implementing email verification in auth-service.ts, the approach is X." This helps Claude retain the most important information.

### `/clear` — Reset Conversation
Full reset — wipes conversation history but keeps settings and CLAUDE.md loaded.

**When to use**: When the conversation is beyond saving and `/compact` isn't enough.

### `/new` — New Conversation
Starts a fresh conversation. Similar to `/clear` but semantically signals "new task."

### `/fork` — Split Session
Creates a branch of the current conversation. The original session continues in another terminal.

**Power move**: Fork before trying a risky approach. If it doesn't work, your original session is untouched.

```
Terminal 1: /fork → continues experimenting
Terminal 2: resume original session → try a different approach
```

## Context & Memory

### `/memory` — Check Loaded Files
Shows which files are loaded into Claude's context (CLAUDE.md, skills, etc.).

**When to use**:
- Regularly — you might have stale CLAUDE.md files eating context
- When Claude seems to have wrong assumptions about the project
- After making changes to CLAUDE.md or skills

### `/context` — Inspect Context Window
Shows what's in your current context window and how much space it takes.

**When to use**:
- Before complex tasks — ensure nothing unnecessary is loaded
- When responses seem slow — large context = slower processing
- Debugging unexpected Claude behavior

## Configuration

### `/config` — Browse Settings
Interactive configuration browser. Explore and change:
- **Output mode**: Default, quiet, verbose, or *explanatory mode*
- **Notifications**: Desktop notifications when tasks complete or permission is needed
- **Theme**: Terminal color scheme
- **Model**: Switch between Sonnet, Opus, Haiku
- **Permissions**: What Claude can do without asking
- **Auto-memory**: Persist learnings across sessions

### Explanatory Mode (Personal Recommendation)
Enable via `/config` → Output mode → Explanatory.

In this mode, Claude shares small, useful insights with every response — things like "I used Grep instead of reading the full file because..." or "This function uses the strategy pattern, which means..."

These micro-insights compound over time. After a week, you'll have picked up dozens of useful patterns and Claude Code techniques you wouldn't have discovered otherwise.

### `/insights` — Get Workflow Suggestions
After some usage, Claude analyzes your patterns and suggests improvements.

**When to use**: After a week of regular usage. Claude might suggest:
- Skills you should create based on repeated instructions
- Hooks that would automate your common workflows
- CLAUDE.md improvements based on what you keep telling Claude

## Multi-Directory & Browser

### `/add-dir` — Add Another Directory
Add another directory to the current session. Work across multiple repos simultaneously.

**Use cases**:
- Monorepo: add the shared packages directory
- Cross-repo changes: update API and SDK simultaneously
- Reference: keep documentation repo open while coding

### Claude in Chrome
Claude Code can interact with browsers for visual workflows:

1. Open Chrome and navigate to a page
2. Claude takes a screenshot
3. Compare against Figma designs (via MCP)
4. Identify pixel-perfect differences

**Use case**: "Open the deployed app, screenshot the login page, and compare it against the Figma mockup" — Claude identifies visual discrepancies.

## Session Resumption

### Resume Old Conversations
You can resume previous Claude Code conversations:

```
/resume                   # Browse previous conversations and pick one to resume
```

You can also use `claude --resume` or `claude --resume <id>` from the terminal if you know the conversation ID.

**When to use**:
- Continue work from yesterday
- Pick up where a colleague left off
- Return to a conversation after a distraction

### Combined with `/fork`
1. Start a session, do some exploration
2. `/fork` to experiment with approach A
3. Later, resume the original session for approach B
4. Compare results

## Slash Commands (Custom)

Custom commands live in `.claude/commands/` and are invoked with `/<name>`:

```
/review-pr 42        → Run the review-pr command with argument "42"
/plan add auth       → Run the plan command with argument "add auth"
/tdd user service    → Run the tdd command with argument "user service"
```

See [the commands directory](../.claude/commands/) for examples.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current generation |
| `Ctrl+B` | Send current task to background |
| `Ctrl+S` | Stash/restore current input |
| `Ctrl+D` | Exit Claude Code |
| `Up/Down` | Navigate command history |
| `Tab` | Autocomplete file paths and commands |

**`Ctrl+B` — Background Tasks**: Start a long task, press Ctrl+B to send it to the background, and continue working. You'll be notified when it completes.

**`Ctrl+S` — Stash Input**: Halfway through typing a prompt and need to do something else? Press Ctrl+S to stash your current input, handle the interruption, then press Ctrl+S again to restore it.

