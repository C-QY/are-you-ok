# play-easter-egg.ps1
# Triggered only by the exact phrase "are you ok".
# Plays assets/leijun.mp3 (or .wav) if present; falls back to text.

$assetsDir = Join-Path $PSScriptRoot "..\assets"
$mp3 = Join-Path $assetsDir "leijun.mp3"
$wav = Join-Path $assetsDir "leijun.wav"

$played = $false

if (Test-Path $mp3) {
    try {
        Add-Type -AssemblyName presentationCore -ErrorAction SilentlyContinue
        $player = New-Object System.Windows.Media.MediaPlayer
        $player.Open([System.Uri]::new((Resolve-Path $mp3).Path))
        $player.Play()
        Start-Sleep 4
        $player.Stop()
        $played = $true
    } catch {}
}

if (-not $played -and (Test-Path $wav)) {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        $sound = New-Object System.Media.SoundPlayer $wav
        $sound.PlaySync()
        $played = $true
    } catch {}
}

if (-not $played) {
    Write-Output 'easter_egg:ok'
}
