#!/usr/bin/env bash
set -euo pipefail

FILE_PATH=""
if command -v python3 >/dev/null 2>&1; then
  FILE_PATH="$(python3 - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    print(data.get('file_path', '') or '')
except Exception:
    print('')
PY
)"
elif command -v python >/dev/null 2>&1; then
  FILE_PATH="$(python - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    print(data.get('file_path', '') or '')
except Exception:
    print('')
PY
)"
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then exit 0; fi

# Only show diff if file is tracked by git
if git ls-files --error-unmatch "$FILE_PATH" &>/dev/null; then
    DIFF=$(git diff --stat "$FILE_PATH" 2>/dev/null || echo "")
    if [ -n "$DIFF" ]; then
        echo "Changes: $DIFF"
    fi
fi
exit 0
