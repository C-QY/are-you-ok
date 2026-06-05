# are-you-ok skill installer for Windows (PowerShell 5.1+)
# Usage: irm https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.ps1 | iex

$repo = "https://github.com/C-QY/are-you-ok"
$dest = "$env:USERPROFILE\.claude\skills\are-you-ok"

New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null

if (Test-Path (Join-Path $dest ".git")) {
    Push-Location $dest
    git pull
    $exitCode = $LASTEXITCODE
    Pop-Location
    if ($exitCode -ne 0) { Write-Error "Update failed. Check your network and try again."; exit 1 }
    Write-Host ""
    Write-Host "  are-you-ok updated." -ForegroundColor Green
} else {
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    git clone $repo $dest
    if ($LASTEXITCODE -ne 0) { Write-Error "Clone failed. Make sure git is installed."; exit 1 }
    Write-Host ""
    Write-Host "  are-you-ok installed." -ForegroundColor Green
}

Write-Host "  Restart Claude Code, then say 'are you ok'."
Write-Host ""
