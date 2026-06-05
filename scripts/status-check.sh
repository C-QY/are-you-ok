#!/usr/bin/env bash
# status-check.sh - Layer 3 data collector for the are-you-ok skill (Mac/Linux)
# Usage: status-check.sh [--ok-audio] [--network-check]

# NETWORK CHECK - quick DNS probe, runs before data collection
if [ "$1" = "--network-check" ] || [ "$2" = "--network-check" ]; then
  if nslookup api.anthropic.com >/dev/null 2>&1; then
    echo "network_status:ok"
  else
    echo "network_status:fail"
  fi
fi

# OK AUDIO - play audio first so it starts while data is collected
if [ "$1" = "--ok-audio" ] || [ "$2" = "--ok-audio" ]; then
  _no_audio="$(dirname "$0")/../.no-audio"
  if [ -f "$_no_audio" ]; then
    : # silently skip
  else
    mp3="$(dirname "$0")/../assets/eleijun-are-you-ok.mp3"
    _played=false
    if [ -f "$mp3" ]; then
      if command -v afplay >/dev/null 2>&1;   then afplay "$mp3" & _played=true
      elif command -v mpg123 >/dev/null 2>&1; then mpg123 -q "$mp3" & _played=true
      elif command -v ffplay >/dev/null 2>&1; then ffplay -nodisp -autoexit -loglevel quiet "$mp3" & _played=true
      fi
    fi
    if [ "$_played" = true ]; then
      echo "ok_audio:playing"
    else
      echo "ok_audio:not_found"
    fi
  fi
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
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
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
