# Block Large File Writes Hook
# Prevents Claude from writing files larger than 500 lines.
$ErrorActionPreference = "SilentlyContinue"
$maxLines = 500

try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $content = [string]$toolInput.content
} catch {
    exit 0
}

if (-not $content) { exit 0 }

$lineCount = ($content -split "`n").Count
if ($lineCount -gt $maxLines) {
    Write-Output "BLOCKED: File exceeds $maxLines lines ($lineCount lines)"
    Write-Output "Break the file into smaller modules or write it incrementally"
    exit 1
}

exit 0
