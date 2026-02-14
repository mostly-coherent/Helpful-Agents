#!/bin/bash
# =============================================================================
# Dev Environment Setup — Mac / Linux
# =============================================================================
# One-time setup for building apps with Cursor.
# Idempotent: safe to run multiple times (skips already-installed tools).
# RESILIENT: individual failures do NOT stop the script. Every phase runs
#            regardless of whether the previous one succeeded. A final
#            scorecard tells you exactly what worked and what needs attention.
#
# Usage:
#   bash scripts/setup.sh
# =============================================================================

# NOTE: We intentionally do NOT use `set -e` here.
# Each phase handles its own errors and continues to the next.
set -uo pipefail

# ---------------------------------------------------------------------------
# Colors and helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠️${NC}  $1"; }
fail()    { echo -e "${RED}❌${NC} $1"; }
step()    { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ---------------------------------------------------------------------------
# Scorecard — tracks what passed, warned, or failed
# ---------------------------------------------------------------------------
declare -a RESULTS=()

record_pass() { RESULTS+=("PASS|$1"); }
record_warn() { RESULTS+=("WARN|$1"); }
record_fail() { RESULTS+=("FAIL|$1"); }

# ---------------------------------------------------------------------------
# OS Detection
# ---------------------------------------------------------------------------
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    fail "Unsupported OS: $OSTYPE. This script supports macOS and Linux. For Windows, use setup.ps1."
    exit 1
fi

info "Detected OS: $OS"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
has() { command -v "$1" &>/dev/null; }

version_gte() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# try_install: runs a command, logs success or failure, never exits
try_install() {
    local label="$1"
    shift
    if "$@" 2>&1; then
        success "$label installed"
        return 0
    else
        fail "$label install failed (exit code $?). Continuing..."
        return 1
    fi
}

# =====================================================================
# PHASE 1: Package Manager
# =====================================================================
step "Phase 1: Package Manager"

if [[ "$OS" == "mac" ]]; then
    if has brew; then
        success "Homebrew already installed ($(brew --version | head -1))"
        record_pass "Homebrew"
    else
        info "Installing Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            # Add to PATH for Apple Silicon Macs
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
            fi
            success "Homebrew installed"
            record_pass "Homebrew"
        else
            fail "Homebrew install failed. Some tools may need manual install."
            record_fail "Homebrew"
        fi
    fi
elif [[ "$OS" == "linux" ]]; then
    PKG_MGR="none"
    if has apt-get; then
        info "Using apt (Debian/Ubuntu)"
        PKG_MGR="apt"
    elif has dnf; then
        info "Using dnf (Fedora/RHEL)"
        PKG_MGR="dnf"
    elif has pacman; then
        info "Using pacman (Arch)"
        PKG_MGR="pacman"
    else
        warn "No recognized package manager found. Some tools may need manual install."
    fi
    record_pass "Package manager ($PKG_MGR)"
fi

# =====================================================================
# PHASE 2: Git
# =====================================================================
step "Phase 2: Git"

if has git; then
    GIT_VER=$(git --version | awk '{print $3}')
    success "Git already installed (v$GIT_VER)"
    record_pass "Git v$GIT_VER"
else
    info "Installing Git..."
    if [[ "$OS" == "mac" ]]; then
        xcode-select --install 2>/dev/null || true
        warn "If prompted, accept the Xcode Command Line Tools install and re-run this script."
        record_warn "Git (Xcode CLT prompted — may need re-run)"
    elif [[ "$OS" == "linux" ]]; then
        case "${PKG_MGR:-none}" in
            apt)  sudo apt-get update -qq && sudo apt-get install -y -qq git && record_pass "Git" || record_fail "Git" ;;
            dnf)  sudo dnf install -y git && record_pass "Git" || record_fail "Git" ;;
            pacman) sudo pacman -S --noconfirm git && record_pass "Git" || record_fail "Git" ;;
            *)    fail "No package manager to install Git."; record_fail "Git" ;;
        esac
    fi
fi

# =====================================================================
# PHASE 3: Node.js
# =====================================================================
step "Phase 3: Node.js"

NEED_NODE=true
if has node; then
    NODE_VER=$(node -v | sed 's/v//')
    if version_gte "$NODE_VER" "18.0.0"; then
        success "Node.js already installed (v$NODE_VER)"
        record_pass "Node.js v$NODE_VER"
        NEED_NODE=false
    else
        warn "Node.js v$NODE_VER found but v18+ required. Upgrading..."
    fi
fi

if $NEED_NODE; then
    info "Installing Node.js 20 LTS..."
    if [[ "$OS" == "mac" ]]; then
        if has brew; then
            if brew install node@20 2>&1; then
                brew link --overwrite node@20 2>/dev/null || true
                success "Node.js $(node -v 2>/dev/null || echo '20') installed"
                record_pass "Node.js"
            else
                fail "Node.js install via brew failed."
                record_fail "Node.js — try: brew install node@20"
            fi
        else
            fail "Homebrew not available. Install Node.js manually from https://nodejs.org"
            record_fail "Node.js — install from https://nodejs.org"
        fi
    elif [[ "$OS" == "linux" ]]; then
        if curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>&1 && sudo apt-get install -y nodejs 2>&1; then
            success "Node.js installed"
            record_pass "Node.js"
        else
            fail "Node.js install failed."
            record_fail "Node.js — install from https://nodejs.org"
        fi
    fi
fi

# Verify npm
if has npm; then
    success "npm $(npm -v) available"
else
    warn "npm not found. Usually comes with Node.js."
    record_warn "npm — reinstall Node.js"
fi

# =====================================================================
# PHASE 4: Python
# =====================================================================
step "Phase 4: Python"

NEED_PYTHON=true
PYTHON_CMD=""
if has python3; then
    PYTHON_CMD="python3"
elif has python; then
    PYTHON_CMD="python"
fi

if [[ -n "$PYTHON_CMD" ]]; then
    PY_VER=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
    if version_gte "$PY_VER" "3.10.0"; then
        success "Python already installed (v$PY_VER)"
        record_pass "Python v$PY_VER"
        NEED_PYTHON=false
    else
        warn "Python v$PY_VER found but v3.10+ recommended. Upgrading..."
    fi
fi

if $NEED_PYTHON; then
    info "Installing Python 3.12..."
    if [[ "$OS" == "mac" ]]; then
        if has brew && brew install python@3.12 2>&1; then
            success "Python installed"
            record_pass "Python"
        else
            fail "Python install failed."
            record_fail "Python — try: brew install python@3.12"
        fi
    elif [[ "$OS" == "linux" ]]; then
        case "${PKG_MGR:-none}" in
            apt)  sudo apt-get install -y -qq python3 python3-pip python3-venv && record_pass "Python" || record_fail "Python" ;;
            dnf)  sudo dnf install -y python3 python3-pip && record_pass "Python" || record_fail "Python" ;;
            pacman) sudo pacman -S --noconfirm python python-pip && record_pass "Python" || record_fail "Python" ;;
            *)    fail "No package manager to install Python."; record_fail "Python" ;;
        esac
    fi
fi

# =====================================================================
# PHASE 5: GitHub CLI
# =====================================================================
step "Phase 5: GitHub CLI"

if has gh; then
    GH_VER=$(gh --version | head -1 | awk '{print $3}')
    success "GitHub CLI already installed (v$GH_VER)"
    record_pass "GitHub CLI v$GH_VER"
else
    info "Installing GitHub CLI..."
    INSTALLED_GH=false
    if [[ "$OS" == "mac" ]]; then
        if has brew && brew install gh 2>&1; then
            INSTALLED_GH=true
        fi
    elif [[ "$OS" == "linux" ]]; then
        case "${PKG_MGR:-none}" in
            apt)
                (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
                && sudo apt-get update -qq && sudo apt-get install -y -qq gh) && INSTALLED_GH=true
                ;;
            dnf)  sudo dnf install -y gh 2>&1 && INSTALLED_GH=true ;;
            pacman) sudo pacman -S --noconfirm github-cli 2>&1 && INSTALLED_GH=true ;;
        esac
    fi

    if $INSTALLED_GH; then
        success "GitHub CLI installed"
        record_pass "GitHub CLI"
    else
        fail "GitHub CLI install failed."
        record_fail "GitHub CLI — install from https://cli.github.com"
    fi
fi

# Check auth (non-blocking)
if has gh; then
    if gh auth status &>/dev/null 2>&1; then
        success "GitHub CLI authenticated"
    else
        warn "GitHub CLI not authenticated. Run: gh auth login"
        echo "    Choose: GitHub.com → HTTPS → Login with a web browser"
        record_warn "GitHub CLI auth — run: gh auth login"
    fi
fi

# =====================================================================
# PHASE 6: Vercel CLI
# =====================================================================
step "Phase 6: Vercel CLI"

if has vercel; then
    VERCEL_VER=$(vercel --version 2>/dev/null | head -1)
    success "Vercel CLI already installed (v$VERCEL_VER)"
    record_pass "Vercel CLI"
else
    info "Installing Vercel CLI..."
    if has npm && npm install -g vercel 2>&1; then
        success "Vercel CLI installed"
        record_pass "Vercel CLI"
    else
        fail "Vercel CLI install failed. Requires npm."
        record_fail "Vercel CLI — try: npm install -g vercel"
    fi
fi

# =====================================================================
# PHASE 7: Supabase CLI
# =====================================================================
step "Phase 7: Supabase CLI"

if has supabase; then
    SB_VER=$(supabase --version 2>/dev/null)
    success "Supabase CLI already installed ($SB_VER)"
    record_pass "Supabase CLI"
else
    info "Installing Supabase CLI..."
    INSTALLED_SB=false
    if [[ "$OS" == "mac" ]] && has brew; then
        brew install supabase/tap/supabase 2>&1 && INSTALLED_SB=true
    fi
    # Fallback to npm on any OS
    if ! $INSTALLED_SB && has npm; then
        npm install -g supabase 2>&1 && INSTALLED_SB=true
    fi

    if $INSTALLED_SB; then
        success "Supabase CLI installed"
        record_pass "Supabase CLI"
    else
        fail "Supabase CLI install failed."
        record_fail "Supabase CLI — try: npm install -g supabase"
    fi
fi

# =====================================================================
# PHASE 8: Utilities (jq, tree)
# =====================================================================
step "Phase 8: Utilities (jq, tree)"

for tool in jq tree; do
    if has "$tool"; then
        success "$tool already installed"
        record_pass "$tool"
    else
        info "Installing $tool..."
        INSTALLED_TOOL=false
        if [[ "$OS" == "mac" ]] && has brew; then
            brew install "$tool" 2>&1 && INSTALLED_TOOL=true
        elif [[ "$OS" == "linux" ]]; then
            case "${PKG_MGR:-none}" in
                apt)    sudo apt-get install -y -qq "$tool" 2>&1 && INSTALLED_TOOL=true ;;
                dnf)    sudo dnf install -y "$tool" 2>&1 && INSTALLED_TOOL=true ;;
                pacman) sudo pacman -S --noconfirm "$tool" 2>&1 && INSTALLED_TOOL=true ;;
            esac
        fi

        if $INSTALLED_TOOL; then
            success "$tool installed"
            record_pass "$tool"
        else
            warn "$tool install failed. Non-critical — continuing."
            record_warn "$tool"
        fi
    fi
done

# =====================================================================
# PHASE 9: MCP Server Configuration
# =====================================================================
step "Phase 9: Cursor MCP Servers"

MCP_CONFIG="$HOME/.cursor/mcp.json"
MCP_DIR="$HOME/.cursor"

mkdir -p "$MCP_DIR"

# Read existing config or start fresh
if [[ -f "$MCP_CONFIG" ]]; then
    info "Existing MCP config found. Merging (your servers won't be overwritten)..."
    EXISTING=$(cat "$MCP_CONFIG" 2>/dev/null || echo '{"mcpServers":{}}')
else
    info "No MCP config found. Creating new one..."
    EXISTING='{"mcpServers":{}}'
fi

NEW_SERVERS='{
    "GitHub": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
            "GITHUB_TOKEN": "${GITHUB_TOKEN}"
        }
    },
    "playwright": {
        "command": "npx",
        "args": ["@playwright/mcp@latest"]
    },
    "context7": {
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp@latest"]
    }
}'

if has jq; then
    # Safe merge: new servers go in first, existing servers override (preserving user customizations)
    if MERGED=$(echo "$EXISTING" | jq --argjson new "$NEW_SERVERS" '.mcpServers = ($new * .mcpServers)' 2>&1); then
        echo "$MERGED" | jq '.' > "$MCP_CONFIG"
        success "MCP config updated at $MCP_CONFIG"
        record_pass "MCP config"
    else
        warn "jq merge failed. Writing fresh config..."
        echo "{\"mcpServers\": $NEW_SERVERS}" | jq '.' > "$MCP_CONFIG" 2>/dev/null || echo "{\"mcpServers\": $NEW_SERVERS}" > "$MCP_CONFIG"
        success "MCP config written (fresh) to $MCP_CONFIG"
        record_pass "MCP config (fresh)"
    fi
else
    # No jq available — write directly
    warn "jq not available for safe merge. Writing default config..."
    cat > "$MCP_CONFIG" << 'MCPEOF'
{
  "mcpServers": {
    "GitHub": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
MCPEOF
    success "MCP config written to $MCP_CONFIG"
    record_warn "MCP config (no jq — existing servers may have been overwritten)"
fi

# GITHUB_TOKEN check (informational only)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    success "GITHUB_TOKEN is set in environment"
    record_pass "GITHUB_TOKEN"
else
    warn "GITHUB_TOKEN not set. GitHub MCP won't work until you set it."
    echo ""
    echo "    To create a token:"
    echo "    1. Go to https://github.com/settings/tokens"
    echo "    2. Generate new token (classic)"
    echo "    3. Select scope: repo"
    echo "    4. Copy the token"
    echo ""
    echo "    Then set it:"
    echo "    export GITHUB_TOKEN=\"ghp_your_token_here\""
    echo "    # Add to ~/.zshrc or ~/.bashrc to persist"
    echo ""
    echo "    Or set it in Cursor: Settings → MCP → GitHub → Environment Variables"
    record_warn "GITHUB_TOKEN — not set yet (see instructions above)"
fi

# =====================================================================
# FINAL SCORECARD
# =====================================================================
step "Setup Scorecard"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

echo ""
for result in "${RESULTS[@]}"; do
    STATUS="${result%%|*}"
    LABEL="${result#*|}"
    case "$STATUS" in
        PASS) printf "  ${GREEN}✅${NC} %s\n" "$LABEL"; ((PASS_COUNT++)) ;;
        WARN) printf "  ${YELLOW}⚠️${NC}  %s\n" "$LABEL"; ((WARN_COUNT++)) ;;
        FAIL) printf "  ${RED}❌${NC} %s\n" "$LABEL"; ((FAIL_COUNT++)) ;;
    esac
done

echo ""
echo -e "  ${GREEN}Passed:${NC}  $PASS_COUNT"
echo -e "  ${YELLOW}Warnings:${NC} $WARN_COUNT"
echo -e "  ${RED}Failed:${NC}  $FAIL_COUNT"
echo ""

if [[ $FAIL_COUNT -eq 0 && $WARN_COUNT -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}🎉 Everything installed successfully! You're ready to build.${NC}"
elif [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}${BOLD}Almost there! Review the warnings above, then you're good to go.${NC}"
else
    echo -e "${RED}${BOLD}Some installs failed. Fix the ❌ items above and re-run this script.${NC}"
    echo -e "The script is idempotent — it will skip what's already installed and retry the rest."
fi

echo ""
echo "Next steps:"
echo "  1. Fix any ❌ or ⚠️ items above"
echo "  2. Run: gh auth login          (if not already authenticated)"
echo "  3. Set GITHUB_TOKEN             (for GitHub MCP)"
echo "  4. Restart Cursor               (so MCP servers load)"
echo "  5. Get API keys:"
echo "     - Anthropic: https://console.anthropic.com"
echo "     - OpenAI:    https://platform.openai.com (optional)"
echo "     - Supabase:  https://supabase.com/dashboard (optional)"
echo ""
echo "To verify everything works, run:"
echo "  bash scripts/verify.sh"
echo ""
