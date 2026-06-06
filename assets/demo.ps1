# Demo script - simulates are-you-ok skill output
param([string]$Mode = "agent")

if ($Mode -eq "agent") {
    Write-Host ""
    Write-Host "👌  状态检查 ─── 2026-06-06 14:32" -ForegroundColor Green
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│  模型   claude-sonnet-4-6" -ForegroundColor White
    Write-Host "│  目录   ~/projects/my-app" -ForegroundColor White
    Write-Host "│  git    main · 2Δ · `"feat: 新增用户搜索`"" -ForegroundColor White
    Write-Host "│  记忆   4 条" -ForegroundColor White
    Write-Host "│  任务   ●2 进行中  ○1 待处理  ✓3 已完成" -ForegroundColor White
    Write-Host "│  工具   Read Write Edit Glob Grep" -ForegroundColor White
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "├─ 进行中 ──────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "│  ●  实现结果列表的分页功能" -ForegroundColor Yellow
    Write-Host "│  ●  为认证模块编写单元测试" -ForegroundColor Yellow
    Write-Host "├─ 待处理 ──────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "│  ○  更新 API 文档" -ForegroundColor Cyan
    Write-Host "├─ 记忆列表 ────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "│  project-alpha   后端迁移目标与当前阶段" -ForegroundColor White
    Write-Host "╰────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

if ($Mode -eq "easter") {
    Write-Host ""
    Write-Host "╭──────────────────────────────────╮" -ForegroundColor Magenta
    Write-Host "│     🎤  `"Hello~ Thank you~`"      │" -ForegroundColor Magenta
    Write-Host "│      `"Thank you very much!`"      │" -ForegroundColor Magenta
    Write-Host "│              Friday              │" -ForegroundColor Magenta
    Write-Host "│           2026-06-06             │" -ForegroundColor Magenta
    Write-Host "╰──────────────────────────────────╯" -ForegroundColor Magenta
    Write-Host ""
}
