# Pre-Commit Guard — blocks dangerous Bash commands before execution
# Event: PreToolUse (Bash)
#
# WHY: Defense-in-depth. Claude is cautious by default, but a guard hook
# catches dangerous commands even if they slip through — especially important
# when running in autonomous/yolo mode.

$ErrorActionPreference = "Stop"

# Extract the command from CLAUDE_TOOL_INPUT (JSON)
try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $command = $toolInput.command
} catch {
    exit 0
}

if (-not $command) { exit 0 }

$cmdLower = $command.ToLower()

# --- Dangerous Pattern Checks ---

# 1. Catastrophic deletions
if ($cmdLower -match 'rm\s+(-[a-z]*f[a-z]*\s+)?(/|~|\$home)\b') {
    Write-Output "BLOCKED: Recursive deletion of root or home directory"
    Write-Output "Command: $command"
    exit 1
}

# 2. Force-push to protected branches
if ($cmdLower -match 'git\s+push\s+.*--force.*\b(main|master|develop|release)\b') {
    Write-Output "BLOCKED: Force-push to protected branch"
    Write-Output "Command: $command"
    Write-Output "Use --force-with-lease on feature branches only"
    exit 1
}

if ($cmdLower -match 'git\s+push\s+.*\b(main|master|develop|release)\b.*--force') {
    Write-Output "BLOCKED: Force-push to protected branch"
    Write-Output "Command: $command"
    exit 1
}

# 3. Writing to .env files
if ($cmdLower -match '>\s*\.env\b') {
    Write-Output "BLOCKED: Writing to .env file via redirect"
    Write-Output "Command: $command"
    Write-Output "Edit .env files manually to avoid credential exposure"
    exit 1
}

# 4. SQL destructive operations
if ($cmdLower -match '\b(drop\s+(table|database|schema)|truncate\s+table|delete\s+from\s+\w+\s*;?\s*$)') {
    Write-Output "BLOCKED: Destructive SQL operation"
    Write-Output "Command: $command"
    Write-Output "Run destructive SQL manually with explicit confirmation"
    exit 1
}

# 5. Dangerous permission changes
if ($cmdLower -match 'chmod\s+777') {
    Write-Output "BLOCKED: chmod 777 is a security risk"
    Write-Output "Command: $command"
    Write-Output "Use specific permissions (e.g., chmod 644 for files, 755 for directories)"
    exit 1
}

# 6. Git reset --hard without target
if ($cmdLower -match 'git\s+reset\s+--hard\s*$') {
    Write-Output "BLOCKED: git reset --hard without target"
    Write-Output "Command: $command"
    Write-Output "Specify a target: git reset --hard HEAD~1 or git reset --hard origin/main"
    exit 1
}

# All checks passed
exit 0
