# Hook Recipes

6 ready-to-use hook recipes. Copy the JSON to your `.claude/settings.json` and the scripts to your project.

---

## Recipe 1: Auto-Lint After Edits

**Event**: PostToolUse (Write, Edit)
**What**: Runs ESLint with auto-fix on changed files

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": ["bash hooks/auto-lint/hook.sh"]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# hooks/auto-lint/hook.sh
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | grep -oP '"file_path"\s*:\s*"(.*?)"' | sed 's/"file_path"\s*:\s*"//;s/"$//' || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then exit 0; fi

EXT="${FILE_PATH##*.}"
case "$EXT" in
    js|jsx|ts|tsx)
        npx eslint --fix "$FILE_PATH" 2>/dev/null && echo "Linted: $FILE_PATH"
        ;;
esac
exit 0
```

---

## Recipe 2: Timestamp Logger

**Event**: PostToolUse (all)
**What**: Logs every tool use with timestamp to a file for audit

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": ["bash hooks/timestamp-logger/hook.sh"]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# hooks/timestamp-logger/hook.sh
LOG_FILE=".claude/tool-usage.log"
mkdir -p .claude
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Tool: ${CLAUDE_TOOL_NAME:-unknown} | Session: ${CLAUDE_SESSION_ID:-unknown}" >> "$LOG_FILE"
exit 0
```

---

## Recipe 3: Block Large File Writes

**Event**: PreToolUse (Write)
**What**: Prevents Claude from writing files larger than a threshold (e.g., 500 lines). Large files should be built incrementally.

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

```bash
#!/usr/bin/env bash
# hooks/block-large-files/hook.sh
set -euo pipefail

MAX_LINES=500

CONTENT=$(echo "$CLAUDE_TOOL_INPUT" | grep -oP '"content"\s*:\s*"(.*?)"' | head -1 || echo "")
LINE_COUNT=$(echo "$CONTENT" | grep -c '\\n' || echo "0")

if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
    echo "BLOCKED: File exceeds $MAX_LINES lines ($LINE_COUNT lines)"
    echo "Break the file into smaller modules or write it incrementally"
    exit 1
fi
exit 0
```

---

## Recipe 4: Git Diff Summary After Edits

**Event**: PostToolUse (Edit)
**What**: Shows a quick diff summary after each edit so you can track what changed

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

```bash
#!/usr/bin/env bash
# hooks/git-diff-summary/hook.sh
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | grep -oP '"file_path"\s*:\s*"(.*?)"' | sed 's/"file_path"\s*:\s*"//;s/"$//' || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then exit 0; fi

# Only show diff if file is tracked by git
if git ls-files --error-unmatch "$FILE_PATH" &>/dev/null; then
    DIFF=$(git diff --stat "$FILE_PATH" 2>/dev/null || echo "")
    if [ -n "$DIFF" ]; then
        echo "Changes: $DIFF"
    fi
fi
exit 0
```

---

## Recipe 5: Prevent Secret Commits

**Event**: PreToolUse (Bash)
**What**: Blocks `git add` or `git commit` if staged files contain potential secrets

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

```bash
#!/usr/bin/env bash
# hooks/secret-guard/hook.sh
set -euo pipefail

COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | grep -oP '"command"\s*:\s*"(.*?)"' | sed 's/"command"\s*:\s*"//;s/"$//' || echo "")

# Only check git commit/add commands
if ! echo "$COMMAND" | grep -qE 'git\s+(commit|add)'; then
    exit 0
fi

# Check staged files for secrets
STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
for FILE in $STAGED; do
    if [ -f "$FILE" ]; then
        if grep -qE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{48}|-----BEGIN.*PRIVATE KEY|password\s*=\s*['\''"][^'\''"]+)' "$FILE" 2>/dev/null; then
            echo "BLOCKED: Potential secret detected in staged file: $FILE"
            echo "Review the file and remove secrets before committing"
            exit 1
        fi
    fi
done
exit 0
```

---

## Recipe 6: Test Runner After Implementation

**Event**: PostToolUse (Write, Edit)
**What**: Automatically runs related tests after Claude modifies implementation files

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": ["bash hooks/auto-test/hook.sh"]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# hooks/auto-test/hook.sh
set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | grep -oP '"file_path"\s*:\s*"(.*?)"' | sed 's/"file_path"\s*:\s*"//;s/"$//' || echo "")

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
```

---

## Writing Your Own Hooks

### Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# Parse input
TOOL_INPUT="$CLAUDE_TOOL_INPUT"    # JSON string
TOOL_NAME="$CLAUDE_TOOL_NAME"      # e.g., "Bash", "Write", "Edit"
SESSION_ID="$CLAUDE_SESSION_ID"    # Unique session ID

# Your logic here
# ...

# Exit 0 = success (proceed), non-zero = block (PreToolUse) or warn (PostToolUse)
exit 0
```

### Guidelines
- **Always exit 0** unless you intentionally want to block an action
- **Fail gracefully** — if your hook can't parse input, exit 0 (don't break Claude)
- **Keep it fast** — hooks run synchronously, slow hooks = slow Claude
- **Log sparingly** — stdout goes to Claude as feedback
