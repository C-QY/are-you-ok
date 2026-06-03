---
name: are-you-ok
description: >
  Print a structured agent status snapshot covering model, workspace, git state,
  memory, active tasks, allowed tools, and background jobs.
  Trigger when user asks: "are you ok", "你还好吗", "状态怎么样", "汇报进度",
  "你现在在做什么", "当前状态", or any request for a session or context summary.
version: 2.1.0
allowed_tools: [PowerShell, Bash, Read, Glob]
resources:
  - scripts/status-check.ps1
  - scripts/status-check.sh
tags: [status, agent, context, session, health-check]
---

# are you ok? — Agent Status Snapshot

## Prerequisites

**Windows**
- PowerShell 5.1+
- `git` optional

**Mac / Linux**
- bash
- `git` optional
- Run once after install: `chmod +x scripts/status-check.sh`

Script must be placed at `scripts/status-check.ps1` (Windows) or
`scripts/status-check.sh` (Mac/Linux) relative to this skill file.

## Workflow

**Step 1 — Run the data collection script**

Detect the current platform and run the matching script:

- **Windows** → execute `scripts/status-check.ps1` via PowerShell
- **Mac/Linux** → execute `scripts/status-check.sh` via Bash

Both scripts output identical `key:value` lines. Capture the full output.
Do NOT read the script file into context — execute it.

**Step 2 — Gather agent-side context**

The script cannot access agent-internal state. Collect these yourself:
- Current model name (from system context)
- Active, pending, and done task counts from TodoWrite
- Full task list (in-progress and pending only)
- Allowed tools for this session
- Any running background jobs

**Step 3 — Render the status output**

Combine script output and agent-side context. Render in two parts:

**Part A — Summary header** (always show, one line per field):

```
are you ok? · {YYYY-MM-DD HH:MM}

agent     {model name}
cwd       {working directory from script}
git       {branch · N uncommitted · last: "{commit msg}" — or "not a repo"}
memory    {N entries — or "none"}
tasks     {N active, N pending, N done}
tools     {space-separated list of allowed tools}
jobs      {N running — or "none"}
```

**Part B — Expanded detail blocks** (only show non-empty sections):

```
tasks (active)
  · {description}

tasks (pending)
  · {description}

memory
  {slug}    {one-line description}

recent changes
  {filename}
```

## Constraints

- Do NOT add prose, headers, or explanations outside the template
- Do NOT show "tasks (done)" — done tasks add no actionable value
- Do NOT truncate memory entries — show all
- Do NOT expose secrets, tokens, or passwords
- If a section is empty, omit the detail block entirely (summary line still shows "none")

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Script not found | Ensure the `scripts/` folder is alongside `SKILL.md` |
| git fields missing | Not a git repo — write "not a repo" in git line |
| memory shows "none" | No MEMORY.md exists yet — expected for new sessions |
| Windows: execution policy error | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Mac/Linux: permission denied | `chmod +x scripts/status-check.sh` |

## Example Output

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
