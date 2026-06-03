---
name: are-you-ok
description: >
  Print a fast, lightweight status snapshot of the current agent session.
  Covers: model, workspace, git state, memory, active tasks, tools, background jobs.
  Works with any AI model. Designed for high-frequency polling by humans or supervisor agents.
  Human triggers (EN): "are you ok", "status check", "what are you doing", "report status",
  "give me a status update", "how's it going", "what's your progress", "current status".
  Human triggers (CN): "你还好吗", "状态怎么样", "汇报进度", "汇报一下进度", "更新一下状态",
  "你现在在做什么", "进度怎么样", "当前状态", "给我汇报一下", or any context summary request.
  Agent-to-agent trigger: emit `!status` or send {"skill": "are-you-ok", "caller": "<id>"}.
version: 2.2.0
allowed_tools: [PowerShell, Bash, Read, Glob]
resources:
  - scripts/status-check.ps1
  - scripts/status-check.sh
tags: [status, agent, context, session, health-check, multi-agent]
---

# are you ok? — Agent Status Snapshot

## Overview

A fast, lightweight status check for any AI agent. Useful for:
- A **human** wanting a quick read on what the agent is doing
- A **supervisor agent** polling the state of a sub-agent
- Any agent **handing off** context to another session

## Prerequisites

**Windows** — PowerShell 5.1+  
**Mac / Linux** — bash; run once after install: `chmod +x scripts/status-check.sh`  
**All platforms** — `git` optional; skipped gracefully if absent

## Trigger Modes

### Human-initiated
Natural language phrases: `are you ok` · `你还好吗` · `状态怎么样` · `汇报进度` · `当前状态`

### Agent-to-agent
Any agent (supervisor, orchestrator, peer) can trigger this by including:
- The token `!status` anywhere in its message
- A structured call: `{"skill": "are-you-ok", "caller": "<agent-id>"}`

When called by another agent, include the caller's identity in the output header if provided.

## Workflow

**Step 1 — Run the data collection script**

- **Windows** → execute `scripts/status-check.ps1` via PowerShell  
- **Mac/Linux** → execute `scripts/status-check.sh` via Bash

Capture full output. Do NOT read the script into context — execute it.

**Step 2 — Gather agent-side context**

Collect from your own session state:
- Model name
- Active, pending, done task counts + full active/pending task list
- Allowed tools
- Running background jobs

**Step 3 — Render the status box**

Draw the output using box-drawing characters as shown in the template below.
Keep width ≤ 56 characters. Omit empty detail sections entirely.

```
┌─ STATUS ──────────────────────── {YYYY-MM-DD HH:MM} ┐
│                                                      │
│  agent    {model name}                               │
│  cwd      {working directory}                        │
│  git      {branch} · {N}Δ · "{last commit msg}"     │
│  memory   {N} entries  ·  {path-hint or "none"}      │
│  tasks    ●{N} active  ○{N} pending  ✓{N} done       │
│  tools    {space-separated tool names}               │
│  jobs     {N} running  /  none                       │
│                                                      │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  {task description}                               │
│                                                      │
├─ PENDING ────────────────────────────────────────────┤
│  ○  {task description}                               │
│                                                      │
├─ MEMORY ─────────────────────────────────────────────┤
│  {slug:<16}  {one-line description}                  │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Rendering rules:**
- Omit `ACTIVE` block if no active tasks; omit `PENDING` block if no pending tasks
- Omit `MEMORY` block if memory count is 0
- Cap active/pending task lists at 5 each; append `(+N more)` if exceeded
- Cap memory entries at 10; append `(+N more)` if exceeded
- Truncate any value line exceeding 50 chars with `…`
- If called by another agent, replace the top border label:
  `┌─ STATUS · called by {caller-id} ─── {datetime} ─┐`
- `git` line: if not a repo, write `not a repo`
- `memory` line: if not using Claude memory, write agent's own memory/context system name or `none`
- Do NOT expose secrets, tokens, or passwords
- Do NOT add prose outside the box

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Script not found | Ensure `scripts/` folder is alongside `SKILL.md` |
| git fields missing | Not a git repo — write `not a repo` |
| memory shows 0 | No MEMORY.md found — expected for non-Claude agents or new sessions |
| Windows: execution policy | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Mac/Linux: permission denied | `chmod +x scripts/status-check.sh` |

## Example Output

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
