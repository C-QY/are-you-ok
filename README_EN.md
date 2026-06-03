# are-you-ok

> A lightweight skill for users and supervisor agents to instantly check any AI agent's current state or an active project's progress.

**[中文版本 →](README.md)**

---

## Two Modes

| Mode | Focus | Triggers |
|------|-------|---------|
| **Agent Status** | Model, tools, tasks, memory | `are you ok` · `status check` · `report status` |
| **Project Status** | Name, version, commits, changes | `project status` · `project progress` · `show project` |

Agent call: `!status` or `{"skill":"are-you-ok","mode":"agent|project"}`

---

## Sample Output

**Agent mode** (`status check`):
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
├─ PENDING ────────────────────────────────────────────┤
│  ○  update API documentation                         │
├─ MEMORY ─────────────────────────────────────────────┤
│  project-alpha   backend migration goals             │
└──────────────────────────────────────────────────────┘
```

**Project mode** (`project status`):
```
┌─ PROJECT STATUS ────────────── 2026-06-03 14:32 ────┐
│                                                      │
│  project  my-app  [Node.js]                          │
│  version  v1.2.0                                     │
│  cwd      ~/projects/my-app                          │
│  git      main · 3Δ · "feat: add user search"        │
│  memory   4 entries                                  │
│  tasks    ●2 active  ○3 pending  ✓8 done             │
│  agent    claude-sonnet-4-6                          │
│                                                      │
├─ PROJECT BRIEF ──────────────────────────────────────┤
│  Full-stack Node.js app, RESTful API + React frontend│
├─ RECENT COMMITS ─────────────────────────────────────┤
│  a1b2c3d  feat: add user search                      │
│  e4f5g6h  fix: login redirect issue                  │
│  i7j8k9l  chore: upgrade dependencies                │
├─ ACTIVE ─────────────────────────────────────────────┤
│  ●  implement pagination for the results list        │
├─ PENDING ────────────────────────────────────────────┤
│  ○  update API documentation                         │
├─ RECENT CHANGES ─────────────────────────────────────┤
│  src/components/SearchBar.tsx                        │
├─ MEMORY ─────────────────────────────────────────────┤
│  project-alpha   backend migration goals             │
└──────────────────────────────────────────────────────┘
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

## Easter Egg (Optional)

Triggers only when the exact phrase `are you ok` is used (case-insensitive). Other trigger phrases do not activate it.

**Effect:**
```
╭──────────────────────────────────╮
│  🎤  "Are you OK?"               │
│      Lei Jun · Shanghai · 2015   │
╰──────────────────────────────────╯
```
The status box renders normally after the Easter egg.

---

### Enable GIF

Place `leijun.gif` in the `assets/` folder. It opens in your default viewer on trigger.

### Enable Audio

Place `leijun.mp3` (or `leijun.wav`) in the `assets/` folder. It plays automatically on trigger.

Supported files (use any or all):

| File | Effect |
|------|--------|
| `assets/leijun.gif` | Opens GIF in default viewer |
| `assets/leijun.mp3` | Plays audio |
| `assets/leijun.wav` | Plays audio (fallback format) |

If no media files are present, a text-only Easter egg is shown — the skill works normally either way.

---

### Disable the Easter Egg

Remove the media files from `assets/` to disable the corresponding effects.

To completely disable the Easter egg logic, delete:
```
scripts/play-easter-egg.ps1
scripts/play-easter-egg.sh
```

---

## Requirements

| Platform | Requirement |
|----------|-------------|
| Windows | PowerShell 5.1+ |
| Mac / Linux | bash |
| All platforms | `git` (optional) |

---

## Design Principles

**Fast · Lightweight · Universal** — scripts collect metadata only, never actual content. Before any change: does this add extra overhead? If yes, skip it.

| Layer | File | Token cost |
|-------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens |
| L2 | `SKILL.md` body | Loaded on trigger |
| L3 | `scripts/status-check.*` | Executed, not read — zero token cost |
