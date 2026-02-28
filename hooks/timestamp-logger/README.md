# Timestamp Logger Hook

Logs every tool use with timestamp to a file for audit.

## Event
PostToolUse (all)

## Usage

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": ["bash hooks/timestamp-logger/hook.sh"]
      }
    ]
  }
}
```

## Why This Exists
Audit trail for debugging and understanding Claude's behavior over time. Useful for debugging issues or analyzing usage patterns.
