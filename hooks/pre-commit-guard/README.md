# Pre-Commit Guard

## What It Does
A `PreToolUse` hook that intercepts Bash commands before they execute, blocking dangerous operations that could cause data loss or affect shared branches.

## Why It Exists
Claude Code can run arbitrary shell commands. While it's cautious by default, a well-configured guard hook provides defense-in-depth — catching dangerous commands even if they slip through Claude's own safety checks.

## What It Blocks

| Pattern | Risk | Example |
|---------|------|---------|
| `rm -rf /` or `rm -rf ~` | Catastrophic data loss | `rm -rf /` |
| Force-push to main/master | Overwrites shared history | `git push --force origin main` |
| `.env` file writes | Credential exposure | `echo SECRET=x > .env` |
| `DROP TABLE` / `DROP DATABASE` | Data destruction | `psql -c "DROP TABLE users"` |
| `chmod 777` | Security misconfiguration | `chmod 777 /etc/passwd` |

## How It Works
The hook receives the Bash command via `$CLAUDE_TOOL_INPUT`, parses it, and checks against a blocklist of dangerous patterns. If a match is found, it exits with a non-zero code and prints an explanation — Claude will see the rejection and adjust its approach.

## Installation

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["bash hooks/pre-commit-guard/guard.sh"]
      }
    ]
  }
}
```
