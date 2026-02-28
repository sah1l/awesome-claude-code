# Code Review Standards

## Why This Skill Exists
Code reviews are the highest-leverage quality practice — but only when feedback is actionable and categorized by severity. Conventional Comments eliminate the ambiguity of "maybe consider..." style feedback.

## Conventional Comments Format

Every review comment MUST use this format:

```
<label>: <subject>

<optional body — reasoning, links, examples>
```

### Labels (ordered by severity)

| Label | Meaning | Blocking? |
|-------|---------|-----------|
| `blocker` | Must fix before merge — bugs, security issues, data loss | Yes |
| `issue` | Should fix — logic errors, missing edge cases | Yes |
| `suggestion` | Improvement worth considering — better patterns, readability | No |
| `nitpick` | Style/formatting preference — take it or leave it | No |
| `question` | Seeking clarification — not necessarily wrong | No |
| `praise` | Highlighting good work — important for morale | No |
| `thought` | Open-ended idea for future consideration | No |

### Review Modes

**Quick Review** — scan for blockers and issues only. Use for small PRs, hotfixes, or time-constrained reviews.

**Deep Review** — full analysis including suggestions, performance, security, and architecture. Use for feature PRs and significant changes.

### Rules
1. Always state the label first — the author should know severity at a glance
2. Explain WHY, not just WHAT — "this could NPE" → "this could NPE because `user` is nullable when fetched from cache (see UserCache.ts:47)"
3. Offer alternatives — don't just criticize, show a better way
4. One comment per concern — don't bundle unrelated feedback
5. Praise good code — reinforces patterns you want to see more of

See [examples.md](examples.md) for annotated review comment examples.
