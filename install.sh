#!/usr/bin/env bash
# are-you-ok skill installer for Mac / Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/C-QY/are-you-ok/master/install.sh | bash

set -e

REPO="https://github.com/C-QY/are-you-ok"
DEST="$HOME/.claude/skills/are-you-ok"
TMP="$(mktemp -d)/are-you-ok"

git clone "$REPO" "$TMP"

rm -rf "$DEST"
cp -r "$TMP" "$DEST"
chmod +x "$DEST/scripts/status-check.sh"
rm -rf "$(dirname "$TMP")"

echo ""
echo "  are-you-ok installed."
echo "  Restart Claude Code, then say 'are you ok'."
echo ""
