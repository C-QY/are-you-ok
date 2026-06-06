#!/usr/bin/env bash
# are-you-ok skill installer for Mac / Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash

set -e

REPO="https://github.com/C-QY/are-you-ok"
DEST="$HOME/.claude/skills/are-you-ok"
TMP="$(mktemp -d)/are-you-ok"

if [ -d "$DEST/.git" ]; then
    # Already installed — update in place
    rm -rf "$TMP"
    cd "$DEST" && git pull origin master
else
    git clone "$REPO" "$TMP"
    mkdir -p "$(dirname "$DEST")"
    cp -r "$TMP" "$DEST"
    rm -rf "$(dirname "$TMP")"
fi
chmod +x "$DEST/scripts/status-check.sh"

echo ""
echo "  are-you-ok installed."
echo "  Restart Claude Code, then say 'are you ok'."
echo ""
