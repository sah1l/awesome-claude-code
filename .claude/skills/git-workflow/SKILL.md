# Git Workflow

## Why This Skill Exists
Git conventions prevent merge conflicts, lost work, and deployment accidents. These patterns scale from solo projects to large teams without adding ceremony.

## Branch Naming

```
<type>/<ticket>-<short-description>
```

| Type | When |
|------|------|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Code restructuring |
| `chore/` | Build, CI, dependencies |
| `docs/` | Documentation |
| `test/` | Test additions/fixes |

Examples:
- `feat/AUTH-42-email-verification`
- `fix/PAY-108-duplicate-charge`
- `chore/upgrade-node-22`

### Rules
- Lowercase, hyphen-separated
- Include ticket number when available
- Keep under 50 characters
- Branch from `main` (or `develop` if using gitflow)

## Merge Strategy

**Squash merge to main** — keeps main history clean, each commit = one feature/fix.

```bash
# On GitHub: "Squash and merge" button
# Locally:
git checkout main
git merge --squash feat/AUTH-42-email-verification
git commit  # write a clean summary
```

**Exception**: For large features with meaningful internal commits, use a regular merge to preserve history.

## Pull Request Template

```markdown
## What
<!-- One-liner: what does this PR do? -->

## Why
<!-- What problem does it solve? Link to issue/ticket. -->

## How
<!-- Brief description of the approach. Highlight non-obvious decisions. -->

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing done (describe scenario)

## Screenshots
<!-- If UI changes, before/after screenshots -->
```

## Commit Hygiene
- Commit early, commit often on feature branches
- Squash before merge to main
- Never commit: `.env`, credentials, large binaries, build artifacts
- See [commit skill](../commit/SKILL.md) for message format

## Conflict Resolution
1. `git fetch origin main`
2. `git rebase origin/main` (for feature branches)
3. Resolve conflicts, maintaining the intent of both changes
4. `git rebase --continue`
5. Force-push feature branch only: `git push --force-with-lease`

**Never force-push to main/develop/release branches.**
