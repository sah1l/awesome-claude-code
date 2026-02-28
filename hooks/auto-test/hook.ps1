# Auto-Test Hook
# Runs related tests after Claude modifies implementation files.
$ErrorActionPreference = "SilentlyContinue"

try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    exit 0
}

if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }
if ($filePath -match '\.(test|spec)\.(ts|tsx|js|jsx)$') { exit 0 }

$dir = Split-Path $filePath -Parent
$base = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.')

$testCandidates = @(
    (Join-Path $dir "$base.test.$ext"),
    (Join-Path $dir "$base.spec.$ext"),
    (Join-Path (Join-Path $dir "__tests__") "$base.test.$ext")
)

foreach ($testFile in $testCandidates) {
    if (Test-Path $testFile) {
        Write-Output "Running related test: $testFile"
        npx vitest run $testFile 2>$null
        if ($LASTEXITCODE -ne 0) {
            npx jest $testFile 2>$null
        }
        exit 0
    }
}

exit 0
