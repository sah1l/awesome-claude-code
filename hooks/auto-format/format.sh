#!/usr/bin/env bash
# Auto-Format Hook — formats files after Claude writes or edits them
# Event: PostToolUse (Write, Edit)
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

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

EXT="${FILE_PATH##*.}"

HAS_PRETTIER=false
if [ -f ".prettierrc" ] || [ -f ".prettierrc.js" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
    HAS_PRETTIER=true
elif [ -f "package.json" ] && grep -q '"prettier"' package.json; then
    HAS_PRETTIER=true
fi

if [ "$HAS_PRETTIER" = true ]; then
    case "$EXT" in
        js|jsx|ts|tsx|css|scss|html|json|yaml|yml|md)
            npx prettier --write "$FILE_PATH" 2>/dev/null && echo "Formatted with Prettier: $FILE_PATH"
            exit 0
            ;;
    esac
fi

if [ "$EXT" = "py" ] && ([ -f "pyproject.toml" ] || [ -f "setup.cfg" ] || command -v black >/dev/null 2>&1); then
    python -m black "$FILE_PATH" 2>/dev/null && echo "Formatted with Black: $FILE_PATH"
    exit 0
fi

if [ "$EXT" = "rs" ] && command -v rustfmt >/dev/null 2>&1; then
    rustfmt "$FILE_PATH" 2>/dev/null && echo "Formatted with rustfmt: $FILE_PATH"
    exit 0
fi

if [ "$EXT" = "go" ] && command -v gofmt >/dev/null 2>&1; then
    gofmt -w "$FILE_PATH" 2>/dev/null && echo "Formatted with gofmt: $FILE_PATH"
    exit 0
fi

if [ -f ".clang-format" ] && command -v clang-format >/dev/null 2>&1; then
    case "$EXT" in
        c|cpp|cc|cxx|h|hpp|java)
            clang-format -i "$FILE_PATH" 2>/dev/null && echo "Formatted with clang-format: $FILE_PATH"
            exit 0
            ;;
    esac
fi

exit 0
