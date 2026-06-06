# are-you-ok &nbsp;![雷总唱歌版](https://img.shields.io/badge/-%E9%9B%B7%E6%80%BB%E5%94%B1%E6%AD%8C%E7%89%88-ff6600?style=flat-square)

> 轻量状态查看 Skill —— 检查 Agent 进度，网络中断后自动恢复 context，还有雷总唱歌 🎤

[![LINUX DO](https://img.shields.io/badge/LINUX_DO-社区讨论-blue?logo=discourse&logoColor=white)](https://linux.do/u/zzzz/activity)

**[English →](README_EN.md)**

---

## 快速安装

**Windows（PowerShell）：**
```powershell
irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex
```

**Mac / Linux：**
```bash
curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash
```

安装后重启 Claude Code，说 `are you ok` 即可。

<details>
<summary>手动安装</summary>

```bash
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

## 解决什么问题

长时间使用 Claude Code 时，你可能会遇到：

- 不知道 Agent 当前做到哪一步了
- 网络断开重连后，Agent 忘记了中断前的状态
- 想快速确认 git 状态、任务列表、记忆条数，但不想打断当前对话

`are-you-ok` 用一句话触发完整的状态快照，并在网络恢复时**自动**引导 Agent 安全地接续工作。

---

## 四种模式

| 模式 | 触发方式 | 作用 |
|------|---------|------|
| **Agent 状态** | `are you ok` · `你还好吗` · `状态怎么样` · `汇报进度` | 查看模型、工具、任务、记忆 |
| **项目进度** | `项目进度` · `项目状态` · `项目情况` · `汇报项目` | 查看项目名、版本、提交、变更文件 |
| **快速一瞥** | `?` · `??` · `???` | 先回答问题，末尾追加状态摘要 |
| **网络恢复** | 自动触发（无需输入） | 检测断网信号，输出恢复步骤 |
| **语音彩蛋** | `hello` · `thank you` · `thank you very much` | 静默播放音频 + 文字彩蛋 |
| **超级彩蛋** | `雷总唱歌给我听` | 播放完整18秒音频 + 文字彩蛋 |

Agent 程序化调用：`!status` 或 `{"skill":"are-you-ok","mode":"agent|project"}`

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

---

## 网络恢复模式

这是 `are-you-ok` 最独特的功能。当对话上下文中出现网络错误信号时**自动触发**，无需用户输入，直接输出断网摘要与恢复步骤。

**网络恢复输出示例：**
```
👌 网络恢复 ─── 2026-06-04 10:30
│
│  网络   ✓ 已恢复
│  git    2Δ 未提交  ·  "feat: 新增用户搜索"
│  任务   ●1 进行中  ○2 待处理
│
├─ 恢复步骤 ────────────────────────────────────
│  1. 回顾中断点：哪一步工具调用可能未完成？
│  2. 用只读操作验证实际状态（Read/Grep），不要直接继续写
│  3. 有后台任务时确认是否仍在运行还是已挂起
│  4. 确认后再继续下一步操作
╰────────────────────────────────────────────────
```

**支持识别的断网信号：**

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

## 适用环境

| 平台 | 要求 |
|------|------|
| Windows | PowerShell 5.1+ |
| Mac | bash · afplay（系统自带） |
| Linux | bash · mpg123 或 ffplay（音频可选） |
| 全平台 | `git` 可选 |

---

## 语音彩蛋

全部**静默后台播放**，不弹出任何播放器窗口。

| 触发词 | 音频文件 | 时长 | 效果 |
|------|---------|------|------|
| `are you ok` | `eleijun-are-you-ok.mp3` | ~2s | 播放 + 显示状态框 |
| `hello` · `thank you` · `thank you very much` | `eleijun-hello.mp3` | ~3.7s | 播放 + 文字彩蛋 |
| `雷总唱歌给我听` | `eleijun-super.mp3` | ~18s | 完整音频 + 文字彩蛋 |

三个触发词播放同一段音频（Hello~ Thank you~ Thank you very much!），触发时显示：
```
╭──────────────────────────────────╮
│     🎤  "Hello~ Thank you~"      │
│      "Thank you very much!"      │
│              Friday              │
│         Shanghai · 2015          │
╰──────────────────────────────────╯
```
> 显示当天星期几和地理城市（IP 自动定位，无法定位时显示 China）。

> 音频文件缺失时自动降级为纯文字版，不影响正常使用。

**启用音频：** 将 `.mp3`（或 `.wav`）文件放入 `assets/` 文件夹，触发时自动播放。
> 素材来源：搜「雷军 are you ok」截取对应片段，建议 64kbps 单声道编码。

**关闭所有音频：** 在 `assets/` 目录下创建空文件 `.no-audio`，静默跳过，不影响状态框输出。

```bash
touch ~/.claude/skills/are-you-ok/assets/.no-audio
```

---

## 设计原则

**快速 · 轻量 · 通用** — 脚本只采集元数据，不读取任何实际内容。任何改动前先问：会不会增加额外负担？

| 层级 | 文件 | Token 成本 |
|------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens |
| L2 | `SKILL.md` 正文 | 触发后加载 |
| L3 | `scripts/status-check.*` | 执行不读取，零 token |
