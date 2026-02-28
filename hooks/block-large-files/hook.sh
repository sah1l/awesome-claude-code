#!/usr/bin/env bash
set -euo pipefail

MAX_LINES=500
LINE_COUNT=0

if command -v python3 >/dev/null 2>&1; then
  LINE_COUNT="$(python3 - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    content = data.get('content', '') or ''
    print(content.count('\n') + (1 if content else 0))
except Exception:
    print(0)
PY
)"
elif command -v python >/dev/null 2>&1; then
  LINE_COUNT="$(python - <<'PY'
import json, os
raw = os.environ.get('CLAUDE_TOOL_INPUT', '{}')
try:
    data = json.loads(raw)
    content = data.get('content', '') or ''
    print(content.count('\n') + (1 if content else 0))
except Exception:
    print(0)
PY
)"
fi

if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
    echo "BLOCKED: File exceeds $MAX_LINES lines ($LINE_COUNT lines)"
    echo "Break the file into smaller modules or write it incrementally"
    exit 1
fi
exit 0
