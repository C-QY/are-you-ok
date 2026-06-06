#!/usr/bin/env bash
# status-check.sh - Layer 3 data collector for the are-you-ok skill (Mac/Linux)
# Usage: status-check.sh [--easter-egg] [--audio-only --audio-clip <name>] [--network-check]

# NETWORK CHECK - quick DNS probe, runs before data collection
for arg in "$@"; do
  if [ "$arg" = "--network-check" ]; then
    if nslookup api.anthropic.com > /dev/null 2>&1; then
      echo "network_status:ok"
    else
      echo "network_status:fail"
    fi
    break
  fi
done

# AUDIO - determine clip and play
clip_to_play=""
audio_only=false
i=1
while [ $i -le $# ]; do
  arg="${!i}"
  if [ "$arg" = "--easter-egg" ]; then clip_to_play="are-you-ok"
  elif [ "$arg" = "--audio-only" ]; then audio_only=true
  elif [ "$arg" = "--audio-clip" ]; then i=$((i+1)); clip_to_play="${!i}"
  fi
  i=$((i+1))
done

if [ -n "$clip_to_play" ]; then
  assets="$(dirname "$0")/../assets"
  mp3="$assets/eleijun-$clip_to_play.mp3"
  wav="$assets/eleijun-$clip_to_play.wav"
  played=false
  if [ -f "$assets/.no-audio" ]; then
    : # audio disabled by user
  elif [ -f "$mp3" ]; then
    if command -v afplay &>/dev/null;   then afplay "$mp3" & played=true
    elif command -v mpg123 &>/dev/null; then mpg123 -q "$mp3" & played=true
    elif command -v ffplay &>/dev/null; then ffplay -nodisp -autoexit -loglevel quiet "$mp3" & played=true
    fi
  elif [ -f "$wav" ]; then
    if command -v afplay &>/dev/null;   then afplay "$wav" & played=true
    elif command -v aplay &>/dev/null;  then aplay -q "$wav" & played=true
    fi
  fi
  if [ "$played" = true ]; then
    echo "easter_egg:playing"
  else
    echo "easter_egg:missing"
  fi
fi

# CITY DETECTION - IP lookup for easter egg attribution; default Shanghai on failure
city="Shanghai"
if command -v curl &>/dev/null; then
  city_resp=$(curl -s --max-time 3 "http://ip-api.com/json/?fields=city" 2>/dev/null)
  city_val=$(echo "$city_resp" | grep -o '"city":"[^"]*"' | sed 's/"city":"//;s/"//')
  [ -n "$city_val" ] && city="$city_val"
fi
echo "city:$city"

# AUDIO ONLY - pure easter egg triggers: return timestamp + clip name, skip data collection
if [ "$audio_only" = true ]; then
  echo "timestamp:$(date '+%Y-%m-%d %H:%M')"
  echo "audio_clip:$clip_to_play"
  exit 0
fi

echo "timestamp:$(date '+%Y-%m-%d %H:%M')"

cwd="$(pwd)"
echo "cwd:$cwd"

# PROJECT TYPE & NAME
project_type="unknown"
project_name="$(basename "$cwd")"

if [ -f "$cwd/package.json" ]; then
  project_type="Node.js"
  pkg_name=$(grep -m1 '"name"' "$cwd/package.json" 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -n "$pkg_name" ] && project_name="$pkg_name"
elif [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ]; then project_type="Python"
elif [ -f "$cwd/go.mod" ];    then project_type="Go"
elif [ -f "$cwd/Cargo.toml" ]; then project_type="Rust"
elif [ -f "$cwd/pom.xml" ];   then project_type="Java"
elif ls "$cwd"/*.csproj "$cwd"/*.sln 2>/dev/null | grep -q .; then project_type=".NET"
fi

echo "project_name:$project_name"
echo "project_type:$project_type"

# GIT
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  count=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

  echo "git_branch:$branch"
  echo "git_uncommitted:$count"
  echo "git_tag:$tag"

  git log --format="%h %s" -3 2>/dev/null | while IFS= read -r line; do
    echo "git_log:$line"
  done

  { git diff --name-only 2>/dev/null
    git diff --cached --name-only 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u | head -10 | while IFS= read -r f; do
    echo "changed_file:$f"
  done
else
  echo "git_branch:none"
  echo "git_tag:none"
fi

# CLAUDE.md - first meaningful line
if [ -f "$cwd/CLAUDE.md" ]; then
  brief=$(grep -v '^#' "$cwd/CLAUDE.md" | grep -v '^[[:space:]]*$' | head -1 | sed 's/^[[:space:]]*//')
  [ -n "$brief" ] && echo "claude_brief:$brief"
fi

# MEMORY - count only; omit entirely when not found (agent skips the memory line)
if [ -d "$HOME/.claude" ]; then
  mem_file=$(find "$HOME/.claude" -maxdepth 6 -name "MEMORY.md" 2>/dev/null | head -1)
  if [ -n "$mem_file" ]; then
    count=$(grep -c "^- \[" "$mem_file" 2>/dev/null || echo 0)
    echo "memory_path:$mem_file"
    echo "memory_count:$count"
  fi
fi

exit 0
