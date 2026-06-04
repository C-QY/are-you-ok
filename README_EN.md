# are-you-ok

> A lightweight skill for users and supervisor agents to instantly check any AI agent's current state or an active project's progress.

**[中文版本 →](README.md)**

---

## Three Modes

| Mode | Focus | Trigger |
|------|-------|---------|
| **Agent Status** | Model, tools, tasks, memory | `are you ok` · `status check` · `report status` |
| **Project Status** | Name, version, commits, changes | `project status` · `project progress` · `show project` |
| **Network Recovery** | Network status, uncommitted changes, recovery steps | **Auto-triggered** — no user input needed |

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

**Network Recovery mode** (auto-triggered, no input needed):
```
┌─ NETWORK RECOVERY ────────────── 2026-06-04 10:30 ──┐
│                                                      │
│  network  ✓ restored                                 │
│  git      2Δ uncommitted  ·  "feat: add user search" │
│  jobs     none                                       │
│  tasks    ●1 active  ○2 pending                      │
│                                                      │
├─ RECOVERY STEPS ─────────────────────────────────────┤
│  1. Identify the interrupted tool call / operation   │
│  2. Verify actual state with read-only ops first     │
│  3. Check background jobs — still running or hung?   │
│  4. Confirm state before resuming any writes         │
└──────────────────────────────────────────────────────┘
```

---

## Network Recovery Mode

Triggers **automatically** when network error signals appear in the conversation context — no user input required.

**Recognizes network interruptions across major AI tools:**

| Tool | Detected signals |
|------|-----------------|
| Claude Code | `socket connection was closed unexpectedly` · `Streamable HTTP error` |
| ChatGPT / OpenAI | `network error` · `Failed to fetch` · `The network connection was lost` |
| GitHub Copilot | `Copilot is not reachable` · `Connection to GitHub Copilot failed` |
| Cursor | `Could not connect to language model` |
| Gemini | `UNAVAILABLE` · `deadline exceeded` · `transport error` |
| Universal signals | `ECONNRESET` · `ETIMEDOUT` · `ENOTFOUND` · `502` · `503` |

**Does NOT trigger on:** user-initiated exits (no error signal), token limit errors, content policy rejections.

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

## Easter Egg

Triggers only when the exact phrase `are you ok` is used (case-insensitive). Other trigger phrases do not activate it. Enabled by default.

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

Place `eleijun-are-you-ok.gif` in the `assets/` folder. It opens in your default viewer on trigger.

### Enable Audio

Place `eleijun-are-you-ok.mp3` (or `eleijun-are-you-ok.wav`) in the `assets/` folder. It plays automatically on trigger.

Supported files:

| File | Effect |
|------|--------|
| `assets/eleijun-are-you-ok.mp3` | Plays audio |
| `assets/eleijun-are-you-ok.wav` | Plays audio (fallback format) |

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
