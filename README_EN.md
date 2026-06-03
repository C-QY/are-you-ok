# are-you-ok

> A fast, lightweight status report skill for any AI agent.

**[中文版本 →](README.md)**

---

## Purpose

`are-you-ok` is a high-frequency, fast, universal status check skill designed for:

- **Humans** checking what an agent is currently doing
- **Supervisor agents** polling the state of sub-agents
- **Any AI model** reporting its state before a context handoff

Not tied to Claude Code — any agent supporting the SKILL.md format can use it.

---

## Sample Output

```
┌─ STATUS ──────────────────────── 2026-06-03 14:32 ──┐
│                                                      │
│  agent    claude-sonnet-4-6                          │
│  cwd      ~/projects/my-app                          │
│  git      main · 2Δ · "feat: add user search"        │
│  memory   4 entries                                  │
│  tasks    ●2 active  ○1 pending  ✓3 done             │
│  tools    Read Write Edit Glob Grep                  │
│  jobs     none                                       │
│                                                      │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  implement pagination for the results list        │
│  ●  write unit tests for the auth module             │
│                                                      │
├─ PENDING ────────────────────────────────────────────┤
│  ○  update API documentation                         │
│                                                      │
├─ MEMORY ─────────────────────────────────────────────┤
│  project-alpha     backend migration goals           │
│  feedback-tests    prefer integration tests          │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## Trigger Phrases

### Human (English & Chinese — both work equally)

| English | Chinese |
|---------|---------|
| are you ok | 你还好吗 |
| status check | 状态怎么样 |
| what are you doing | 你现在在做什么 |
| report status | 汇报进度 |
| give me a status update | 汇报一下进度 |
| how's it going | 更新一下状态 |
| what's your progress | 进度怎么样 |
| current status | 当前状态 |

### Agent-to-agent (programmatic)
```
!status
```
or structured:
```json
{"skill": "are-you-ok", "caller": "<agent-id>"}
```

---

## Installation

```
~/.claude/skills/are-you-ok/
  SKILL.md
  scripts/
    status-check.ps1   ← Windows
    status-check.sh    ← Mac / Linux
```

**Mac / Linux — one extra step:**
```bash
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh
```

---

## Requirements

| Platform | Requirement |
|----------|-------------|
| Windows | PowerShell 5.1+ |
| Mac / Linux | bash |
| All platforms | `git` (optional) |

---

## Architecture

| Layer | File | Token cost |
|-------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens (always loaded) |
| L2 | `SKILL.md` body | Loaded on trigger |
| L3 | `scripts/status-check.*` | Executed, not read — zero token cost |
