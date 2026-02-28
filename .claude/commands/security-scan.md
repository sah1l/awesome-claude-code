# /security-scan — Security Audit Workflow

## Description
Runs a comprehensive security audit combining the security-auditor agent with automated secrets detection. Produces a severity-ranked report with actionable remediation guidance.

## Usage
```
/security-scan $ARGUMENTS
```
- `/security-scan` — full codebase scan
- `/security-scan src/auth/` — scan specific directory
- `/security-scan --focus injection` — focus on specific vulnerability class

## Workflow

### Wave 1: Automated Checks (Parallel)

**Task 1 — Secrets Detection**
Scan for hardcoded secrets using pattern matching:
```bash
# High-entropy strings, API keys, tokens
grep -rEn "AKIA[0-9A-Z]{16}" .                           # AWS access keys
grep -rEn "sk-[A-Za-z0-9]{48}" .                         # OpenAI/Stripe secret keys
grep -rEn "ghp_[A-Za-z0-9]{36}" .                        # GitHub personal tokens
grep -rEn "password[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]" .  # Hardcoded passwords
grep -rEn "-----BEGIN ([A-Z ]+ )?PRIVATE KEY-----" .     # Private keys
```

Also check:
- `.env` files committed to git: `git ls-files | grep -i '\.env'`
- Secrets in git history: `git log --all -p | grep -Ei "password|secret|api[_-]?key"` (sample)

**Task 2 — Dependency Audit**
```bash
# Node.js
npm audit --json 2>/dev/null

# Python
pip audit 2>/dev/null

# Go
govulncheck ./... 2>/dev/null

# Rust
cargo audit 2>/dev/null
```

### Wave 2: Security Auditor Agent
Launch the security-auditor agent to perform OWASP Top 10 analysis on the codebase (or targeted directory). The agent provides deep analysis that automated tools miss — logic flaws, authorization bypasses, and architectural security issues.

### Wave 3: Synthesize Report

```markdown
## Security Scan Report

### Summary
| Severity | Count |
|----------|-------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |
| Info | X |

### Secrets Detection
[Findings from Wave 1, Task 1]

### Dependency Vulnerabilities
[Findings from Wave 1, Task 2]

### Code Analysis (OWASP Top 10)
[Findings from Wave 2, ranked by severity]

### Remediation Priority
1. [Critical items — fix immediately]
2. [High items — fix this sprint]
3. [Medium items — fix this quarter]
4. [Low items — fix when touching related code]

### Recommendations
- [ ] Set up `npm audit` / `pip audit` in CI pipeline
- [ ] Add pre-commit hook for secrets detection
- [ ] Schedule quarterly dependency updates
- [ ] Enable security headers in production
```

## Why This Command?
- Combines automated scanning (fast, catches known patterns) with AI analysis (deep, catches logic flaws)
- A single command replaces running 3-4 separate security tools
- Severity ranking prevents alert fatigue — focus on what matters
- Remediation guidance means findings are actionable, not just scary
