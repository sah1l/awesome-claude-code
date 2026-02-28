#!/usr/bin/env bash
# Pre-Commit Guard — blocks dangerous Bash commands before execution
# Event: PreToolUse (Bash)
set -euo pipefail

COMMAND=""
if command -v python3 >/dev/null 2>&1; then
  COMMAND="$(python3 - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    print(data.get('command', '') or '')
except Exception:
    print('')
PY
)"
elif command -v python >/dev/null 2>&1; then
  COMMAND="$(python - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    print(data.get('command', '') or '')
except Exception:
    print('')
PY
)"
fi

if [ -z "$COMMAND" ]; then
    exit 0
fi

CMD_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

if echo "$CMD_LOWER" | grep -qE 'rm\s+(-[a-z]*f[a-z]*\s+)?(/|~|\$home)\b'; then
    echo "BLOCKED: Recursive deletion of root or home directory"
    echo "Command: $COMMAND"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE 'git\s+push\s+.*--force.*\b(main|master|develop|release)\b'; then
    echo "BLOCKED: Force-push to protected branch"
    echo "Command: $COMMAND"
    echo "Use --force-with-lease on feature branches only"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE 'git\s+push\s+.*\b(main|master|develop|release)\b.*--force'; then
    echo "BLOCKED: Force-push to protected branch"
    echo "Command: $COMMAND"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE '>\s*\.env\b'; then
    echo "BLOCKED: Writing to .env file via redirect"
    echo "Command: $COMMAND"
    echo "Edit .env files manually to avoid credential exposure"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE '\b(drop\s+(table|database|schema)|truncate\s+table|delete\s+from\s+\w+\s*;?\s*$)'; then
    echo "BLOCKED: Destructive SQL operation"
    echo "Command: $COMMAND"
    echo "Run destructive SQL manually with explicit confirmation"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE 'chmod\s+777'; then
    echo "BLOCKED: chmod 777 is a security risk"
    echo "Command: $COMMAND"
    echo "Use specific permissions (e.g., chmod 644 for files, 755 for directories)"
    exit 1
fi

if echo "$CMD_LOWER" | grep -qE 'git\s+reset\s+--hard\s*$'; then
    echo "BLOCKED: git reset --hard without target"
    echo "Command: $COMMAND"
    echo "Specify a target: git reset --hard HEAD~1 or git reset --hard origin/main"
    exit 1
fi

exit 0
