## Examples

### Good commit messages

```bash
feat: add email verification on signup

Prevents fake accounts from consuming API quota.
Verification link expires after 24h.
```

```bash
fix: handle null user in dashboard redirect
```

### Bad commit messages (to avoid)

```bash
Updated stuff              # vague, past tense
feat(auth): Add Login.     # unnecessary scope, capitalized, period
```

## $ARGUMENTS
When invoked with arguments, treat them as the change description and generate an appropriate commit message following these conventions.