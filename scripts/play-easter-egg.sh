#!/usr/bin/env bash
# play-easter-egg.sh
# Triggered only by the exact phrase "are you ok".
# Plays assets/eleijun-are-you-ok.mp3 if present; falls back to text.

assets_dir="$(dirname "$0")/../assets"
mp3="$assets_dir/eleijun-are-you-ok.mp3"
gif="$assets_dir/eleijun-are-you-ok.gif"
played=false

# Open GIF in default viewer (non-blocking)
if [ -f "$gif" ]; then
  if command -v open &>/dev/null; then
    open "$gif" &      # Mac
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$gif" &  # Linux
  fi
fi

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
  echo "easter_egg:ok"
fi
