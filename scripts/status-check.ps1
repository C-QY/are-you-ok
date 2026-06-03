# status-check.ps1 — Layer 3 data collector for the are-you-ok skill
# Outputs workspace metadata only. Memory content is read by the agent, not this script.

$cwd = (Get-Location).Path

# CWD
Write-Output "cwd:$cwd"

# GIT
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -eq 0) {
        $branch     = git rev-parse --abbrev-ref HEAD
        $shortStat  = git status --short 2>$null
        $count      = if ($shortStat) { ($shortStat | Measure-Object).Count } else { 0 }
        $lastCommit = git log --format="%s" -1 2>$null
        Write-Output "git_branch:$branch"
        Write-Output "git_uncommitted:$count"
        Write-Output "git_last:$lastCommit"

        $changed = @()
        $changed += git diff --name-only 2>$null
        $changed += git diff --cached --name-only 2>$null
        $changed += git ls-files --others --exclude-standard 2>$null
        $changed | Select-Object -Unique -First 10 | ForEach-Object {
            Write-Output "changed_file:$_"
        }
    } else {
        Write-Output "git_branch:none"
    }
} catch {
    Write-Output "git_branch:none"
}

# MEMORY — count only, content is for the agent to read directly
$memoryRoot = Join-Path $env:USERPROFILE ".claude\projects"
if (Test-Path $memoryRoot) {
    $memFile = Get-ChildItem -Path $memoryRoot -Recurse -Filter "MEMORY.md" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($memFile) {
        $entryCount = (Select-String -Path $memFile.FullName -Pattern "^- \[").Count
        Write-Output "memory_path:$($memFile.FullName)"
        Write-Output "memory_count:$entryCount"
    } else {
        Write-Output "memory_count:0"
    }
} else {
    Write-Output "memory_count:0"
}
