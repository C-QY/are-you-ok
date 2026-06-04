# play-ok-audio.ps1
# Triggered only by the exact phrase "are you ok".
# Uses default system player for instant non-blocking playback.
# To disable audio: create assets/.no-audio

$assetsDir = Join-Path $PSScriptRoot "..\assets"
$mp3 = Join-Path $assetsDir "eleijun-are-you-ok.mp3"
$wav = Join-Path $assetsDir "eleijun-are-you-ok.wav"
$noAudio = Join-Path $assetsDir ".no-audio"

if (Test-Path $noAudio) { exit 0 }

if (Test-Path $mp3) {
    Start-Process $mp3
} elseif (Test-Path $wav) {
    Start-Process $wav
} else {
    Write-Output 'ok_audio:not_found'
}
