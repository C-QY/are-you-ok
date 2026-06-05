#!/usr/bin/env bash
# are-you-ok skill installer for Mac / Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash

set -e

REPO="https://github.com/C-QY/are-you-ok"
DEST="$HOME/.claude/skills/are-you-ok"

mkdir -p "$(dirname "$DEST")"

if [ -d "$DEST/.git" ]; then
    cd "$DEST" && git pull
    echo ""
    echo "  are-you-ok updated."
else
    [ -d "$DEST" ] && rm -rf "$DEST"
    git clone "$REPO" "$DEST"
    chmod +x "$DEST/scripts/status-check.sh"
    echo ""
    echo "  are-you-ok installed."
fi

echo "  Restart Claude Code, then say 'are you ok'."
echo ""
