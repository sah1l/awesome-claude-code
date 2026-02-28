# Secret Guard Hook
# Blocks git add/commit if staged files contain potential secrets.
$ErrorActionPreference = "SilentlyContinue"

try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $command = [string]$toolInput.command
} catch {
    exit 0
}

if (-not $command) { exit 0 }
if ($command -notmatch 'git\s+(commit|add)') { exit 0 }

$staged = git diff --cached --name-only 2>$null
if (-not $staged) { exit 0 }

$pattern = '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{48}|-----BEGIN.*PRIVATE KEY|password\s*=\s*["''][^"'']+)'
foreach ($file in ($staged -split "`n")) {
    $f = $file.Trim()
    if (-not $f) { continue }
    if (-not (Test-Path $f)) { continue }

    $content = Get-Content $f -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match $pattern) {
        Write-Output "BLOCKED: Potential secret detected in staged file: $f"
        Write-Output "Review the file and remove secrets before committing"
        exit 1
    }
}

exit 0
