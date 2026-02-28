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

# Skip if the edited file IS a test
if echo "$FILE_PATH" | grep -qE '\.(test|spec)\.(ts|tsx|js|jsx)$'; then exit 0; fi

# Look for corresponding test file
DIR=$(dirname "$FILE_PATH")
BASE=$(basename "$FILE_PATH" | sed 's/\.[^.]*$//')
EXT="${FILE_PATH##*.}"

for TEST_FILE in "$DIR/$BASE.test.$EXT" "$DIR/$BASE.spec.$EXT" "$DIR/__tests__/$BASE.test.$EXT"; do
    if [ -f "$TEST_FILE" ]; then
        echo "Running related test: $TEST_FILE"
        npx vitest run "$TEST_FILE" 2>/dev/null || npx jest "$TEST_FILE" 2>/dev/null || true
        exit 0
    fi
done

# No test file found — silent exit
exit 0
