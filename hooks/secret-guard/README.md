# Secret Guard Hook

Blocks git add/commit if staged files contain potential secrets.

## Event
PreToolUse (Bash)

## Usage

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["bash hooks/secret-guard/hook.sh"]
      }
    ]
  }
}
```

For PowerShell-based setups, use:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["powershell -File hooks/secret-guard/hook.ps1"]
      }
    ]
  }
}
```

## Why This Exists
Prevents accidental exposure of secrets (API keys, passwords, private keys) in git commits.
