#!/usr/bin/env bash
# play-easter-egg.sh
# Triggered only by the exact phrase "are you ok".
# Plays assets/leijun.mp3 if present; falls back to text.

assets_dir="$(dirname "$0")/../assets"
mp3="$assets_dir/leijun.mp3"
played=false

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
