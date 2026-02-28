# /changelog — Generate Changelog from Git History

## Description
Reads git history and generates a changelog in [Keep a Changelog](https://keepachangelog.com/) format. Groups commits by type, links to PRs/issues, and handles version bumping.

## Usage
```
/changelog $ARGUMENTS
```
- `/changelog` — generate unreleased changes since last tag
- `/changelog v1.2.0` — generate changelog for a specific version
- `/changelog v1.1.0..v1.2.0` — generate changelog between two versions

## Workflow

### Step 1: Determine Range
```bash
# Find the latest tag
git describe --tags --abbrev=0

# Get commits since last tag (or between specified versions)
git log v1.1.0..HEAD --oneline --no-merges
```

### Step 2: Categorize Commits
Parse commit messages using conventional commit prefixes:

| Prefix | Changelog Section |
|--------|------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `refactor:` | Changed |
| `perf:` | Changed (Performance) |
| `docs:` | Documentation |
| `chore:` | Maintenance |
| `BREAKING CHANGE` | Breaking Changes (top of changelog) |

### Step 3: Enrich with Context
- Extract PR numbers from merge commits or commit messages
- Link to GitHub issues mentioned in commits
- Group related commits (e.g., multiple commits for one feature)

### Step 4: Generate Changelog

```markdown
# Changelog

## [1.2.0] - 2026-02-28

### Breaking Changes
- Removed deprecated `v1/auth` endpoint — migrate to `v2/auth` (#142)

### Added
- Email verification on signup (#128)
- Export to CSV for reports (#134)
- Rate limiting on public API endpoints (#139)

### Fixed
- Handle null user in dashboard redirect (#131)
- Prevent duplicate charge on payment retry (#136)

### Changed
- Migrate user search to Elasticsearch for performance (#133)
- Simplify error response format to match API conventions (#137)

### Documentation
- Add API authentication guide (#140)

### Maintenance
- Upgrade Node.js to v22 (#141)
- Update dependencies (#143)
```

### Step 5: Output
- If `CHANGELOG.md` exists, prepend the new version section
- If not, create a new `CHANGELOG.md` with the standard header
- Present the result to the user for review before writing

## Format Notes
- Follow [Keep a Changelog](https://keepachangelog.com/) format exactly
- Most recent version first
- Include dates in ISO format (YYYY-MM-DD)
- Link PR numbers to GitHub when repo URL is available
- If commits don't follow conventional commits, categorize by best guess based on the diff
