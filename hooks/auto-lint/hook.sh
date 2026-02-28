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

EXT="${FILE_PATH##*.}"
case "$EXT" in
    js|jsx|ts|tsx)
        npx eslint --fix "$FILE_PATH" 2>/dev/null && echo "Linted: $FILE_PATH"
        ;;
esac
exit 0
