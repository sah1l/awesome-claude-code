# Timestamp Logger Hook
# Logs each tool invocation with timestamp for lightweight auditing.
$ErrorActionPreference = "SilentlyContinue"

$logDir = ".claude"
$logFile = Join-Path $logDir "tool-usage.log"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$toolName = if ($env:CLAUDE_TOOL_NAME) { $env:CLAUDE_TOOL_NAME } else { "unknown" }
$sessionId = if ($env:CLAUDE_SESSION_ID) { $env:CLAUDE_SESSION_ID } else { "unknown" }

Add-Content -Path $logFile -Value "[$timestamp] Tool: $toolName | Session: $sessionId"
exit 0
