#!/usr/bin/env bash
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

if ! echo "$COMMAND" | grep -Eq 'git\s+(commit|add)'; then
  exit 0
fi

STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
for FILE in $STAGED; do
  if [ -f "$FILE" ]; then
    if grep -qE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{48}|-----BEGIN.*PRIVATE KEY|password[[:space:]]*=[[:space:]]*['\''"][^'\''"]+)' "$FILE" 2>/dev/null; then
      echo "BLOCKED: Potential secret detected in staged file: $FILE"
      echo "Review the file and remove secrets before committing"
      exit 1
    fi
  fi
done

exit 0
