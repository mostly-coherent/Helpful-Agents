#!/usr/bin/env bash
# Install skills, agents, commands, and rules from Helpful Agents.
# Run from repo root after cloning. Idempotent — safe to re-run.
#
# SCOPE MODEL (mirrors both Claude Code and Cursor):
#
#   User-level   (all workspaces)   ~/.claude/  and  ~/.cursor/
#   Workspace    (this workspace)   parent/.claude/  and  parent/.cursor/
#
# INSTALLATION PREFERENCE: User-level by default
#   - Skills, agents, commands, rules → user-level (available in ALL workspaces)
#   - Workspace templates (workspace/) → optional; only for skills needing per-workspace
#     customization (paths, accounts). Skipped if already exists.
#   - Rules: user-level ONLY — never copied to workspace
#
# FLAGS:
#   --no-pull    Skip git pull (offline or manual workflows)
#   --dogfood    Full maintainer loop: sync workspace → repo → pull → install
#   --dry-run    Show what would change without installing
#
# Works for both:
#   - Standalone clone: git clone ... && cd Helpful_Agents && ./install.sh
#   - Subfolder clone:  cd "Helpful Agents" && ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Parse flags ───────────────────────────────────────────────────────────────
FLAG_NO_PULL=false
FLAG_DOGFOOD=false
FLAG_DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --no-pull)  FLAG_NO_PULL=true ;;
    --dogfood)  FLAG_DOGFOOD=true ;;
    --dry-run)  FLAG_DRY_RUN=true ;;
    --help|-h)
      echo "Usage: ./install.sh [--no-pull] [--dogfood] [--dry-run]"
      echo ""
      echo "  (default)    Pull latest, install, show what changed"
      echo "  --no-pull    Skip git pull (offline or manual workflows)"
      echo "  --dogfood    Maintainer loop: sync workspace → repo → pull → install"
      echo "  --dry-run    Show what would change without installing"
      exit 0
      ;;
  esac
done

# ── Target directories ──────────────────────────────────────────────────────
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
WORKSPACE_CLAUDE="$(dirname "$SCRIPT_DIR")/.claude"
WORKSPACE_CURSOR="$(dirname "$SCRIPT_DIR")/.cursor"

# ── Change tracking ──────────────────────────────────────────────────────────
CHANGES_NEW=()
CHANGES_UPDATED=()
CHANGES_UNCHANGED=()

# Compare a source file against an installed file. Records the result.
# Usage: track_change <label> <source> <installed>
track_change() {
  local label="$1" src="$2" dst="$3"
  if [ ! -e "$dst" ]; then
    CHANGES_NEW+=("$label")
  elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    CHANGES_UPDATED+=("$label")
  else
    CHANGES_UNCHANGED+=("$label")
  fi
}

# Compare a source directory against an installed directory (recursive content).
# Usage: track_change_dir <label> <source_dir> <installed_dir>
track_change_dir() {
  local label="$1" src="$2" dst="$3"
  if [ ! -d "$dst" ]; then
    CHANGES_NEW+=("$label")
  elif ! diff -rq "$src" "$dst" > /dev/null 2>&1; then
    CHANGES_UPDATED+=("$label")
  else
    CHANGES_UNCHANGED+=("$label")
  fi
}

# ── Ensure target directories exist ────────────────────────────────────────
mkdir -p "$CLAUDE_HOME/skills" "$CLAUDE_HOME/commands" "$CLAUDE_HOME/agents" "$CLAUDE_HOME/rules"
mkdir -p "$CURSOR_HOME/skills" "$CURSOR_HOME/commands" "$CURSOR_HOME/agents" "$CURSOR_HOME/rules"
mkdir -p "$WORKSPACE_CLAUDE/skills" "$WORKSPACE_CLAUDE/commands" "$WORKSPACE_CLAUDE/rules"
mkdir -p "$WORKSPACE_CURSOR/skills" "$WORKSPACE_CURSOR/commands" "$WORKSPACE_CURSOR/rules"

# ── DOGFOOD: Sync workspace → repo ──────────────────────────────────────────

if [ "$FLAG_DOGFOOD" = true ]; then
  echo "🐕 Dogfood mode: syncing workspace → Helpful Agents repo"
  echo ""

  WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

  # Private (personal info or preferences — never publish)
  # Source of truth for these: MyPrivatePrompts/skills/
  # Private primitives — never sync into Helpful Agents repo.
  # These contain personal info, personal preferences, or are
  # JM's competitive differentiators. Managed via MyPrivatePrompts.
  SKILL_EXCLUDES=(
    --exclude='my-git-sync/'
    --exclude='my-authenticity/'
    --exclude='my-create-project/'
    --exclude='update-helpful-agents/'
    # Filesystem noise
    --exclude='.DS_Store'
    --exclude='__pycache__/'
  )

  RULE_EXCLUDES=(
    --exclude='my-authenticity.md'
    --exclude='my-authenticity.mdc'
    --exclude='cursor-specifics.mdc'
    --exclude='jm-preferences.mdc'
    # Filesystem noise
    --exclude='.DS_Store'
  )

  # Phase 1: Sync Cursor workspace → Helpful Agents/.cursor/
  if [ -d "$WORKSPACE_ROOT/.cursor/skills" ]; then
    echo "  .cursor/skills/ → repo"
    rsync -avL "${SKILL_EXCLUDES[@]}" \
      "$WORKSPACE_ROOT/.cursor/skills/" \
      "$SCRIPT_DIR/.cursor/skills/" 2>/dev/null | grep -c "^" | xargs -I{} echo "    {} items checked"
  fi

  if [ -d "$WORKSPACE_ROOT/.cursor/commands" ]; then
    echo "  .cursor/commands/ → repo"
    rsync -av --exclude='.DS_Store' \
      "$WORKSPACE_ROOT/.cursor/commands/" \
      "$SCRIPT_DIR/.cursor/commands/" 2>/dev/null || true
  fi

  if [ -d "$WORKSPACE_ROOT/.cursor/agents" ]; then
    echo "  .cursor/agents/ → repo"
    rsync -av --exclude='.DS_Store' \
      "$WORKSPACE_ROOT/.cursor/agents/" \
      "$SCRIPT_DIR/.cursor/agents/" 2>/dev/null || true
  fi

  if [ -d "$WORKSPACE_ROOT/.cursor/rules" ]; then
    echo "  .cursor/rules/ → repo"
    rsync -av "${RULE_EXCLUDES[@]}" \
      "$WORKSPACE_ROOT/.cursor/rules/" \
      "$SCRIPT_DIR/.cursor/rules/" 2>/dev/null || true
  fi

  # Phase 2: Sync Claude Code workspace → Helpful Agents/.claude/
  if [ -d "$WORKSPACE_ROOT/.claude/skills" ]; then
    echo "  .claude/skills/ → repo"
    rsync -avL "${SKILL_EXCLUDES[@]}" \
      "$WORKSPACE_ROOT/.claude/skills/" \
      "$SCRIPT_DIR/.claude/skills/" 2>/dev/null | grep -c "^" | xargs -I{} echo "    {} items checked"
  fi

  if [ -d "$WORKSPACE_ROOT/.claude/commands" ]; then
    echo "  .claude/commands/ → repo"
    rsync -av --exclude='.DS_Store' \
      "$WORKSPACE_ROOT/.claude/commands/" \
      "$SCRIPT_DIR/.claude/commands/" 2>/dev/null || true
  fi

  if [ -d "$WORKSPACE_ROOT/.claude/agents" ]; then
    echo "  .claude/agents/ → repo"
    rsync -av --exclude='.DS_Store' \
      "$WORKSPACE_ROOT/.claude/agents/" \
      "$SCRIPT_DIR/.claude/agents/" 2>/dev/null || true
  fi

  if [ -d "$WORKSPACE_ROOT/.claude/rules" ]; then
    echo "  .claude/rules/ → repo"
    rsync -av "${RULE_EXCLUDES[@]}" \
      "$WORKSPACE_ROOT/.claude/rules/" \
      "$SCRIPT_DIR/.claude/rules/" 2>/dev/null || true
  fi

  # Phase 3: Merge user-level items not in workspace (fills gaps from other workspaces)
  echo "  Merging user-level items (--ignore-existing)..."

  [ -d "$CURSOR_HOME/skills" ] && rsync -avL --ignore-existing \
    "${SKILL_EXCLUDES[@]}" \
    "$CURSOR_HOME/skills/" "$SCRIPT_DIR/.cursor/skills/" 2>/dev/null || true

  [ -d "$CURSOR_HOME/commands" ] && rsync -av --ignore-existing \
    --exclude='.DS_Store' "$CURSOR_HOME/commands/" "$SCRIPT_DIR/.cursor/commands/" 2>/dev/null || true

  [ -d "$CURSOR_HOME/agents" ] && rsync -av --ignore-existing \
    --exclude='.DS_Store' "$CURSOR_HOME/agents/" "$SCRIPT_DIR/.cursor/agents/" 2>/dev/null || true

  [ -d "$CURSOR_HOME/rules" ] && rsync -av --ignore-existing \
    "${RULE_EXCLUDES[@]}" "$CURSOR_HOME/rules/" "$SCRIPT_DIR/.cursor/rules/" 2>/dev/null || true

  [ -d "$CLAUDE_HOME/skills" ] && rsync -avL --ignore-existing \
    "${SKILL_EXCLUDES[@]}" \
    "$CLAUDE_HOME/skills/" "$SCRIPT_DIR/.claude/skills/" 2>/dev/null || true

  [ -d "$CLAUDE_HOME/commands" ] && rsync -av --ignore-existing \
    --exclude='.DS_Store' "$CLAUDE_HOME/commands/" "$SCRIPT_DIR/.claude/commands/" 2>/dev/null || true

  [ -d "$CLAUDE_HOME/agents" ] && rsync -av --ignore-existing \
    --exclude='.DS_Store' "$CLAUDE_HOME/agents/" "$SCRIPT_DIR/.claude/agents/" 2>/dev/null || true

  [ -d "$CLAUDE_HOME/rules" ] && rsync -av --ignore-existing \
    "${RULE_EXCLUDES[@]}" "$CLAUDE_HOME/rules/" "$SCRIPT_DIR/.claude/rules/" 2>/dev/null || true

  echo ""
  echo "  Dogfood sync complete. Repo updated from workspace + user-level."
  echo ""
fi

# ── AUTO-PULL ────────────────────────────────────────────────────────────────

if [ "$FLAG_NO_PULL" = false ] && [ -d "$SCRIPT_DIR/.git" ]; then
  echo "🔄 Pulling latest from remote..."
  cd "$SCRIPT_DIR"
  if git pull --ff-only 2>/dev/null; then
    echo "   Up to date."
  else
    echo "   ⚠️  Pull failed (merge conflict or no remote). Continuing with local copy."
  fi
  echo ""
fi

# ── DRY-RUN gate ─────────────────────────────────────────────────────────────

if [ "$FLAG_DRY_RUN" = true ]; then
  echo "🔍 Dry run — comparing repo against installed files (no changes will be made)"
  echo ""
fi

# ── Install header ───────────────────────────────────────────────────────────

echo "Installing from Helpful Agents..."
echo "  Claude Code → $CLAUDE_HOME"
echo "  Cursor      → $CURSOR_HOME"
echo ""

# ── USER-LEVEL SKILLS ───────────────────────────────────────────────────────
# `.cursor/skills/` and `.claude/skills/` are installed separately; folder counts
# should match — if they diverge, fix the repo. Removing a skill from the repo
# removes it on the next install when the script replaces each skill dir.

echo "📦 User-level skills"

if [ -d "$SCRIPT_DIR/.claude/skills" ]; then
  echo "  Claude Code → $CLAUDE_HOME/skills/"
  for skill in "$SCRIPT_DIR"/.claude/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ -f "$skill/SKILL.md" ] || continue
    track_change_dir "skill:claude:$name" "$skill" "$CLAUDE_HOME/skills/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      rm -rf "$CLAUDE_HOME/skills/$name"
      mkdir -p "$CLAUDE_HOME/skills/$name"
      cp -R "$skill"/* "$CLAUDE_HOME/skills/$name/"
    fi
    echo "    ✓ $name"
  done
fi

if [ -d "$SCRIPT_DIR/.cursor/skills" ]; then
  echo "  Cursor      → $CURSOR_HOME/skills/"
  for skill in "$SCRIPT_DIR"/.cursor/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ -f "$skill/SKILL.md" ] || continue
    track_change_dir "skill:cursor:$name" "$skill" "$CURSOR_HOME/skills/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      rm -rf "$CURSOR_HOME/skills/$name"
      mkdir -p "$CURSOR_HOME/skills/$name"
      cp -R "$skill"/* "$CURSOR_HOME/skills/$name/"
    fi
    echo "    ✓ $name"
  done
fi

# ── USER-LEVEL AGENTS ───────────────────────────────────────────────────────

echo ""
echo "📦 User-level agents"

if [ -d "$SCRIPT_DIR/.claude/agents" ]; then
  echo "  Claude Code → $CLAUDE_HOME/agents/"
  for agent in "$SCRIPT_DIR"/.claude/agents/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    track_change "agent:claude:$name" "$agent" "$CLAUDE_HOME/agents/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$agent" "$CLAUDE_HOME/agents/"
    fi
    echo "    ✓ $name"
  done
else
  echo "  (no Claude Code agents)"
fi

if [ -d "$SCRIPT_DIR/.cursor/agents" ]; then
  echo "  Cursor      → $CURSOR_HOME/agents/"
  for agent in "$SCRIPT_DIR"/.cursor/agents/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    track_change "agent:cursor:$name" "$agent" "$CURSOR_HOME/agents/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$agent" "$CURSOR_HOME/agents/"
    fi
    echo "    ✓ $name"
  done
else
  echo "  (no Cursor agents)"
fi

# ── USER-LEVEL COMMANDS ─────────────────────────────────────────────────────

echo ""
echo "📦 User-level commands"

if [ -d "$SCRIPT_DIR/.claude/commands" ]; then
  echo "  Claude Code → $CLAUDE_HOME/commands/"
  for cmd in "$SCRIPT_DIR"/.claude/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")
    track_change "command:claude:$name" "$cmd" "$CLAUDE_HOME/commands/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$cmd" "$CLAUDE_HOME/commands/"
    fi
    echo "    ✓ $name"
  done
fi

if [ -d "$SCRIPT_DIR/.cursor/commands" ]; then
  echo "  Cursor      → $CURSOR_HOME/commands/"
  for cmd in "$SCRIPT_DIR"/.cursor/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")
    track_change "command:cursor:$name" "$cmd" "$CURSOR_HOME/commands/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$cmd" "$CURSOR_HOME/commands/"
    fi
    echo "    ✓ $name"
  done
fi

# ── USER-LEVEL RULES ────────────────────────────────────────────────────────

echo ""
echo "📦 User-level rules"

# Claude Code: .md files only
if [ -d "$SCRIPT_DIR/.claude/rules" ]; then
  echo "  Claude Code → $CLAUDE_HOME/rules/  (.md)"
  for rule in "$SCRIPT_DIR"/.claude/rules/*.md; do
    [ -f "$rule" ] || continue
    name=$(basename "$rule")
    track_change "rule:claude:$name" "$rule" "$CLAUDE_HOME/rules/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$rule" "$CLAUDE_HOME/rules/"
    fi
    echo "    ✓ $name"
  done
fi

# Cursor: .mdc files (Cursor dialect), fall back to .md if no .mdc exists
if [ -d "$SCRIPT_DIR/.cursor/rules" ]; then
  echo "  Cursor      → $CURSOR_HOME/rules/  (.mdc)"
  for rule in "$SCRIPT_DIR"/.cursor/rules/*.mdc "$SCRIPT_DIR"/.cursor/rules/*.md; do
    [ -f "$rule" ] || continue
    name=$(basename "$rule")
    track_change "rule:cursor:$name" "$rule" "$CURSOR_HOME/rules/$name"
    if [ "$FLAG_DRY_RUN" = false ]; then
      cp "$rule" "$CURSOR_HOME/rules/"
    fi
    echo "    ✓ $name"
  done
fi

# Rules: user-level ONLY — never copied to workspace

# ── WORKSPACE-LEVEL SKILLS (skip if already exists) ────────────────────────
# Never ship these to the parent workspace (removed from repo / personal-lab default).
WORKSPACE_SKILL_SKIP=(slack-triage)

echo ""
echo "📦 Workspace skills (skip if exists)"

workspace_skill_skipped() {
  local n="$1"
  local s
  for s in "${WORKSPACE_SKILL_SKIP[@]}"; do
    [ "$n" = "$s" ] && return 0
  done
  return 1
}

if [ -d "$SCRIPT_DIR/workspace/skills" ]; then
  echo "  Claude Code → $WORKSPACE_CLAUDE/skills/"
  for skill in "$SCRIPT_DIR"/workspace/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    workspace_skill_skipped "$name" && continue
    [ -f "$skill/SKILL.md" ] || continue
    if [ -e "$WORKSPACE_CLAUDE/skills/$name" ]; then
      echo "    ⏭ $name (exists)"
    else
      CHANGES_NEW+=("workspace:claude:$name")
      if [ "$FLAG_DRY_RUN" = false ]; then
        mkdir -p "$WORKSPACE_CLAUDE/skills/$name"
        cp -R "$skill"/* "$WORKSPACE_CLAUDE/skills/$name/"
      fi
      echo "    ✓ $name"
    fi
  done

  echo "  Cursor      → $WORKSPACE_CURSOR/skills/"
  for skill in "$SCRIPT_DIR"/workspace/skills/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    workspace_skill_skipped "$name" && continue
    [ -f "$skill/SKILL.md" ] || continue
    if [ -e "$WORKSPACE_CURSOR/skills/$name" ]; then
      echo "    ⏭ $name (exists)"
    else
      CHANGES_NEW+=("workspace:cursor:$name")
      if [ "$FLAG_DRY_RUN" = false ]; then
        mkdir -p "$WORKSPACE_CURSOR/skills/$name"
        cp -R "$skill"/* "$WORKSPACE_CURSOR/skills/$name/"
      fi
      echo "    ✓ $name"
    fi
  done
else
  echo "  (no workspace skills)"
fi

# ── WORKSPACE-LEVEL COMMANDS (skip if already exists) ──────────────────────

echo ""
echo "📦 Workspace commands (skip if exists)"

if [ -d "$SCRIPT_DIR/workspace/commands" ]; then
  count=0
  for cmd in "$SCRIPT_DIR"/workspace/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd")

    if [ -f "$WORKSPACE_CLAUDE/commands/$name" ]; then
      echo "    ⏭ $name → Claude Code (exists)"
    else
      CHANGES_NEW+=("workspace:claude:cmd:$name")
      if [ "$FLAG_DRY_RUN" = false ]; then
        cp "$cmd" "$WORKSPACE_CLAUDE/commands/"
      fi
      echo "    ✓ $name → Claude Code"
    fi

    if [ -f "$WORKSPACE_CURSOR/commands/$name" ]; then
      echo "    ⏭ $name → Cursor (exists)"
    else
      CHANGES_NEW+=("workspace:cursor:cmd:$name")
      if [ "$FLAG_DRY_RUN" = false ]; then
        cp "$cmd" "$WORKSPACE_CURSOR/commands/"
      fi
      echo "    ✓ $name → Cursor"
    fi
    count=$((count + 1))
  done
  [ "$count" -eq 0 ] && echo "  (no workspace commands)"
else
  echo "  (no workspace commands)"
fi

# ── CHANGE REPORT ────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FLAG_DRY_RUN" = true ]; then
  echo "📋 Dry run report (no changes made)"
else
  echo "📋 What changed"
fi

echo ""

new_count=${#CHANGES_NEW[@]}
updated_count=${#CHANGES_UPDATED[@]}
unchanged_count=${#CHANGES_UNCHANGED[@]}

if [ "$new_count" -gt 0 ]; then
  echo "  + NEW ($new_count):"
  for item in "${CHANGES_NEW[@]}"; do
    echo "    + $item"
  done
  echo ""
fi

if [ "$updated_count" -gt 0 ]; then
  echo "  ~ UPDATED ($updated_count):"
  for item in "${CHANGES_UPDATED[@]}"; do
    echo "    ~ $item"
  done
  echo ""
fi

if [ "$new_count" -eq 0 ] && [ "$updated_count" -eq 0 ]; then
  echo "  = All $unchanged_count items unchanged. Already up to date."
  echo ""
fi

echo "  Total: $new_count new, $updated_count updated, $unchanged_count unchanged"

# ── SUMMARY ──────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done!"
echo ""
echo "  User-level  Claude Code → $CLAUDE_HOME"
echo "  User-level  Cursor      → $CURSOR_HOME"
echo "  Workspace   Claude Code → $WORKSPACE_CLAUDE"
echo "  Workspace   Cursor      → $WORKSPACE_CURSOR"
echo ""
echo "  Rules and commands: user-level only."
echo "  Workspace templates: skipped if already customized."

if [ "$FLAG_DOGFOOD" = true ]; then
  echo ""
  echo "  🐕 Dogfood: workspace → repo sync completed."
  echo "  Next: cd \"$(basename "$SCRIPT_DIR")\" && git add -A && git status"
fi
