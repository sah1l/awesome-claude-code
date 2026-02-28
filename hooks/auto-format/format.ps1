# Auto-Format Hook — formats files after Claude writes or edits them
# Event: PostToolUse (Write, Edit)
#
# WHY: Claude writes clean code, but every project has its own formatting rules.
# Running the formatter automatically ensures consistency without manual passes.

$ErrorActionPreference = "SilentlyContinue"

# Extract the file path from CLAUDE_TOOL_INPUT (JSON)
try {
    $toolInput = $env:CLAUDE_TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    exit 0
}

if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }

# Get file extension
$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.')

# --- Formatter Detection & Execution ---

# Prettier (JS, TS, CSS, HTML, JSON, YAML, MD)
$hasPrettier = (Test-Path ".prettierrc") -or (Test-Path ".prettierrc.js") -or
               (Test-Path ".prettierrc.json") -or (Test-Path "prettier.config.js")

if (-not $hasPrettier -and (Test-Path "package.json")) {
    $pkg = Get-Content "package.json" -Raw
    if ($pkg -match '"prettier"') { $hasPrettier = $true }
}

if ($hasPrettier) {
    $prettierExts = @('js','jsx','ts','tsx','css','scss','html','json','yaml','yml','md')
    if ($ext -in $prettierExts) {
        npx prettier --write $filePath 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Output "Formatted with Prettier: $filePath" }
        exit 0
    }
}

# Black (Python)
if ($ext -eq 'py') {
    $hasBlack = $false
    if (Test-Path "pyproject.toml") {
        $content = Get-Content "pyproject.toml" -Raw
        if ($content -match '\[tool\.black\]') { $hasBlack = $true }
    }
    if ($hasBlack -or (Get-Command black -ErrorAction SilentlyContinue)) {
        python -m black $filePath 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Output "Formatted with Black: $filePath" }
        exit 0
    }
}

# rustfmt (Rust)
if ($ext -eq 'rs' -and (Get-Command rustfmt -ErrorAction SilentlyContinue)) {
    rustfmt $filePath 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Output "Formatted with rustfmt: $filePath" }
    exit 0
}

# gofmt (Go)
if ($ext -eq 'go' -and (Get-Command gofmt -ErrorAction SilentlyContinue)) {
    gofmt -w $filePath 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Output "Formatted with gofmt: $filePath" }
    exit 0
}

# clang-format (C, C++, Java)
if ((Test-Path ".clang-format") -and (Get-Command clang-format -ErrorAction SilentlyContinue)) {
    $clangExts = @('c','cpp','cc','cxx','h','hpp','java')
    if ($ext -in $clangExts) {
        clang-format -i $filePath 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Output "Formatted with clang-format: $filePath" }
        exit 0
    }
}

# No formatter detected — silent exit
exit 0
