# Hooks

## What Are Claude Code Hooks?

Hooks are shell commands that execute automatically in response to Claude Code events. They let you enforce rules, automate formatting, and integrate with external tools — without modifying Claude's behavior directly.

## How Hooks Work

Hooks are configured in `.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["bash hooks/pre-commit-guard/guard.sh"]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": ["bash hooks/auto-format/format.sh"]
      }
    ]
  }
}
```

## Hook Events

| Event | When It Fires | Use Cases |
|-------|--------------|-----------|
| `PreToolUse` | Before a tool executes | Block dangerous commands, validate inputs |
| `PostToolUse` | After a tool executes | Auto-format, lint, log changes |
| `Stop` | When Claude finishes a response | Summary logging, cleanup tasks |
| `PermissionRequest` | When Claude asks for permission | Audit logging, custom alerts |

## Hook Input

Hooks receive context via environment variables:

| Variable | Description |
|----------|-------------|
| `$CLAUDE_TOOL_NAME` | Name of the tool being used (e.g., "Bash", "Write") |
| `$CLAUDE_TOOL_INPUT` | JSON string of the tool's input parameters |
| `$CLAUDE_TOOL_OUTPUT` | (PostToolUse only) JSON string of the tool's output |
| `$CLAUDE_SESSION_ID` | Unique session identifier |

## Hook Output

- **Exit code 0**: Hook succeeded — proceed normally
- **Exit code non-zero**: Hook failed — block the action (PreToolUse) or log warning (PostToolUse)
- **stdout**: Displayed to Claude as feedback (use for error messages)

## Hooks in This Repo

| Hook | Event | Purpose |
|------|-------|---------|
| [pre-commit-guard](pre-commit-guard/) | PreToolUse (Bash) | Block dangerous commands |
| [auto-format](auto-format/) | PostToolUse (Write, Edit) | Auto-format changed files |

> **Note**: For desktop notifications, Claude Code has built-in support — run `/config` to find notification settings. No custom hook needed.

Each hook includes:
- `README.md` — what it does and why
- `*.sh` + `*.ps1` — cross-platform scripts where applicable

## Writing Your Own Hooks

1. Create a directory under `hooks/`
2. Write your script (always provide both `.sh` and `.ps1` for cross-platform support)
3. Add the hook configuration to `.claude/settings.json`
4. Test with a dry run before enabling

See [hook-recipes.md](../docs/hook-recipes.md) for 6 ready-to-use hook recipes.
