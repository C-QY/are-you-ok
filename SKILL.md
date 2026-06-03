---
name: are-you-ok
description: >-
  Print a structured status snapshot of the current agent session or active project.
  Agent mode: model, git, memory, tasks, tools, jobs.
  Project mode: project name/type, version, recent commits, changed files.
  Trigger — agent: "are you ok", "你还好吗", "状态怎么样", "汇报进度", "当前状态", !status.
  Trigger — project: "项目进度", "项目状态", "项目情况", "project status", "project progress".
  Output language: Chinese for CN triggers and "are you ok"; English otherwise.
allowed_tools: [PowerShell, Bash, Read, Glob]
resources:
  - scripts/status-check.ps1
  - scripts/status-check.sh
---

## Workflow

**Step 1 — Run the data collection script**

- Windows: execute `scripts/status-check.ps1` via PowerShell
- Mac/Linux: execute `scripts/status-check.sh` via Bash

Do NOT read the script into context — execute it. Captures: cwd, project_name,
project_type, git branch/tag/log×3/changes, claude_brief, memory count.

**Step 2 — Determine mode and language**

| Trigger pattern | Mode | Language |
|----------------|------|----------|
| CN phrase / `are you ok` | Agent | Chinese |
| EN phrase (`status check`, etc.) | Agent | English |
| CN project phrase | Project | Chinese |
| EN project phrase | Project | English |
| `!status` / JSON call | Agent | English |
| `{"skill":"are-you-ok","mode":"project"}` | Project | English |

**Step 3 — Collect agent-side context**

- Model name
- Active, pending, done task counts + full active/pending task list
- Allowed tools (Agent mode only)
- Running background jobs (Agent mode only)

**Step 4 — Render the status box**

Draw using box-drawing characters per the matching template below.
Omit empty detail blocks entirely.

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
- Omit `项目简介 / PROJECT BRIEF` if no CLAUDE.md in cwd
- Omit `最近变更 / RECENT CHANGES` if no changed files
- Cap active/pending tasks at 5 each; append `(+N more)` if exceeded
- Cap memory entries at 10; append `(+N more)` if exceeded
- Cap recent commits at 3; cap recent changes at 10
- Truncate any value line exceeding 50 chars with `…`
- Agent caller: replace top border label with caller identity
- git not a repo: CN `非代码仓库` / EN `not a repo`
- memory not found: CN `无` / EN `none`
- Do NOT expose secrets, tokens, or passwords
- Do NOT add prose outside the box

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
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  更新 API 文档                                    │
├─ 记忆列表 ───────────────────────────────────────────┤
│  project-alpha   后端迁移目标与当前阶段                 │
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
├─ 最近提交 ───────────────────────────────────────────┤
│  a1b2c3d  feat: 新增用户搜索                          │
│  e4f5g6h  fix: 修复登录跳转问题                        │
├─ 进行中 ─────────────────────────────────────────────┤
│  ●  实现结果列表的分页功能                              │
├─ 待处理 ─────────────────────────────────────────────┤
│  ○  更新 API 文档                                    │
├─ 最近变更 ───────────────────────────────────────────┤
│  src/components/SearchBar.tsx                        │
├─ 记忆列表 ───────────────────────────────────────────┤
│  project-alpha   后端迁移目标与当前阶段                 │
└──────────────────────────────────────────────────────┘
```
