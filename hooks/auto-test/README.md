# Auto-Test Hook

Automatically runs related tests after Claude modifies implementation files.

## Event
PostToolUse (Write, Edit)

## Usage

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": ["bash hooks/auto-test/hook.sh"]
      }
    ]
  }
}
```

## Why This Exists
Provides immediate feedback on whether changes break existing functionality. Saves time by running relevant tests automatically.
