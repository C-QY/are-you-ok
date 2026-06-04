---
name: are-you-ok
description: >-
  Print a structured status snapshot of the current agent session or active project.
  Agent mode: model, git, memory, tasks, tools, jobs.
  Project mode: project name/type, version, recent commits, changed files.
  Recovery mode: network status, uncommitted changes, jobs, tasks, recovery steps.
  Trigger — agent: "are you ok", "你还好吗", "状态怎么样", "汇报进度", "当前状态", !status.
  Trigger — inline peek: ?, ??, ??? — finish the current response first, then append the status box.
  Trigger — project: "项目进度", "项目状态", "项目情况", "project status", "project progress".
  Trigger — recovery (AUTO, no user input needed): invoke automatically at the start of a
  conversation turn when the context contains ANY of these network error signals —
  Claude Code: "socket connection was closed unexpectedly", "Streamable HTTP error",
  "claude.ai proxy connection failed";
  OpenAI/GPT: "network error", "Failed to fetch", "The network connection was lost",
  "Error communicating with ChatGPT";
  Copilot: "Copilot is not reachable", "Connection to GitHub Copilot failed";
  Cursor: "Could not connect to language model";
  Gemini: "UNAVAILABLE", "deadline exceeded", "transport error";
  Universal: "ECONNRESET", "ECONNREFUSED", "ETIMEDOUT", "ENOTFOUND", "ERR_NETWORK",
  "502", "503", "request timeout", "connection was closed", "connection interrupted".
  Do NOT auto-invoke if user voluntarily ended the conversation with no error signals.
  Do NOT auto-invoke for business errors (token limit, content policy, etc.).
  Output language: Chinese for CN triggers and "are you ok"; English otherwise.
allowed_tools: [PowerShell, Bash, Read, Glob]
resources:
  - scripts/status-check.ps1
  - scripts/status-check.sh
  - assets/eleijun-are-you-ok.mp3
---

## Workflow

**Step 1 — Run the data collection script**

- Windows: `scripts/status-check.ps1` — add `-EasterEgg` flag if trigger is `are you ok`
- Mac/Linux: `scripts/status-check.sh` — add `--easter-egg` flag if trigger is `are you ok`
- Recovery trigger: add `-NetworkCheck` flag (Windows) / `--network-check` flag (Mac/Linux)

Do NOT read the script into context — execute it. Captures: **timestamp**, cwd, project_name,
project_type, git branch/tag/log×3/changes, claude_brief, memory count.
With `-NetworkCheck`: also outputs `network_status:ok` or `network_status:fail`.
With the easter egg flag, audio plays automatically in the background.

Use the `timestamp:` value from script output for the status box — **no separate time call needed**.

If the script returns `easter_egg:ok` (no audio file found), render this before the status box:

```
╭──────────────────────────────────╮
│  🎤  "Are you OK?"               │
│      Lei Jun · Shanghai · 2015   │
╰──────────────────────────────────╯
```

**Step 2 — Determine mode and language**

| Trigger pattern | Mode | Language |
|----------------|------|----------|
| CN phrase / `are you ok` | Agent | Chinese |
| EN phrase (`status check`, etc.) | Agent | English |
| CN project phrase | Project | Chinese |
| EN project phrase | Project | English |
| `!status` / JSON call | Agent | English |
| `{"skill":"are-you-ok","mode":"project"}` | Project | English |
| `?` / `??` / `???` | Inline peek | matches context lang |
| network error signal in context (auto) | Recovery | matches context lang |

**Inline peek behavior** (`?` / `??` / `???`): Complete the current response or task first, then append the status box at the end — do not interrupt ongoing work.

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
👌  状态检查 ─── {YYYY-MM-DD HH:MM}
│
│  模型   {model}
│  目录   {cwd}
│  git    {branch} · {N}Δ · "{last commit msg}"
│  记忆   {N} 条
│  任务   ●{N} 进行中  ○{N} 待处理  ✓{N} 已完成
│  工具   {tool names}
│
├─ 进行中 ──────────────────────────────────────
│  ●  {task}
├─ 待处理 ──────────────────────────────────────
│  ○  {task}
├─ 记忆列表 ────────────────────────────────────
│  {slug:<16}  {description}
╰────────────────────────────────────────────────
```

### Agent Mode — English
```
👌  STATUS ─── {YYYY-MM-DD HH:MM}
│
│  agent    {model}
│  cwd      {cwd}
│  git      {branch} · {N}Δ · "{last commit msg}"
│  memory   {N} entries
│  tasks    ●{N} active  ○{N} pending  ✓{N} done
│  tools    {tool names}
│
├─ ACTIVE ───────────────────────────────────────
│  ●  {task}
├─ PENDING ──────────────────────────────────────
│  ○  {task}
├─ MEMORY ───────────────────────────────────────
│  {slug:<16}  {description}
╰────────────────────────────────────────────────
```

### Project Mode — Chinese
```
👌  项目状态 ─── {YYYY-MM-DD HH:MM}
│
│  项目   {project_name}  [{project_type}]
│  版本   {git_tag / 未发布}
│  目录   {cwd}
│  git    {branch} · {N}Δ · "{last commit msg}"
│  记忆   {N} 条
│  任务   ●{N} 进行中  ○{N} 待处理  ✓{N} 已完成
│  模型   {model}
│
├─ 项目简介 ────────────────────────────────────
│  {claude_brief}
├─ 最近提交 ────────────────────────────────────
│  {hash}  {commit msg}
├─ 进行中 ──────────────────────────────────────
│  ●  {task}
├─ 待处理 ──────────────────────────────────────
│  ○  {task}
├─ 最近变更 ────────────────────────────────────
│  {filename}
├─ 记忆列表 ────────────────────────────────────
│  {slug:<16}  {description}
╰────────────────────────────────────────────────
```

### Project Mode — English
```
👌  PROJECT STATUS ─── {YYYY-MM-DD HH:MM}
│
│  project  {project_name}  [{project_type}]
│  version  {git_tag / untagged}
│  cwd      {cwd}
│  git      {branch} · {N}Δ · "{last commit msg}"
│  memory   {N} entries
│  tasks    ●{N} active  ○{N} pending  ✓{N} done
│  agent    {model}
│
├─ PROJECT BRIEF ────────────────────────────────
│  {claude_brief}
├─ RECENT COMMITS ───────────────────────────────
│  {hash}  {commit msg}
├─ ACTIVE ───────────────────────────────────────
│  ●  {task}
├─ PENDING ──────────────────────────────────────
│  ○  {task}
├─ RECENT CHANGES ───────────────────────────────
│  {filename}
├─ MEMORY ───────────────────────────────────────
│  {slug:<16}  {description}
╰────────────────────────────────────────────────
```

### Recovery Mode — Chinese
```
👌  网络恢复 ─── {YYYY-MM-DD HH:MM}
│
│  网络   ✓ 已恢复 / ✗ 仍然异常
│  git    {N}Δ 未提交  ·  "{last commit msg}"
│  后台   {N} 个 / 无
│  任务   ●{N} 进行中  ○{N} 待处理
│
├─ 恢复步骤 ────────────────────────────────────
│  1. 回顾中断点：哪一步工具调用可能未完成？
│  2. 用只读操作验证实际状态（Read/Grep）不要直接继续写
│  3. 有后台任务时确认是否仍在运行还是已挂起
│  4. 确认后再继续下一步操作
╰────────────────────────────────────────────────
```

### Recovery Mode — English
```
👌  NETWORK RECOVERY ─── {YYYY-MM-DD HH:MM}
│
│  network  ✓ restored / ✗ still down
│  git      {N}Δ uncommitted  ·  "{last commit msg}"
│  jobs     {N} running / none
│  tasks    ●{N} active  ○{N} pending
│
├─ RECOVERY STEPS ───────────────────────────────
│  1. Identify the interrupted tool call / operation
│  2. Verify actual state with read-only ops first
│  3. Check background jobs — still running or hung?
│  4. Confirm state before resuming any writes
╰────────────────────────────────────────────────
```

## Rendering Rules

- Omit any detail block if its content is empty
- Omit `项目简介 / PROJECT BRIEF` if no CLAUDE.md in cwd
- Omit `最近变更 / RECENT CHANGES` if no changed files
- Cap active/pending tasks at 5 each; append `(+N more)` if exceeded
- Cap memory entries at 10; append `(+N more)` if exceeded
- Cap recent commits at 3; cap recent changes at 10
- Truncate any value line exceeding 50 chars with `…`
- **CJK-aware padding**: Box inner width = 54 visual columns. For each content line, count CJK characters (Chinese, Japanese, Korean + full-width punctuation such as （）【】、。，；：！？——…·) and subtract that count from the trailing space padding. Formula: padding = (54 - char_count - CJK_char_count) spaces. This compensates for CJK chars occupying 2 display columns.
- Agent caller: replace top border label with caller identity
- git not a repo: CN `非代码仓库` / EN `not a repo`
- memory not found (no `memory_count` in script output): omit 记忆 / memory line entirely
- 后台 / jobs line: omit when 无 / none (0 running)
- 任务 / tasks line: omit when all three counts are 0
- Do NOT expose secrets, tokens, or passwords
- Do NOT add prose outside the box
- Recovery mode: `network_status:ok` → `✓ 已恢复` / `✓ restored`; `fail` → `✗ 仍然异常` / `✗ still down`
- Recovery mode: omit git line if not a repo; omit jobs/tasks lines if both are zero/none
- Recovery mode: 恢复步骤 / RECOVERY STEPS are fixed 4 lines, never omitted

## Example Output

**Agent mode — Chinese** (`are you ok`):
```
👌  状态检查 ─── 2026-06-03 14:32
│
│  模型   claude-sonnet-4-6
│  目录   ~/projects/my-app
│  git    main · 2Δ · "feat: 新增用户搜索"
│  记忆   4 条
│  任务   ●2 进行中  ○1 待处理  ✓3 已完成
│  工具   Read Write Edit Glob Grep
│
├─ 进行中 ──────────────────────────────────────
│  ●  实现结果列表的分页功能
│  ●  为认证模块编写单元测试
├─ 待处理 ──────────────────────────────────────
│  ○  更新 API 文档
├─ 记忆列表 ────────────────────────────────────
│  project-alpha   后端迁移目标与当前阶段
╰────────────────────────────────────────────────
```

**Project mode — Chinese** (`项目进度`):
```
👌  项目状态 ─── 2026-06-03 14:32
│
│  项目   my-app  [Node.js]
│  版本   v1.2.0
│  目录   ~/projects/my-app
│  git    main · 3Δ · "feat: 新增用户搜索"
│  记忆   4 条
│  任务   ●2 进行中  ○3 待处理  ✓8 已完成
│  模型   claude-sonnet-4-6
│
├─ 项目简介 ────────────────────────────────────
│  Node.js 全栈应用，RESTful API + React 前端
├─ 最近提交 ────────────────────────────────────
│  a1b2c3d  feat: 新增用户搜索
│  e4f5g6h  fix: 修复登录跳转问题
├─ 进行中 ──────────────────────────────────────
│  ●  实现结果列表的分页功能
├─ 待处理 ──────────────────────────────────────
│  ○  更新 API 文档
├─ 最近变更 ────────────────────────────────────
│  src/components/SearchBar.tsx
├─ 记忆列表 ────────────────────────────────────
│  project-alpha   后端迁移目标与当前阶段
╰────────────────────────────────────────────────
```
