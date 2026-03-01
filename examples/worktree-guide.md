# Git Worktrees for Parallel Development

## What Are Worktrees?

Git worktrees let you have multiple branches checked out simultaneously in different directories. Instead of stashing or committing WIP to switch branches, you open a new worktree and work on both in parallel.

Claude Code has first-class worktree support via the `--worktree` CLI flag — it creates an isolated working copy inside `.claude/worktrees/` and starts a session there automatically.

## Why Use Worktrees?

| Scenario | Without Worktrees | With Worktrees |
|----------|------------------|----------------|
| Urgent hotfix while mid-feature | `git stash` → switch → fix → switch back → `git stash pop` (pray for no conflicts) | Open new worktree → fix → merge → continue feature |
| Review a PR while coding | Stop, commit WIP, checkout PR branch | Open worktree for PR, review, close it |
| Run two Claude sessions on different features | Impossible (same checkout) | Each session in its own worktree |
| Compare behavior between branches | Toggle branches, lose running state | Both branches running simultaneously |

## How It Works in Claude Code

### Creating a Worktree

Use the `--worktree` (or `-w`) flag when launching Claude:

```bash
# Create a named worktree
claude --worktree feature-auth

# Shorthand
claude -w feature-auth

# Auto-generate a random name (e.g. "bright-running-fox")
claude --worktree
```

This does three things:
1. Creates `.claude/worktrees/feature-auth/` — a full isolated copy of your repo
2. Creates a `worktree-feature-auth` branch based on the default remote branch
3. Starts a Claude session with its working directory set to the new worktree

> **Tip**: Add `.claude/worktrees/` to your `.gitignore` so worktree contents don't show as untracked files.

### Automatic Cleanup

When you exit a worktree session, Claude handles cleanup based on what happened:

- **No changes made** — worktree directory and branch are removed automatically
- **Changes or commits exist** — Claude prompts you to keep or remove:
  - **Keep**: Preserves the directory and branch so you can return later
  - **Remove**: Deletes the worktree and its branch (discards all work)

### Manual Worktree Commands

You can also use native Git worktree commands directly:

```bash
# Create a worktree for a hotfix
git worktree add ../hotfix-payment fix/payment-bug

# Create a worktree from a remote branch (PR review)
git worktree add ../pr-review origin/feat/new-dashboard

# List all worktrees
git worktree list

# Remove a worktree when done
git worktree remove ../hotfix-payment
```

## Worktree Hooks

Claude Code provides two hooks for customizing worktree behavior. These are especially useful for copying environment files, initializing tooling, or supporting non-Git VCS.

### WorktreeCreate

Fires when `claude --worktree` is run or a subagent uses `isolation: "worktree"`.

- **Blocking**: Yes — a non-zero exit code prevents worktree creation
- **Must return**: The absolute path to the created worktree on stdout

**Input (piped as JSON to stdin):**
```json
{
  "session_id": "abc123",
  "hook_event_name": "WorktreeCreate",
  "cwd": "/home/user/project",
  "name": "feature-auth"
}
```

#### Example: Copy `.env` files into new worktrees

Most projects have `.gitignore`'d files (`.env`, `.env.local`, certs, etc.) that won't exist in a fresh worktree. This hook copies them automatically.

Add to `.claude/settings.json`:
```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash hooks/worktree-create/setup.sh"
          }
        ]
      }
    ]
  }
}
```

`hooks/worktree-create/setup.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Read hook input
INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

WORKTREE_DIR="$CWD/.claude/worktrees/$NAME"

# Let Git create the worktree first (default behavior)
git worktree add "$WORKTREE_DIR" -b "worktree-$NAME" >&2

# Copy gitignored environment files
for f in .env .env.local .env.development; do
  if [ -f "$CWD/$f" ]; then
    cp "$CWD/$f" "$WORKTREE_DIR/$f"
    echo "Copied $f to worktree" >&2
  fi
done

# Copy other project-specific files that aren't tracked
[ -f "$CWD/certs/local.pem" ] && {
  mkdir -p "$WORKTREE_DIR/certs"
  cp "$CWD/certs/local.pem" "$WORKTREE_DIR/certs/"
}

# MUST print the worktree path to stdout
echo "$WORKTREE_DIR"
```

#### Example: Install dependencies in new worktrees

If your project has `node_modules/` or Python venvs that are gitignored:

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

WORKTREE_DIR="$CWD/.claude/worktrees/$NAME"

git worktree add "$WORKTREE_DIR" -b "worktree-$NAME" >&2

# Install dependencies so the worktree is ready to run
if [ -f "$WORKTREE_DIR/package.json" ]; then
  echo "Installing npm dependencies..." >&2
  (cd "$WORKTREE_DIR" && npm install --silent) >&2
fi

echo "$WORKTREE_DIR"
```

#### Example: Non-Git VCS (SVN)

WorktreeCreate hooks replace the default Git behavior entirely, so you can use them with SVN, Perforce, or Mercurial:

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name')
DIR="$HOME/.claude/worktrees/$NAME"

svn checkout https://svn.example.com/repo/trunk "$DIR" >&2
echo "$DIR"
```

### WorktreeRemove

Fires when a worktree is being removed (on session exit or when a subagent finishes).

- **Blocking**: No — failures are logged but don't prevent removal
- **Returns**: Nothing required

**Input (piped as JSON to stdin):**
```json
{
  "session_id": "abc123",
  "hook_event_name": "WorktreeRemove",
  "cwd": "/home/user/project",
  "worktree_path": "/home/user/project/.claude/worktrees/feature-auth"
}
```

#### Example: Archive worktree changes before removal

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')
CWD=$(echo "$INPUT" | jq -r '.cwd')
NAME=$(basename "$WORKTREE_PATH")

# Save a patch of any uncommitted changes before the worktree is deleted
if [ -d "$WORKTREE_PATH" ]; then
  DIFF=$(cd "$WORKTREE_PATH" && git diff HEAD 2>/dev/null || true)
  if [ -n "$DIFF" ]; then
    mkdir -p "$CWD/.claude/worktree-archives"
    echo "$DIFF" > "$CWD/.claude/worktree-archives/$NAME-$(date +%s).patch"
    echo "Archived uncommitted changes" >&2
  fi
fi
```

### Hook Summary

| Hook | Can Block? | Must Return | Use Case |
|------|-----------|-------------|----------|
| **WorktreeCreate** | Yes | Absolute path (stdout) | Copy .env files, install deps, non-Git VCS |
| **WorktreeRemove** | No | Nothing | Archive changes, cleanup temp files |

## Practical Patterns

### Pattern 1: Parallel Claude Sessions

```bash
# Terminal 1 — main feature work
cd ~/projects/myapp
claude  # Working on feat/user-dashboard

# Terminal 2 — urgent bug fix (isolated worktree)
cd ~/projects/myapp
claude --worktree hotfix-payment
# Now working in .claude/worktrees/hotfix-payment/
# with its own worktree-hotfix-payment branch
```

### Pattern 2: PR Review Without Context Switching

```bash
# Start a worktree session for the review
claude -w review-pr-42

# Inside the session, check out the PR branch and review
# > git fetch origin feat/new-auth
# > git checkout feat/new-auth
# > /review-pr

# When you exit, Claude cleans up automatically
```

### Pattern 3: Safe Experimentation

```bash
# Try a risky refactor in an isolated worktree
claude --worktree experiment-new-arch

# Experiment freely — if it fails, exit and choose "Remove"
# Your main checkout is completely untouched
```

### Pattern 4: Subagent Isolation

Subagents can also run in worktrees via the `isolation: "worktree"` parameter. This is useful for parallel agent tasks that might modify files:

```
Launch three agents in parallel, each in its own worktree,
to prototype three different approaches to the auth system.
```

Each subagent gets its own worktree that is automatically cleaned up when it finishes without changes.

## Worktree Best Practices

1. **Name worktrees descriptively**: `claude -w hotfix-payment`, not `claude -w temp`
2. **Commit before exiting**: If your work matters, commit it — uncommitted changes are lost on removal
3. **Don't share branches**: Each worktree should have its own branch
4. **Worktrees share the git database**: Commits in one worktree are visible to all (after `git fetch`)
5. **Watch for lock files**: If a worktree is removed uncleanly, run `git worktree prune`
6. **Use WorktreeCreate hooks**: Automate copying `.env` files and installing dependencies — saves time every session

## Limitations

- A branch can only be checked out in one worktree at a time
- Worktrees share the same `.git` database — large repos have one copy, not N
- Submodules may need re-initialization in new worktrees
- Some IDE extensions don't handle multiple worktrees well
- Gitignored files (`.env`, `node_modules/`) don't exist in fresh worktrees — use WorktreeCreate hooks to solve this
