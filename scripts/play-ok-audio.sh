#!/usr/bin/env bash
# play-ok-audio.sh
# Triggered only by the exact phrase "are you ok".
# Plays assets/eleijun-are-you-ok.mp3 if present; falls back to text.
# To disable audio: create assets/.no-audio

assets_dir="$(dirname "$0")/../assets"
mp3="$assets_dir/eleijun-are-you-ok.mp3"
played=false

[ -f "$assets_dir/.no-audio" ] && exit 0

if [ -f "$mp3" ]; then
  if command -v afplay &>/dev/null; then
    afplay "$mp3" &     # Mac
    played=true
  elif command -v mpg123 &>/dev/null; then
    mpg123 -q "$mp3" &  # Linux
    played=true
  elif command -v ffplay &>/dev/null; then
    ffplay -nodisp -autoexit -loglevel quiet "$mp3" &
    played=true
  fi
fi

if [ "$played" = false ]; then
  echo "ok_audio:not_found"
fi
