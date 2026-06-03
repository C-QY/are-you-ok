#!/usr/bin/env bash
# status-check.sh — Layer 3 data collector for the are-you-ok skill (Mac/Linux)
# Outputs workspace metadata only. Memory content is read by the agent, not this script.
# Output format is identical to status-check.ps1 for unified agent-side parsing.

# CWD
echo "cwd:$(pwd)"

# GIT
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  count=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  last=$(git log --format="%s" -1 2>/dev/null)
  echo "git_branch:$branch"
  echo "git_uncommitted:$count"
  echo "git_last:$last"
  {
    git diff --name-only 2>/dev/null
    git diff --cached --name-only 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u | head -10 | while IFS= read -r f; do
    echo "changed_file:$f"
  done
else
  echo "git_branch:none"
fi

# MEMORY — count only, content is for the agent to read directly
mem_file=$(find "$HOME/.claude/projects" -maxdepth 6 -name "MEMORY.md" 2>/dev/null | head -1)
if [ -n "$mem_file" ]; then
  count=$(grep -c "^- \[" "$mem_file" 2>/dev/null || echo 0)
  echo "memory_path:$mem_file"
  echo "memory_count:$count"
else
  echo "memory_count:0"
fi
