#!/usr/bin/env bash
# Install Cursor skills and commands to ~/.cursor/
# Run from Helpful Agents repo root after clone.
# Idempotent — safe to re-run.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"

mkdir -p "$CURSOR_HOME/skills"
mkdir -p "$CURSOR_HOME/commands"

echo "Installing Cursor configs to $CURSOR_HOME..."

if [ -d "$SCRIPT_DIR/.cursor/skills" ]; then
  for skill in "$SCRIPT_DIR"/.cursor/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    rm -rf "$CURSOR_HOME/skills/$name"
    cp -R "$skill" "$CURSOR_HOME/skills/"
    echo "  ✓ $name"
  done
fi

if [ -d "$SCRIPT_DIR/.cursor/commands" ]; then
  for cmd in "$SCRIPT_DIR"/.cursor/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")
    cp "$cmd" "$CURSOR_HOME/commands/"
    echo "  ✓ $name"
  done
fi

echo "Done. Skills and commands are now in $CURSOR_HOME"
echo "They will be available in all Cursor workspaces."
