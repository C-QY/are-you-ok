---
name: are-you-ok
description: >
  Print a fast, lightweight status snapshot of the current agent session or project.
  Two modes: Agent mode (who am I, what am I doing) and Project mode (what project, what state).
  Works with any AI model. Designed for high-frequency polling by humans or supervisor agents.
  Agent triggers (EN): "are you ok", "status check", "what are you doing", "report status",
  "give me a status update", "how's it going", "current status".
  Agent triggers (CN): "你还好吗", "状态怎么样", "汇报进度", "汇报一下进度", "更新一下状态",
  "你现在在做什么", "当前状态", "给我汇报一下".
  Project triggers (EN): "project status", "project progress", "show project", "how's the project".
  Project triggers (CN): "项目进度", "项目状态", "项目情况", "汇报项目", "当前项目", "项目进度怎么样".
  Agent-to-agent: emit `!status` or `{"skill":"are-you-ok","mode":"agent|project","caller":"<id>"}`.
version: 3.0.0
allowed_tools: [PowerShell, Bash, Read, Glob]
resources:
  - scripts/status-check.ps1
  - scripts/status-check.sh
tags: [status, agent, project, context, session, health-check, multi-agent]
---

# are you ok? — Agent & Project Status Snapshot

## Overview

Two modes, one skill:

| Mode | Focus | When to use |
|------|-------|-------------|
| **Agent** | Who the agent is + what it's doing | Quick session check, context handoff |
| **Project** | What the project is + where it's heading | During active development, progress check |

## Prerequisites

**Windows** — PowerShell 5.1+  
**Mac / Linux** — bash; run once: `chmod +x scripts/status-check.sh`  
**All platforms** — `git` optional; skipped gracefully if absent

## Mode Detection

Select mode from the trigger phrase:

| Trigger | Mode | Language |
|---------|------|----------|
| `are you ok` / `你还好吗` / `状态怎么样` / `汇报进度` | Agent | CN / EN by phrase |
| `status check` / `report status` / `current status` | Agent | EN |
| `项目进度` / `项目状态` / `项目情况` / `汇报项目` | Project | CN |
| `project status` / `project progress` / `show project` | Project | EN |
| `!status` / `{"skill":"are-you-ok"}` | Agent | EN (default) |
| `{"skill":"are-you-ok","mode":"project"}` | Project | EN (default) |

`are you ok` → Agent mode, Chinese output (default).

## Workflow

**Step 1 — Run the data collection script**

- **Windows** → execute `scripts/status-check.ps1` via PowerShell
- **Mac/Linux** → execute `scripts/status-check.sh` via Bash

Captures: cwd, project_name, project_type, git state, git_tag, git_log (×3),
changed files, claude_brief, memory path + count.  
Do NOT read the script into context — execute it.

**Step 2 — Gather agent-side context**

- Model name
- Active, pending, done task counts + task list
- Allowed tools (Agent mode only)
- Running background jobs (Agent mode only)

**Step 3 — Render the status box**

Draw using box-drawing characters. Omit empty detail blocks entirely.

---

### Agent Mode — Chinese
```
┌─ 状态检查 ──────────────────── {YYYY-MM-DD HH:MM} ──┐
│                                                      │
│  模型   {model}                                      │
│  目录   {cwd}                                        │
│  git    {branch} · {N}Δ · "{last commit msg}"        │
│  记忆   {N} 条                                       │
│  任务   ●{N} 进行中  ○{N} 待处理  ✓{N} 已完成        │
│  工具   {tool names}                                 │
│  后台   {N} 个 / 无                                  │
│                                                      │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  {task}                                           │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  {task}                                           │
├─ 记忆列表 ───────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

### Agent Mode — English
```
┌─ STATUS ──────────────────────── {YYYY-MM-DD HH:MM} ┐
│                                                      │
│  agent    {model}                                    │
│  cwd      {cwd}                                      │
│  git      {branch} · {N}Δ · "{last commit msg}"     │
│  memory   {N} entries                                │
│  tasks    ●{N} active  ○{N} pending  ✓{N} done      │
│  tools    {tool names}                               │
│  jobs     {N} running / none                         │
│                                                      │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  {task}                                           │
├─ PENDING ────────────────────────────────────────────┤
│  ○  {task}                                           │
├─ MEMORY ─────────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

### Project Mode — Chinese
```
┌─ 项目状态 ──────────────────── {YYYY-MM-DD HH:MM} ──┐
│                                                      │
│  项目   {project_name}  [{project_type}]             │
│  版本   {git_tag / 未发布}                            │
│  目录   {cwd}                                        │
│  git    {branch} · {N}Δ · "{last commit msg}"        │
│  记忆   {N} 条                                       │
│  任务   ●{N} 进行中  ○{N} 待处理  ✓{N} 已完成        │
│  模型   {model}                                      │
│                                                      │
├─ 项目简介 ───────────────────────────────────────────┤
│  {claude_brief}                                      │
├─ 最近提交 ───────────────────────────────────────────┤
│  {hash}  {commit msg}                                │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  {task}                                           │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  {task}                                           │
├─ 最近变更 ───────────────────────────────────────────┤
│  {filename}                                          │
├─ 记忆列表 ───────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

### Project Mode — English
```
┌─ PROJECT STATUS ────────────── {YYYY-MM-DD HH:MM} ──┐
│                                                      │
│  project  {project_name}  [{project_type}]           │
│  version  {git_tag / untagged}                       │
│  cwd      {cwd}                                      │
│  git      {branch} · {N}Δ · "{last commit msg}"     │
│  memory   {N} entries                                │
│  tasks    ●{N} active  ○{N} pending  ✓{N} done      │
│  agent    {model}                                    │
│                                                      │
├─ PROJECT BRIEF ──────────────────────────────────────┤
│  {claude_brief}                                      │
├─ RECENT COMMITS ─────────────────────────────────────┤
│  {hash}  {commit msg}                                │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  {task}                                           │
├─ PENDING ────────────────────────────────────────────┤
│  ○  {task}                                           │
├─ RECENT CHANGES ─────────────────────────────────────┤
│  {filename}                                          │
├─ MEMORY ─────────────────────────────────────────────┤
│  {slug:<16}  {description}                           │
└──────────────────────────────────────────────────────┘
```

## Rendering Rules

- Omit any detail block if its content is empty
- **Project mode**: omit `项目简介 / PROJECT BRIEF` if no CLAUDE.md found
- **Project mode**: omit `最近变更 / RECENT CHANGES` if no changed files
- Cap active/pending tasks at 5 each; append `(+N more)` if exceeded
- Cap memory entries at 10; append `(+N more)` if exceeded
- Cap recent commits at 3; cap recent changes at 10
- Truncate any value line exceeding 50 chars with `…`
- If called by another agent, replace top border:
  CN: `┌─ 状态检查 · 来自 {caller} ─── {datetime} ──┐`
  EN: `┌─ STATUS · from {caller} ──── {datetime} ──┐`
- git not a repo → CN: `非代码仓库` / EN: `not a repo`
- memory not found → CN: `无` / EN: `none`
- Do NOT expose secrets, tokens, or passwords
- Do NOT add prose outside the box

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Script not found | Ensure `scripts/` folder is alongside `SKILL.md` |
| `project_type` shows `unknown` | No recognized config file in cwd |
| `版本` shows `未发布` | No git tags exist yet — use `git tag v0.1.0` |
| Windows: execution policy | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Mac/Linux: permission denied | `chmod +x scripts/status-check.sh` |

## Example Output

**Agent mode — Chinese** (`are you ok`):
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

**Project mode — Chinese** (`项目进度`):
```
┌─ 项目状态 ──────────────────── 2026-06-03 14:32 ────┐
│                                                      │
│  项目   my-app  [Node.js]                            │
│  版本   v1.2.0                                       │
│  目录   ~/projects/my-app                            │
│  git    main · 3Δ · "feat: 新增用户搜索"              │
│  记忆   4 条                                         │
│  任务   ●2 进行中  ○3 待处理  ✓8 已完成               │
│  模型   claude-sonnet-4-6                            │
│                                                      │
├─ 项目简介 ───────────────────────────────────────────┤
│  Node.js 全栈应用，RESTful API + React 前端           │
│                                                      │
├─ 最近提交 ───────────────────────────────────────────┤
│  a1b2c3d  feat: 新增用户搜索                          │
│  e4f5g6h  fix: 修复登录跳转问题                        │
│  i7j8k9l  chore: 升级依赖至最新版                     │
│                                                      │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  实现结果列表的分页功能                              │
│  ●  为认证模块编写单元测试                              │
│                                                      │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  更新 API 文档                                    │
│  ○  部署到测试环境                                    │
│  ○  代码审查 PR #42                                  │
│                                                      │
├─ 最近变更 ───────────────────────────────────────────┤
│  src/components/SearchBar.tsx                        │
│  src/api/users.ts                                    │
│                                                      │
├─ 记忆列表 ───────────────────────────────────────────┤
│  project-alpha   后端迁移目标与当前阶段                 │
│  feedback-tests  偏好集成测试而非 mock                 │
│                                                      │
└──────────────────────────────────────────────────────┘
```
