# Auto-Format Hook

## What It Does
A `PostToolUse` hook that automatically formats files after Claude writes or edits them. Detects the project's formatter and runs it on the changed file.

## Why It Exists
Claude writes clean code, but every project has its own formatting rules (indentation, quotes, semicolons, line length). Running the formatter after every edit ensures Claude's output matches the project's style — no manual formatting passes needed.

## Supported Formatters

| Detected By | Formatter | Languages |
|-------------|-----------|-----------|
| `.prettierrc*`, `package.json > prettier` | Prettier | JS, TS, CSS, HTML, JSON, YAML, MD |
| `pyproject.toml [tool.black]`, `setup.cfg` | Black | Python |
| `rustfmt.toml`, `Cargo.toml` | rustfmt | Rust |
| `go.mod` | gofmt | Go |
| `.clang-format` | clang-format | C, C++, Java |

## How It Works
1. Receives the file path from `$CLAUDE_TOOL_INPUT` (for Write/Edit tools)
2. Detects the formatter by checking for configuration files
3. Runs the formatter on the specific changed file
4. If no formatter is detected, exits silently (no-op)

## Installation

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": ["bash hooks/auto-format/format.sh"]
      }
    ]
  }
}
```
