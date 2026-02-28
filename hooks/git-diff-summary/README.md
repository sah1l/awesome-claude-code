# Git Diff Summary Hook

Shows a quick diff summary after each edit so you can track what changed.

## Event
PostToolUse (Edit)

## Usage

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": ["bash hooks/git-diff-summary/hook.sh"]
      }
    ]
  }
}
```

## Why This Exists
Provides immediate feedback on what changed, helping you understand the impact of each edit without running a full git diff.
