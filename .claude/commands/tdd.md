# /tdd — Test-Driven Development Loop

## Description
Implements features using the Red-Green-Refactor cycle: write a failing test first, implement the minimum code to pass, then refactor. Enforces the discipline of TDD even when it's tempting to skip ahead.

## Usage
```
/tdd $ARGUMENTS
```
Where `$ARGUMENTS` describes the feature or behavior to implement.

## Workflow

### Phase 1: Red — Write Failing Test
1. Use the test-writer agent to detect the project's test framework
2. Study existing test conventions in the project
3. Write a test that describes the desired behavior — it MUST fail initially
4. Run the test to confirm it fails (red)

```bash
# Example: confirm the test fails
npm test -- --testPathPattern="new-feature"
```

### Phase 2: Green — Make It Pass
1. Write the minimum implementation code to make the test pass
2. Do NOT write more than what's needed — resist gold-plating
3. Run the test to confirm it passes (green)

```bash
# Example: confirm the test passes
npm test -- --testPathPattern="new-feature"
```

### Phase 3: Refactor — Clean Up
1. Use the code-simplifier agent to review the implementation
2. Apply any simplifications while keeping tests green
3. Run the full test suite to catch regressions

```bash
# Example: run full suite
npm test
```

### Phase 4: Repeat
If the feature has more behaviors to cover, repeat from Phase 1 with the next test case.

## Output Format

```markdown
## TDD Cycle Complete

### Tests Written
| Test | Status |
|------|--------|
| `createUser_withValidData_returnsUser` | Green |
| `createUser_withDuplicateEmail_throwsError` | Green |
| `createUser_withMissingName_validatesInput` | Green |

### Implementation
- **File**: `src/services/user-service.ts`
- **Lines added**: 35
- **Refactoring applied**: Extracted validation to guard clauses

### Test Run
All X tests passing. 0 failures.
```

## Why TDD?
- Tests are guaranteed to exist (they're written first)
- Tests actually test something meaningful (they fail before the code exists)
- Implementation stays minimal (no speculative code)
- Refactoring is safe (tests catch regressions immediately)
