# Auto-Lint Hook

Runs ESLint with auto-fix on changed JavaScript/TypeScript files after edits.

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
        "hooks": ["bash hooks/auto-lint/hook.sh"]
      }
    ]
  }
}
```

## Why This Exists
Linting catches style issues and potential bugs early. Running automatically after edits keeps code consistently formatted without manual intervention.
