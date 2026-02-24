#!/usr/bin/env bash
# Install Cursor skills and commands from Helpful Agents.
# Run from repo root after cloning.
# Idempotent — safe to re-run.
#
# Two installation targets:
#   User-level   (.cursor/skills + commands)   → ~/.cursor/  (all workspaces)
#   Workspace    (workspace/skills + commands)  → ./.cursor/  (current workspace only, skip if exists)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
WORKSPACE_CURSOR="$(dirname "$SCRIPT_DIR")/.cursor"

mkdir -p "$CURSOR_HOME/skills" "$CURSOR_HOME/commands"
mkdir -p "$WORKSPACE_CURSOR/skills" "$WORKSPACE_CURSOR/commands"

echo "Installing Cursor configs from Helpful Agents..."
echo ""

# ── User-level skills ──────────────────────────────────────
echo "📦 User-level skills → $CURSOR_HOME/skills/"
if [ -d "$SCRIPT_DIR/.cursor/skills" ]; then
  for skill in "$SCRIPT_DIR"/.cursor/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ -f "$skill/SKILL.md" ] || continue
    rm -rf "$CURSOR_HOME/skills/$name"
    mkdir -p "$CURSOR_HOME/skills/$name"
    cp -R "$skill"/* "$CURSOR_HOME/skills/$name/"
    echo "  ✓ $name"
  done
fi

# ── User-level commands ────────────────────────────────────
echo ""
echo "📦 User-level commands → $CURSOR_HOME/commands/"
if [ -d "$SCRIPT_DIR/.cursor/commands" ]; then
  for cmd in "$SCRIPT_DIR"/.cursor/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")
    cp "$cmd" "$CURSOR_HOME/commands/"
    echo "  ✓ $name"
  done
fi

# ── Workspace-level skills (skip if already exists) ────────
echo ""
echo "📦 Workspace skills → $WORKSPACE_CURSOR/skills/"
if [ -d "$SCRIPT_DIR/workspace/skills" ]; then
  for skill in "$SCRIPT_DIR"/workspace/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ -f "$skill/SKILL.md" ] || continue
    if [ -e "$WORKSPACE_CURSOR/skills/$name" ]; then
      echo "  ⏭ $name (already exists, skipping)"
    else
      mkdir -p "$WORKSPACE_CURSOR/skills/$name"
      cp -R "$skill"/* "$WORKSPACE_CURSOR/skills/$name/"
      echo "  ✓ $name"
    fi
  done
else
  echo "  (no workspace skills to install)"
fi

# ── Workspace-level commands (skip if already exists) ──────
echo ""
echo "📦 Workspace commands → $WORKSPACE_CURSOR/commands/"
if [ -d "$SCRIPT_DIR/workspace/commands" ]; then
  count=0
  for cmd in "$SCRIPT_DIR"/workspace/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")
    if [ -f "$WORKSPACE_CURSOR/commands/$name" ]; then
      echo "  ⏭ $name (already exists, skipping)"
    else
      cp "$cmd" "$WORKSPACE_CURSOR/commands/"
      echo "  ✓ $name"
    fi
    count=$((count + 1))
  done
  [ "$count" -eq 0 ] && echo "  (no workspace commands to install)"
else
  echo "  (no workspace commands to install)"
fi

echo ""
echo "Done!"
echo "  User-level  → $CURSOR_HOME  (available in all workspaces)"
echo "  Workspace   → $WORKSPACE_CURSOR  (this workspace only)"
