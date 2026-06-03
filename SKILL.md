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

**Step 3 — Select output language**

| Trigger | Output language |
|---------|----------------|
| Chinese phrase (`你还好吗`, `状态怎么样`, etc.) | Chinese |
| English phrase (`status check`, `report status`, etc.) | English |
| `are you ok` | **Chinese** (default) |
| Agent call (`!status` / JSON) | English (unless caller specifies `"lang": "zh"`) |

**Step 4 — Render the status box**

Draw the output using box-drawing characters. Omit empty detail sections entirely.

**English template:**
```
┌─ STATUS ──────────────────────── {YYYY-MM-DD HH:MM} ┐
│                                                      │
│  agent    {model name}                               │
│  cwd      {working directory}                        │
│  git      {branch} · {N}Δ · "{last commit msg}"     │
│  memory   {N} entries                                │
│  tasks    ●{N} active  ○{N} pending  ✓{N} done      │
│  tools    {space-separated tool names}               │
│  jobs     {N} running  /  none                       │
│                                                      │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  {task description}                               │
├─ PENDING ────────────────────────────────────────────┤
│  ○  {task description}                               │
├─ MEMORY ─────────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

**Chinese template:**
```
┌─ 状态检查 ──────────────────── {YYYY-MM-DD HH:MM} ──┐
│                                                      │
│  模型   {model name}                                 │
│  目录   {working directory}                          │
│  git    {branch} · {N}Δ · "{last commit msg}"        │
│  记忆   {N} 条                                       │
│  任务   ●{N} 进行中  ○{N} 待处理  ✓{N} 已完成        │
│  工具   {space-separated tool names}                 │
│  后台   {N} 个  /  无                                │
│                                                      │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  {task description}                               │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  {task description}                               │
├─ 记忆列表 ───────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

**Rendering rules:**
- Omit a detail block entirely if its section is empty
- Cap active/pending task lists at 5 each; append `(+N more)` if exceeded
- Cap memory entries at 10; append `(+N more)` if exceeded
- Truncate any value exceeding 50 chars with `…`
- If called by another agent, replace the top border label:
  EN: `┌─ STATUS · from {caller-id} ──── {datetime} ──┐`
  CN: `┌─ 状态检查 · 来自 {caller-id} ── {datetime} ──┐`
- `git` / `git` line: if not a repo → EN: `not a repo` / CN: `非代码仓库`
- `memory` / `记忆` line: if no memory found → EN: `none` / CN: `无`
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

**Chinese** (triggered by `are you ok`, `你还好吗`, etc.):
```
┌─ 状态检查 ──────────────────── 2026-06-03 14:32 ────┐
│                                                      │
│  模型   claude-sonnet-4-6                            │
│  目录   ~/projects/my-app                            │
│  git    main · 2Δ · "feat: 新增用户搜索"              │
│  记忆   4 条                                         │
│  任务   ●2 进行中  ○1 待处理  ✓3 已完成               │
│  工具   Read Write Edit Glob Grep                    │
│  后台   无                                           │
│                                                      │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  实现结果列表的分页功能                              │
│  ●  为认证模块编写单元测试                              │
│                                                      │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  更新 API 文档                                    │
│                                                      │
├─ 记忆列表 ───────────────────────────────────────────┤
│  project-alpha   后端迁移目标与当前阶段                 │
│  feedback-tests  偏好集成测试而非 mock                 │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**English** (triggered by `status check`, `report status`, etc.):
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
