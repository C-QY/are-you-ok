# are-you-ok skill installer for Windows (PowerShell 5.1+)
# Usage: irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex

$repo = "https://github.com/C-QY/are-you-ok"
$dest = "$env:USERPROFILE\.claude\skills\are-you-ok"
$tmp  = "$env:TEMP\are-you-ok-install"

if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
git clone $repo $tmp
if ($LASTEXITCODE -ne 0) { Write-Error "Clone failed. Make sure git is installed."; exit 1 }

if (Test-Path "$dest\.git") {
    # Already installed — update in place to avoid directory-in-use errors
    Remove-Item $tmp -Recurse -Force
    Push-Location $dest
    git pull origin master
    if ($LASTEXITCODE -ne 0) { Write-Error "Update failed."; exit 1 }
    Pop-Location
} else {
    New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
    Copy-Item $tmp $dest -Recurse -Force
    Remove-Item $tmp -Recurse -Force
}

Write-Host ""
Write-Host "  are-you-ok installed." -ForegroundColor Green
Write-Host "  Restart Claude Code, then say 'are you ok'."
Write-Host ""
