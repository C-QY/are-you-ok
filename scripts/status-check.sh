#!/usr/bin/env bash
# status-check.sh — Layer 3 data collector for the are-you-ok skill (Mac/Linux)
# Outputs workspace + project metadata only. Memory content is read by the agent.

cwd="$(pwd)"
echo "cwd:$cwd"

# PROJECT TYPE & NAME
project_type="unknown"
project_name="$(basename "$cwd")"

if [ -f "$cwd/package.json" ]; then
  project_type="Node.js"
  pkg_name=$(grep -m1 '"name"' "$cwd/package.json" 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -n "$pkg_name" ] && project_name="$pkg_name"
elif [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ]; then
  project_type="Python"
elif [ -f "$cwd/go.mod" ]; then
  project_type="Go"
elif [ -f "$cwd/Cargo.toml" ]; then
  project_type="Rust"
elif [ -f "$cwd/pom.xml" ]; then
  project_type="Java"
elif ls "$cwd"/*.csproj "$cwd"/*.sln 2>/dev/null | grep -q .; then
  project_type=".NET"
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

  # Last 3 commits
  git log --format="%h %s" -3 2>/dev/null | while IFS= read -r line; do
    echo "git_log:$line"
  done

  # Changed files
  {
    git diff --name-only 2>/dev/null
    git diff --cached --name-only 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u | head -10 | while IFS= read -r f; do
    echo "changed_file:$f"
  done
else
  echo "git_branch:none"
  echo "git_tag:none"
fi

# CLAUDE.md — first meaningful line (non-empty, non-heading)
if [ -f "$cwd/CLAUDE.md" ]; then
  brief=$(grep -v '^#' "$cwd/CLAUDE.md" | grep -v '^[[:space:]]*$' | head -1 | sed 's/^[[:space:]]*//')
  [ -n "$brief" ] && echo "claude_brief:$brief"
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
