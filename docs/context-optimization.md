# Context Window Optimization

## Why This Matters

Claude Code's context window is large but finite. Every token loaded — CLAUDE.md, skills, conversation history, file contents — competes for space. Wasted context means Claude forgets earlier conversation, makes mistakes, or loses track of the plan.

Optimizing context is the difference between Claude that works reliably on large tasks and Claude that starts hallucinating after 20 turns.

## The Context Budget

Think of context as a budget:

```
┌──────────────────────────────────────────┐
│ System prompt + CLAUDE.md     (~5%)      │
│ Skills (loaded on demand)     (~5-10%)   │
│ Agent instructions            (~3-5%)    │
│ Conversation history          (~40-60%)  │
│ File contents (from Read)     (~20-30%)  │
│ Tool outputs                  (~10-15%)  │
│ ─── Available for reasoning ───          │
└──────────────────────────────────────────┘
```

When the context fills up, Claude Code automatically compresses older messages. But compression loses nuance — better to keep context lean from the start.

## Optimization Strategies

### 1. Keep CLAUDE.md Under 150 Lines

CLAUDE.md loads every single message — bloated instructions burn context on every turn. Move detailed standards to skills. See [why-skills-not-claude-md.md](why-skills-not-claude-md.md) for the full decision framework.

### 2. Use `/compact` Strategically

`/compact` compresses the conversation while preserving key information. Use it:

- **When switching tasks** — old task context is noise for the new task
- **When Claude starts making mistakes** — often a sign of context pressure
- **After exploration phases** — before implementation, compact away the search results
- **Every 30-40 turns** — proactive maintenance

### 3. Use `/context` to Inspect

`/context` shows what's loaded. Check it:
- Before complex tasks — ensure nothing unnecessary is loaded
- When Claude seems confused — stale context might be interfering
- After loading multiple files — verify you're not drowning Claude in code

### 4. Read Files Strategically

```
Bad:  "Read the entire 2000-line file"
Good: "Read lines 45-90 of auth-service.ts (the login method)"
```

- Read specific line ranges when you know where to look
- Use Grep to find the right lines before reading full files
- Don't read files "just in case" — read them when you need them

### 5. Target 60-80% Cache Hits

Claude Code caches repeated context (CLAUDE.md, system prompt). Higher cache hits = faster responses and lower cost.

**What helps cache hits**:
- Consistent CLAUDE.md (don't change it mid-session)
- Stable conversation flow (don't rapidly switch tasks)
- Using skills (loaded once, cached)

**What hurts cache hits**:
- Frequent CLAUDE.md edits during a session
- Constantly reading different large files
- Long conversations that push past context limits

### 6. Use Agents for Isolation

When Claude reads 10 files to investigate a bug, all that content stays in context for the rest of the conversation — even after the bug is fixed.

**Solution**: Use the Task tool to delegate investigation to a sub-agent. The sub-agent reads the files, does the analysis, and returns a summary. Only the summary enters the main context.

```
Without agent: Main context has 10 files × ~200 lines = 2000 lines of file content
With agent:    Main context has 1 summary × ~20 lines = 20 lines
```

### 7. Skill Loading Budget

Skills load on demand, but each loaded skill adds to context. For a session:

- **Target**: 2-3 active skills max
- **Avoid**: Loading 8 skills "just in case"
- **Tip**: Skills with `$ARGUMENTS` only load when invoked

## Red Flags

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Claude forgets earlier instructions | Context overflow → compression lost details | `/compact`, reduce context |
| Claude starts hallucinating file contents | Read too many files, confused them | Read specific files, use agents |
| Responses get slower | Large context = more tokens to process | `/compact`, start new session |
| Claude ignores CLAUDE.md rules | CLAUDE.md pushed out by conversation volume | `/compact`, check with `/memory` |
| Duplicate code generated | Forgot it already wrote similar code | `/compact`, reference the file explicitly |

## Session Lifecycle

```
Start of session
├── CLAUDE.md loaded (~5% context)
├── Brief conversation (~10% context)
└── Everything fits comfortably

Mid-session (30+ turns)
├── CLAUDE.md still loaded (~5%)
├── Conversation history growing (~40%)
├── Multiple files read (~25%)
├── Tool outputs accumulated (~15%)
└── Context pressure → consider /compact

Long session (60+ turns)
├── Auto-compression happening
├── Earlier details being lost
├── Risk of confusion increasing
└── Consider /new for a fresh start
```

## Key Takeaway

Context optimization isn't about being stingy — it's about **being intentional**. Load what you need, when you need it, and clean up when you're done. Claude works best when it can focus on the current task without the noise of everything that came before.
