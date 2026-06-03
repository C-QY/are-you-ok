# are-you-ok

> A Claude Code skill that prints a structured agent status snapshot on demand.

**[中文版本 →](README.md)**

---

## What it does

When triggered, the agent prints a structured status snapshot covering:

- **agent** — current model name
- **cwd** — working directory
- **git** — branch, uncommitted count, last commit message
- **memory** — number of persistent memory entries
- **tasks** — active / pending / done task counts
- **tools** — tools allowed in this session
- **jobs** — running background tasks

Sample output:

```
are you ok? · 2026-06-03 14:32

agent     claude-sonnet-4-6
cwd       ~/projects/my-app
git       main · 2 uncommitted · last: "feat: add user search"
memory    4 entries
tasks     2 active, 1 pending, 3 done
tools     Read Write Edit Glob Grep
jobs      none

tasks (active)
  · implement pagination for the results list
  · write unit tests for the auth module

tasks (pending)
  · update API documentation

memory
  project-alpha    backend migration goals and current phase
  feedback-tests   prefer integration tests over mocked unit tests

recent changes
  src/components/SearchBar.tsx
  src/api/users.ts
```

## Trigger phrases

```
are you ok
你还好吗
状态怎么样
汇报进度
当前状态
你现在在做什么
```

## Installation

Copy the following files into your Claude Code skills directory:

```
~/.claude/skills/are-you-ok/
  SKILL.md
  scripts/
    status-check.ps1   ← Windows
    status-check.sh    ← Mac / Linux
```

Or place them inside your project's `.claude/` folder.

**Mac / Linux — one extra step:**
```bash
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh
```

## Requirements

| Platform | Requirement |
|----------|-------------|
| Windows | PowerShell 5.1+ |
| Mac / Linux | bash |
| All platforms | `git` (optional — skipped gracefully if absent) |

## Architecture

| Layer | File | Purpose |
|-------|------|---------|
| L1 | `SKILL.md` frontmatter | Trigger matching, ~100 tokens |
| L2 | `SKILL.md` body | Rendering instructions, loaded on trigger |
| L3 | `scripts/status-check.*` | Deterministic data collection, zero context cost |

The scripts collect workspace metadata only (directory, git state, memory entry count). They never read or output actual memory content — that is handled by the agent directly.
