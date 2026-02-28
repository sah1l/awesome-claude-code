# /build-fix — Auto-Detect & Fix Build Errors

## Description
Detects the project's build system, runs the build, parses errors, and iteratively fixes them. Handles the tedious cycle of "fix one error, reveal the next" automatically. Stops after 3 failed attempts to prevent infinite loops.

## Usage
```
/build-fix
```

No arguments needed — the command auto-detects everything.

## Workflow

### Step 1: Detect Build System
Check for build configuration in this order:

| Check | Build Command |
|-------|--------------|
| `package.json > scripts.build` | `npm run build` |
| `tsconfig.json` | `npx tsc --noEmit` |
| `Makefile` | `make` |
| `Cargo.toml` | `cargo build` |
| `go.mod` | `go build ./...` |
| `pyproject.toml` | `python -m build` |
| `build.gradle` / `pom.xml` | `./gradlew build` / `mvn compile` |

### Step 2: Run Build
Execute the detected build command and capture output.

### Step 3: Parse Errors
Extract structured error information:
- File path
- Line number
- Error message
- Error code (if available)

### Step 4: Fix Errors
For each error (starting with the first — later errors may cascade):
1. Read the file at the error location
2. Understand the error in context
3. Apply the fix using Edit
4. Move to the next error

### Step 5: Retry (Max 3 Attempts)
1. Run the build again
2. If new errors appear, fix them (attempt 2)
3. Run the build one more time (attempt 3)
4. If still failing after 3 attempts, report remaining errors and stop

### Step 6: Report

```markdown
## Build Fix Report

### Build System
[detected build system and command]

### Attempt 1
- Errors found: X
- Errors fixed: Y
- [list of fixes applied]

### Attempt 2
- Errors found: X
- Errors fixed: Y
- [list of fixes applied]

### Result
Build succeeded / Build still failing

### Remaining Issues (if any)
[errors that couldn't be auto-fixed — need human attention]
```

## Why Max 3 Attempts?
- Most build errors cascade — fixing the first one often resolves 5 others
- If errors persist after 3 rounds, they're likely architectural issues that need human judgment
- Prevents infinite fix-break-fix loops that waste time and context
