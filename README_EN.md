# are-you-ok

> A lightweight status skill for Claude Code — check agent progress in one phrase, automatically recover context after a network drop, and hidden audio easter eggs 🎤

[![LINUX DO](https://img.shields.io/badge/LINUX_DO-Community-blue?logo=discourse&logoColor=white)](https://linux.do/u/zzzz/activity)

**[中文 →](README.md)**

---

## Quick Install

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex
```

**Mac / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash
```

Restart Claude Code after installing, then say `are you ok`.

<details>
<summary>Manual install</summary>

```bash
git clone https://github.com/C-QY/are-you-ok
```
Copy the `are-you-ok/` folder to:
```
~/.claude/skills/are-you-ok/
```
Mac / Linux — one extra step:
```bash
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh
```
</details>

---

## What Problem Does It Solve

During long Claude Code sessions, you might run into:

- Not knowing what step the agent is currently on
- Network drops that make the agent lose track of where it was
- Wanting a quick snapshot of git state, task list, and memory without interrupting the flow

`are-you-ok` delivers a full status snapshot in one phrase, and **automatically** guides the agent back on track after a network interruption.

---

## Four Modes

| Mode | Trigger | What it shows |
|------|---------|---------------|
| **Agent Status** | `are you ok` · `status check` · `report status` | Model, tools, tasks, memory |
| **Project Status** | `project status` · `project progress` · `show project` | Name, version, commits, changed files |
| **Inline Peek** | `?` · `??` · `???` | Answers first, appends status summary at the end |
| **Network Recovery** | Auto-triggered — no input needed | Detects network error signals, outputs recovery steps |
| **Easter Egg** | `hello` · `thank you` · `thank you very much` | Silent audio playback + easter egg box |
| **Super Easter Egg** | `are you ok` + `hello` + `thank you` + `thank you very much` in one message | Full 18-second audio + status box |

Programmatic call: `!status` or `{"skill":"are-you-ok","mode":"agent|project"}`

---

## Sample Output

**Agent mode** (`are you ok`):
```
👌 STATUS ─── 2026-06-03 14:32
│
│  agent    claude-sonnet-4-6
│  cwd      ~/projects/my-app
│  git      main · 2Δ · "feat: add user search"
│  memory   4 entries
│  tasks    ●2 active  ○1 pending  ✓3 done
│  tools    Read Write Edit Glob Grep
│
├─ ACTIVE ───────────────────────────────────────
│  ●  implement pagination for the results list
│  ●  write unit tests for the auth module
├─ PENDING ──────────────────────────────────────
│  ○  update API documentation
├─ MEMORY ───────────────────────────────────────
│  project-alpha   backend migration goals
╰────────────────────────────────────────────────
```

**Project mode** (`project status`):
```
👌 PROJECT STATUS ─── 2026-06-03 14:32
│
│  project  my-app  [Node.js]
│  version  v1.2.0
│  cwd      ~/projects/my-app
│  git      main · 3Δ · "feat: add user search"
│  memory   4 entries
│  tasks    ●2 active  ○3 pending  ✓8 done
│  agent    claude-sonnet-4-6
│
├─ PROJECT BRIEF ────────────────────────────────
│  Full-stack Node.js app, RESTful API + React frontend
├─ RECENT COMMITS ───────────────────────────────
│  a1b2c3d  feat: add user search
│  e4f5g6h  fix: login redirect issue
│  i7j8k9l  chore: upgrade dependencies
├─ ACTIVE ───────────────────────────────────────
│  ●  implement pagination for the results list
├─ PENDING ──────────────────────────────────────
│  ○  update API documentation
├─ RECENT CHANGES ───────────────────────────────
│  src/components/SearchBar.tsx
├─ MEMORY ───────────────────────────────────────
│  project-alpha   backend migration goals
╰────────────────────────────────────────────────
```

---

## Network Recovery Mode

This is `are-you-ok`'s most unique feature. When network error signals appear in the conversation context, it **auto-triggers** — no user input required — and immediately outputs a disconnect summary with recovery steps.

**Sample network recovery output:**
```
👌 NETWORK RECOVERY ─── 2026-06-04 10:30
│
│  network  ✓ restored
│  git      2Δ uncommitted  ·  "feat: add user search"
│  tasks    ●1 active  ○2 pending
│
├─ RECOVERY STEPS ───────────────────────────────
│  1. Identify the interrupted tool call / operation
│  2. Verify actual state with read-only ops first (Read/Grep)
│  3. Check background jobs — still running or hung?
│  4. Confirm state before resuming any writes
╰────────────────────────────────────────────────
```

**Recognized network error signals:**

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

## Requirements

| Platform | Requirement |
|----------|-------------|
| Windows | PowerShell 5.1+ |
| Mac | bash · afplay (built-in) |
| Linux | bash · mpg123 or ffplay (optional, for audio) |
| All platforms | `git` (optional) |

---

## Easter Egg Audio

All clips play **silently in the background** — no player window ever pops up.

| Trigger | Audio file | Duration | Effect |
|---------|-----------|----------|--------|
| `are you ok` | `eleijun-are-you-ok.mp3` | ~2s | Plays + status box |
| `hello` · `thank you` · `thank you very much` | `eleijun-hello.mp3` | ~3.7s | Plays + easter egg box |
| All four triggers in one message | `eleijun-super.mp3` | ~18s | Full audio + status box |

All three triggers play the same clip ("Hello~ Thank you~ Thank you very much!") and show:
```
╭──────────────────────────────────╮
│     🎤  "Hello~ Thank you~"      │
│      "Thank you very much!"      │
│              Friday              │
│         Shanghai · 2015          │
╰──────────────────────────────────╯
```
> Shows the current weekday and your location city (auto-detected by IP; falls back to Shanghai).

> Falls back to text-only when no audio file is present — the skill works normally either way.

**Enable audio:** Place the `.mp3` (or `.wav`) files in the `assets/` folder. They play automatically on trigger.
> Source material: search "雷军 are you ok" and trim the phrases; encode at 64 kbps mono.

**Disable all audio:** Create an empty `.no-audio` file in the `assets/` directory. Audio is silently skipped; the easter egg boxes still appear.

```bash
touch ~/.claude/skills/are-you-ok/assets/.no-audio
```

---

## Design Principles

**Fast · Lightweight · Universal** — scripts collect metadata only, never actual file content. Before any change, ask: does this add extra overhead?

| Layer | File | Token cost |
|-------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens |
| L2 | `SKILL.md` body | Loaded on trigger |
| L3 | `scripts/status-check.*` | Executed, not read — zero token cost |
