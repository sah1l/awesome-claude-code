# Git Diff Summary Hook
# Shows a quick diff summary after file edits.
$ErrorActionPreference = "SilentlyContinue"

try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    exit 0
}

if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }

git ls-files --error-unmatch $filePath *> $null
if ($LASTEXITCODE -eq 0) {
    $diff = git diff --stat $filePath 2>$null
    if ($diff) {
        Write-Output "Changes: $diff"
    }
}

exit 0
