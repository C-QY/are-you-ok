# are-you-ok【雷总唱歌版】

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![LINUX DO](https://img.shields.io/badge/LINUX_DO-社区讨论-blue?logo=discourse&logoColor=white)](https://linux.do/u/zzzz/activity)

> 一句话查看 Claude Code Agent 状态 — 自动恢复断网上下文，还有雷总唱歌 🎤

**[English →](README_EN.md)**

---

## ✨ 功能亮点

👌 说 `are you ok` — 立即获取模型、任务、git、记忆的完整快照  
🔄 断网自动恢复 — 检测断网信号，自动输出恢复步骤，无需任何输入  
⚡ 快速一瞥 — 用 `?` 在当前对话末尾追加状态摘要，不打断节奏  
🎵 彩蛋内置 — 说 `雷总唱歌给我听`，后台静默播放 18 秒完整音频  

---

## 快速开始

**Windows（PowerShell）：**
```powershell
irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex
```

**Mac / Linux：**
```bash
curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash
```

安装后重启 Claude Code，说 `are you ok` 即可。已安装的用户重新运行同一命令即可更新。

<details>
<summary>手动安装</summary>

```bash
git clone https://github.com/C-QY/are-you-ok ~/.claude/skills/are-you-ok
chmod +x ~/.claude/skills/are-you-ok/scripts/status-check.sh  # Mac/Linux
```
</details>

---

## 效果预览

**Agent 模式**（`are you ok`）：
```
👌  状态检查 ─── 2026-06-06 14:32
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
👌  项目状态 ─── 2026-06-06 14:32
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
├─ 最近变更 ────────────────────────────────────
│  src/components/SearchBar.tsx
├─ 记忆列表 ────────────────────────────────────
│  project-alpha   后端迁移目标与当前阶段
╰────────────────────────────────────────────────
```

---

## 触发词速查

| 触发词 | 模式 | 输出 |
|--------|------|------|
| `are you ok` · `你还好吗` · `状态怎么样` | Agent 状态 | 模型、任务、git、记忆 |
| `项目进度` · `项目状态` · `project status` | 项目进度 | 版本、提交记录、变更文件 |
| `?` · `??` · `???` | 快速一瞥 | 先答问题，末尾追加状态 |
| 网络错误信号（自动） | 网络恢复 | 断网摘要 + 恢复步骤 |
| `hello` / `thank you` / `thank you very much` | 语音彩蛋 | 后台播音频 + 文字框 |
| `雷总唱歌给我听` | 超级彩蛋 | 完整 18 秒 + 文字框 |

程序化调用：`!status` 或 `{"skill":"are-you-ok","mode":"agent|project"}`

---

## 彩蛋 🎵

全部后台静默播放，不弹出任何播放器窗口。

| 触发词 | 音频文件 | 时长 |
|--------|---------|------|
| `are you ok` | `eleijun-are-you-ok.mp3` | ~2s |
| `hello` / `thank you` / `thank you very much`（任意一个） | `eleijun-hello.mp3` | ~3.7s |
| `雷总唱歌给我听` | `eleijun-super.mp3` | ~18s |

触发时显示：
```
╭──────────────────────────────────╮
│     🎤  "Hello~ Thank you~"      │
│      "Thank you very much!"      │
│              Friday              │
│           2026-06-06             │
╰──────────────────────────────────╯
```

音频文件不在仓库内（版权原因），需自行放入 `assets/` 目录。缺失时自动降级为纯文字框，不影响正常使用。

> 素材来源：B 站搜「雷军 are you ok」，截取对应片段，64kbps 单声道编码。

**关闭音频：** 在 `assets/` 目录创建 `.no-audio` 空文件，音频跳过，文字框正常输出。

```bash
touch ~/.claude/skills/are-you-ok/assets/.no-audio
```

---

## 网络恢复

当对话上下文中出现网络错误信号时**自动触发**，无需任何输入：

```
👌  网络恢复 ─── 2026-06-06 10:30
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

支持识别：Claude Code · ChatGPT · GitHub Copilot · Cursor · Gemini · 通用底层信号（ECONNRESET / 502 / 503 等）

---

## 设计原则

**快速 · 轻量 · 通用** — 脚本只采集元数据，不读取任何文件内容。

| 层级 | 文件 | Token 成本 |
|------|------|-----------|
| L1 | `SKILL.md` frontmatter | ~100 tokens |
| L2 | `SKILL.md` 正文 | 触发后加载 |
| L3 | `scripts/status-check.*` | 执行不读取，零 token |

---

## 适用平台

| 平台 | 要求 |
|------|------|
| Windows | PowerShell 5.1+ |
| Mac | bash · afplay（系统自带） |
| Linux | bash · mpg123 或 ffplay（音频可选） |
| 全平台 | `git` 可选 |
