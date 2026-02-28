# Auto-Lint Hook
# Runs ESLint with auto-fix on changed JavaScript/TypeScript files.
$ErrorActionPreference = "SilentlyContinue"

try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    exit 0
}

if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }

$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.').ToLowerInvariant()
if ($ext -in @('js','jsx','ts','tsx')) {
    npx eslint --fix $filePath 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Output "Linted: $filePath" }
}

exit 0
