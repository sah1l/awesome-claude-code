# Block Large File Writes Hook

Prevents Claude from writing files larger than 500 lines. Large files should be built incrementally.

## Event
PreToolUse (Write)

## Usage

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": ["bash hooks/block-large-files/hook.sh"]
      }
    ]
  }
}
```

## Why This Exists
Large files are harder to maintain and review. This hook encourages breaking files into smaller, focused modules.
