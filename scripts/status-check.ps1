# status-check.ps1 - Layer 3 data collector for the are-you-ok skill (Windows)
# Usage: status-check.ps1 [-EasterEgg] [-AudioOnly -AudioClip <name>]
param([switch]$EasterEgg, [switch]$NetworkCheck, [switch]$AudioOnly, [string]$AudioClip = "")

# NETWORK CHECK - quick DNS probe, runs before data collection
if ($NetworkCheck) {
    try {
        [System.Net.Dns]::GetHostAddresses("api.anthropic.com") | Out-Null
        Write-Output "network_status:ok"
    } catch {
        Write-Output "network_status:fail"
    }
}

# AUDIO - play clip first so it starts while data is collected
$clipToPlay = ""
if ($EasterEgg) { $clipToPlay = "are-you-ok" }
if ($AudioClip -ne "") { $clipToPlay = $AudioClip }

if ($clipToPlay -ne "") {
    $noAudio = Join-Path $PSScriptRoot "..\assets\.no-audio"
    $mp3 = Join-Path $PSScriptRoot "..\assets\eleijun-$clipToPlay.mp3"
    $wav = Join-Path $PSScriptRoot "..\assets\eleijun-$clipToPlay.wav"
    if (Test-Path $noAudio) {
        # audio disabled by user
    } elseif (Test-Path $mp3) {
        $fullPath = (Resolve-Path $mp3).Path
        Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile', '-Command',
            "Add-Type -AssemblyName PresentationCore; `$p = New-Object System.Windows.Media.MediaPlayer; `$p.Open([uri]::new('$fullPath')); `$p.Play(); Start-Sleep 20"
        Write-Output 'easter_egg:playing'
    } elseif (Test-Path $wav) {
        $fullPath = (Resolve-Path $wav).Path
        Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile', '-Command',
            "Add-Type -AssemblyName System.Windows.Forms; (New-Object System.Media.SoundPlayer '$fullPath').PlaySync()"
        Write-Output 'easter_egg:playing'
    } else {
        Write-Output 'easter_egg:missing'
    }
}

# CITY DETECTION - quick IP lookup for easter egg attribution; default to China on failure
$city = "China"
try {
    $geo = Invoke-RestMethod "http://ip-api.com/json/?fields=city" -TimeoutSec 3 -ErrorAction Stop
    if ($geo.city) { $city = $geo.city }
} catch {}
Write-Output "city:$city"

# AUDIO ONLY - pure easter egg triggers: return timestamp + clip name, skip data collection
if ($AudioOnly) {
    Write-Output "timestamp:$(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Write-Output "audio_clip:$clipToPlay"
    exit 0
}

$cwd = (Get-Location).Path

Write-Output "timestamp:$(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# CWD
Write-Output "cwd:$cwd"

# PROJECT TYPE & NAME
$projectType = "unknown"
$projectName = (Split-Path $cwd -Leaf)

if (Test-Path (Join-Path $cwd "package.json")) {
    $projectType = "Node.js"
    try {
        $pkg = Get-Content (Join-Path $cwd "package.json") -Raw | ConvertFrom-Json
        if ($pkg.name) { $projectName = $pkg.name }
    } catch {}
} elseif (Test-Path (Join-Path $cwd "pyproject.toml")) { $projectType = "Python"
} elseif (Test-Path (Join-Path $cwd "setup.py"))       { $projectType = "Python"
} elseif (Test-Path (Join-Path $cwd "go.mod"))         { $projectType = "Go"
} elseif (Test-Path (Join-Path $cwd "Cargo.toml"))     { $projectType = "Rust"
} elseif (Test-Path (Join-Path $cwd "pom.xml"))        { $projectType = "Java"
} elseif ((Get-ChildItem $cwd -Filter "*.csproj" -ErrorAction SilentlyContinue) -or
          (Get-ChildItem $cwd -Filter "*.sln"    -ErrorAction SilentlyContinue)) {
    $projectType = ".NET"
}

Write-Output "project_name:$projectName"
Write-Output "project_type:$projectType"

# GIT
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -eq 0) {
        $branch    = git rev-parse --abbrev-ref HEAD
        $shortStat = git status --short 2>$null
        $count     = if ($shortStat) { ($shortStat | Measure-Object).Count } else { 0 }
        $tag       = git describe --tags --abbrev=0 2>$null
        if (-not $tag) { $tag = "none" }
        $commits   = git log --format="%h %s" -3 2>$null

        Write-Output "git_branch:$branch"
        Write-Output "git_uncommitted:$count"
        Write-Output "git_tag:$tag"
        $commits | ForEach-Object { Write-Output "git_log:$_" }

        $changed  = @()
        $changed += git diff --name-only 2>$null
        $changed += git diff --cached --name-only 2>$null
        $changed += git ls-files --others --exclude-standard 2>$null
        $changed | Select-Object -Unique -First 10 | ForEach-Object {
            Write-Output "changed_file:$_"
        }
    } else {
        Write-Output "git_branch:none"
        Write-Output "git_tag:none"
    }
} catch {
    Write-Output "git_branch:none"
    Write-Output "git_tag:none"
}

# CLAUDE.md - first meaningful line (non-empty, non-heading)
$claudeMd = Join-Path $cwd "CLAUDE.md"
if (Test-Path $claudeMd) {
    $brief = Get-Content $claudeMd | Where-Object {
        $_ -and $_ -notmatch "^#" -and $_.Trim() -ne ""
    } | Select-Object -First 1
    if ($brief) { Write-Output "claude_brief:$($brief.Trim())" }
}

# MEMORY - count only; omit entirely when not found (agent skips the memory line)
$claudeRoot = Join-Path $env:USERPROFILE ".claude"
if (Test-Path $claudeRoot) {
    $memFile = Get-ChildItem -Path $claudeRoot -Recurse -Depth 6 -Filter "MEMORY.md" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($memFile) {
        $entryCount = (Select-String -Path $memFile.FullName -Pattern "^- \[").Count
        Write-Output "memory_path:$($memFile.FullName)"
        Write-Output "memory_count:$entryCount"
    }
}

exit 0
