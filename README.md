# are-you-ok

> 一个面向任意 AI agent 的快速、轻量状态汇报 Skill。

**[English version →](README_EN.md)**

---

## 定位

`are-you-ok` 是一个高频、快速、通用的状态检查 Skill，设计目标：

- **人类用户** 随时查看 agent 正在做什么
- **监管 agent** 批量轮询子 agent 的运行状态
- **任意 AI 模型** 在交接上下文前快速输出当前状态

不绑定 Claude Code——任何支持 SKILL.md 格式的 agent 都可以使用。

---

## 输出示例

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

## 触发方式

### 人类触发
```
are you ok  ·  你还好吗  ·  状态怎么样  ·  汇报进度  ·  当前状态
```

### Agent 触发（机器对机器）
监管 agent 或编排器在消息中包含：
```
!status
```
或结构化调用：
```json
{"skill": "are-you-ok", "caller": "<agent-id>"}
```

---

## 安装

```
~/.claude/skills/are-you-ok/
  SKILL.md
  scripts/
    status-check.ps1   ← Windows
    status-check.sh    ← Mac / Linux
```

**Mac / Linux 额外步骤：**
```bash
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh
```

---

## 适用环境

| 平台 | 要求 |
|------|------|
| Windows | PowerShell 5.1+ |
| Mac / Linux | bash |
| 全平台 | `git` 可选 |

---

## 设计结构

| 层级 | 文件 | token 成本 |
|------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens（始终加载） |
| L2 | `SKILL.md` 正文 | 触发后加载 |
| L3 | `scripts/status-check.*` | 执行不读取，零 token 成本 |
