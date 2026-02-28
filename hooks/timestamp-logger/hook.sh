#!/usr/bin/env bash
set -euo pipefail

LOG_FILE=".claude/tool-usage.log"
mkdir -p .claude

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Tool: ${CLAUDE_TOOL_NAME:-unknown} | Session: ${CLAUDE_SESSION_ID:-unknown}" >> "$LOG_FILE"
exit 0
