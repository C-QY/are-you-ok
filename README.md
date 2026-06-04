# are-you-ok

> 专为用户和监管 Agent 设计的轻量 Skill，可快速查看任意 AI Agent 的当前状态，或正在开发项目的进度与变更。

**[English version →](README_EN.md)**

---

## 三种模式

| 模式 | 聚焦 | 触发方式 |
|------|------|--------|
| **Agent 状态** | 模型、工具、任务、记忆 | `are you ok` · `你还好吗` · `状态怎么样` · `汇报进度` |
| **项目进度** | 项目名、版本、提交、变更 | `项目进度` · `项目状态` · `项目情况` · `汇报项目` |
| **快速一瞥** | 当前状态追加在回复末尾 | `?` · `??` · `???`（先回答，再追加状态）|
| **网络恢复** | 网络状态、未提交变更、恢复步骤 | **自动触发**，无需用户输入 |

Agent 调用：`!status` 或 `{"skill":"are-you-ok","mode":"agent|project"}`

---

## 输出示例

**Agent 模式**（`are you ok`）：
```
👌 状态检查 ─── 2026-06-03 14:32
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

**项目模式**（`项目进度`）：
```
👌 项目状态 ─── 2026-06-03 14:32
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
│  i7j8k9l  chore: 升级依赖至最新版
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

**网络恢复模式**（自动触发，无需输入）：
```
👌 网络恢复 ─── 2026-06-04 10:30
│
│  网络   ✓ 已恢复
│  git    2Δ 未提交  ·  "feat: 新增用户搜索"
│  任务   ●1 进行中  ○2 待处理
│
├─ 恢复步骤 ────────────────────────────────────
│  1. 回顾中断点：哪一步工具调用可能未完成？
│  2. 用只读操作验证实际状态（Read/Grep）不要直接继续写
│  3. 有后台任务时确认是否仍在运行还是已挂起
│  4. 确认后再继续下一步操作
╰────────────────────────────────────────────────
```

---

## 网络恢复模式

当对话上下文中出现**网络错误信号**时自动触发，无需用户输入任何关键词。

**自动识别以下主流工具的网络中断：**

| 工具 | 识别的错误信号 |
|------|--------------|
| Claude Code | `socket connection was closed unexpectedly` · `Streamable HTTP error` |
| ChatGPT / OpenAI | `network error` · `Failed to fetch` · `The network connection was lost` |
| GitHub Copilot | `Copilot is not reachable` · `Connection to GitHub Copilot failed` |
| Cursor | `Could not connect to language model` |
| Gemini | `UNAVAILABLE` · `deadline exceeded` · `transport error` |
| 通用底层信号 | `ECONNRESET` · `ETIMEDOUT` · `ENOTFOUND` · `502` · `503` |

**不触发的情况：** 用户主动结束对话（无错误信号）、token 超限、内容违规等业务错误。

---

## 安装

**Windows（PowerShell）：**
```powershell
irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex
```

**Mac / Linux：**
```bash
curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash
```

安装完成后重启 Claude Code，说 `are you ok` 即可触发。

<details>
<summary>手动安装</summary>

```
git clone https://github.com/C-QY/are-you-ok
```
将 `are-you-ok/` 整个文件夹复制到：
```
~/.claude/skills/are-you-ok/
```
Mac / Linux 额外执行：
```bash
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh
```
</details>

---

## 适用环境

| 平台 | 要求 |
|------|------|
| Windows | PowerShell 5.1+ |
| Mac / Linux | bash |
| 全平台 | `git` 可选 |

---

## 彩蛋

触发词恰好是 `are you ok`（大小写不限）时触发，其他状态词不触发。默认开启。

**效果：**
```
╭──────────────────────────────────╮
│  🎤  "Are you OK?"               │
│      Lei Jun · Shanghai · 2015   │
╰──────────────────────────────────╯
```
彩蛋结束后，状态框正常输出。

---

### 启用音频

将 `eleijun-are-you-ok.mp3`（或 `eleijun-are-you-ok.wav`）放入 `assets/` 文件夹，触发时自动播放。

> B 站搜「雷军 are you ok」，截取约 3 秒片段，保存为 `eleijun-are-you-ok.mp3` 即可。

支持的文件：

| 文件 | 效果 |
|------|------|
| `assets/eleijun-are-you-ok.mp3` | 播放音频 |
| `assets/eleijun-are-you-ok.wav` | 播放音频（备选格式） |

没有任何文件时，自动降级为纯文字版彩蛋，不影响正常使用。

---

### 关闭彩蛋

删除 `assets/` 下的媒体文件即可关闭对应效果。

如需完全禁用彩蛋逻辑，删除以下两个文件：
```
scripts/play-easter-egg.ps1
scripts/play-easter-egg.sh
```

---

## 设计原则

**快速 · 轻量 · 通用** — 脚本只采集元数据，不读取任何实际内容；Memory 内容由 agent 自行读取。任何改动前先问：会不会增加额外负担？

| 层级 | 文件 | token 成本 |
|------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens |
| L2 | `SKILL.md` 正文 | 触发后加载 |
| L3 | `scripts/status-check.*` | 执行不读取，零 token |
