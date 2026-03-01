#!/usr/bin/env bash
# Install Cursor skills and commands from Helpful Agents.
# Run from repo root after cloning.
# Idempotent — safe to re-run.
#
# Two installation targets:
#   User-level   (.cursor/skills + commands + agents + rules) → ~/.cursor/  (all workspaces)
#   Workspace    (workspace/skills + commands + rules + agents) → ./.cursor/  (current workspace only, skip if exists)
#   Workspace    (workspace/templates/FOCUS.md) → workspace root (skip if exists)
#
# PRIVATE EXCLUSION: This repo contains only public-safe configs. Private skills/rules/commands
# (PII, workspace paths, personal accounts) are never synced here. Maintainer uses sync-helpful-agents-cursor
# with explicit exclusions before pushing.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
WORKSPACE_CURSOR="$WORKSPACE_ROOT/.cursor"

mkdir -p "$CURSOR_HOME/skills" "$CURSOR_HOME/commands" "$CURSOR_HOME/agents" "$CURSOR_HOME/rules"
mkdir -p "$WORKSPACE_CURSOR/skills" "$WORKSPACE_CURSOR/commands" "$WORKSPACE_CURSOR/rules" "$WORKSPACE_CURSOR/agents"

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

# ── User-level rules ───────────────────────────────────────
echo ""
echo "📦 User-level rules → $CURSOR_HOME/rules/"
if [ -d "$SCRIPT_DIR/.cursor/rules" ]; then
  for rule in "$SCRIPT_DIR"/.cursor/rules/*.mdc; do
    [ -f "$rule" ] || continue
    name=$(basename "$rule")
    cp "$rule" "$CURSOR_HOME/rules/"
    echo "  ✓ $name"
  done
else
  echo "  (no user-level rules to install)"
fi

# ── User-level agents ──────────────────────────────────────
echo ""
echo "📦 User-level agents → $CURSOR_HOME/agents/"
if [ -d "$SCRIPT_DIR/.cursor/agents" ]; then
  for agent in "$SCRIPT_DIR"/.cursor/agents/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    cp "$agent" "$CURSOR_HOME/agents/"
    echo "  ✓ $name"
  done
else
  echo "  (no agents to install)"
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

# ── Workspace-level rules (skip if already exists) ────────
echo ""
echo "📦 Workspace rules → $WORKSPACE_CURSOR/rules/"
if [ -d "$SCRIPT_DIR/workspace/rules" ]; then
  for rule in "$SCRIPT_DIR"/workspace/rules/*.mdc; do
    [ -f "$rule" ] || continue
    name=$(basename "$rule")
    if [ -f "$WORKSPACE_CURSOR/rules/$name" ]; then
      echo "  ⏭ $name (already exists, skipping)"
    else
      cp "$rule" "$WORKSPACE_CURSOR/rules/"
      echo "  ✓ $name"
    fi
  done
else
  echo "  (no workspace rules to install)"
fi

# ── Workspace-level agents (skip if already exists) ───────
echo ""
echo "📦 Workspace agents → $WORKSPACE_CURSOR/agents/"
if [ -d "$SCRIPT_DIR/workspace/agents" ]; then
  for agent in "$SCRIPT_DIR"/workspace/agents/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    if [ -f "$WORKSPACE_CURSOR/agents/$name" ]; then
      echo "  ⏭ $name (already exists, skipping)"
    else
      cp "$agent" "$WORKSPACE_CURSOR/agents/"
      echo "  ✓ $name"
    fi
  done
else
  echo "  (no workspace agents to install)"
fi

# ── Workspace templates (FOCUS.md to workspace root) ───────
echo ""
echo "📦 Workspace templates → $WORKSPACE_ROOT/"
if [ -f "$SCRIPT_DIR/workspace/templates/FOCUS.md" ]; then
  if [ -f "$WORKSPACE_ROOT/FOCUS.md" ]; then
    echo "  ⏭ FOCUS.md (already exists, skipping)"
  else
    cp "$SCRIPT_DIR/workspace/templates/FOCUS.md" "$WORKSPACE_ROOT/"
    echo "  ✓ FOCUS.md"
  fi
fi

echo ""
echo "Done!"
echo "  User-level  → $CURSOR_HOME  (available in all workspaces)"
echo "  Workspace   → $WORKSPACE_CURSOR  (this workspace only)"
