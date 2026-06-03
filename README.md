# are-you-ok

> 一个让 Claude Code agent 汇报自身当前状态的 Skill。

**[English version →](README_EN.md)**

---

## 这个 Skill 做什么

调用后，agent 会打印一份结构化的状态快照，涵盖：

- **agent** — 当前使用的模型
- **cwd** — 工作目录
- **git** — 分支、未提交数量、最后一条 commit
- **memory** — 持久化记忆条目数量
- **tasks** — 进行中 / 待办 / 已完成的任务数量
- **tools** — 当前 session 允许使用的工具
- **jobs** — 后台运行中的任务

输出示例：

```
are you ok? · 2026-06-03 14:32

agent     claude-sonnet-4-6
cwd       ~/projects/my-app
git       main · 2 uncommitted · last: "feat: add user search"
memory    4 entries
tasks     2 active, 1 pending, 3 done
tools     Bash Read Write Edit Glob Grep
jobs      none

tasks (active)
  · implement pagination for the results list
  · write unit tests for the auth module

tasks (pending)
  · update API documentation

memory
  project-alpha    后端迁移目标与当前阶段
  feedback-tests   偏好集成测试而非 mock 单元测试
  ...

recent changes
  src/components/SearchBar.tsx
  src/api/users.ts
```

## 触发方式

```
are you ok
你还好吗
状态怎么样
汇报进度
当前状态
你现在在做什么
```

## 安装方式

将以下两个文件复制到你的 Claude Code skills 目录：

```
~/.claude/skills/are-you-ok/
  SKILL.md
  scripts/status-check.ps1
```

或放入项目的 `.claude/` 文件夹中。

## 适用环境

- PowerShell 5.1+（Windows）
- `git` 可选，不存在时跳过 git 相关字段

## 设计结构

| 层级 | 文件 | 说明 |
|------|------|------|
| L1 | `SKILL.md` frontmatter | 触发判断，约 100 tokens |
| L2 | `SKILL.md` 正文 | 渲染指令，触发后加载 |
| L3 | `scripts/status-check.ps1` | 确定性数据采集，不占用上下文 |

脚本只采集工作区元数据（目录、git、memory 条目数），不读取也不输出任何实际内容。Memory 的具体内容由 agent 自行读取并决定展示方式。
