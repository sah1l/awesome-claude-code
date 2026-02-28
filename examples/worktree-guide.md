# Git Worktrees for Parallel Development

## What Are Worktrees?

Git worktrees let you have multiple branches checked out simultaneously in different directories. Instead of stashing or committing WIP to switch branches, you open a new worktree and work on both in parallel.

If your Claude Code version supports `/worktree`, you can use it to create an isolated working copy. Otherwise use native Git worktree commands shown below.

## Why Use Worktrees?

| Scenario | Without Worktrees | With Worktrees |
|----------|------------------|----------------|
| Urgent hotfix while mid-feature | `git stash` → switch → fix → switch back → `git stash pop` (pray for no conflicts) | Open new worktree → fix → merge → continue feature |
| Review a PR while coding | Stop, commit WIP, checkout PR branch | Open worktree for PR, review, close it |
| Run two Claude sessions on different features | Impossible (same checkout) | Each session in its own worktree |
| Compare behavior between branches | Toggle branches, lose running state | Both branches running simultaneously |

## How It Works in Claude Code

### Creating a Worktree

In Claude Code, use the built-in command:
```
/worktree
```

On supported versions, this creates a new worktree (path may vary by version/config) with a fresh branch based on HEAD.

### Manual Worktree Commands

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

## Practical Patterns

### Pattern 1: Parallel Claude Sessions

```bash
# Terminal 1 — main feature work
cd ~/projects/myapp
claude  # Working on feat/user-dashboard

# Terminal 2 — urgent bug fix
cd ~/projects/myapp
git worktree add ../myapp-hotfix main
cd ../myapp-hotfix
git checkout -b fix/payment-null
claude  # Fix the bug in isolation
```

### Pattern 2: PR Review Without Context Switching

```bash
# Your main work continues undisturbed
git worktree add ../review-pr-42 origin/feat/new-auth

# Review in the worktree
cd ../review-pr-42
claude
# > /review-pr

# Clean up when done
cd ~/projects/myapp
git worktree remove ../review-pr-42
```

### Pattern 3: Safe Experimentation

```bash
# Try a risky refactor without affecting your main checkout
git worktree add ../experiment main
cd ../experiment
git checkout -b experiment/new-architecture
claude
# Experiment freely — if it fails, just remove the worktree
```

## Worktree Best Practices

1. **Name worktrees descriptively**: `../myapp-hotfix`, `../myapp-review-42`, not `../temp`
2. **Clean up when done**: `git worktree remove <path>` — stale worktrees waste disk space
3. **Don't share branches**: Each worktree should have its own branch
4. **Worktrees share the git database**: Commits in one worktree are visible to all (after `git fetch`)
5. **Watch for lock files**: If a worktree is removed uncleanly, run `git worktree prune`

## Limitations

- A branch can only be checked out in one worktree at a time
- Worktrees share the same `.git` database — large repos have one copy, not N
- Submodules may need re-initialization in new worktrees
- Some IDE extensions don't handle multiple worktrees well
