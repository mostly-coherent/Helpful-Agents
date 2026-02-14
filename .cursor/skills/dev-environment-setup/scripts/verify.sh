#!/bin/bash
# =============================================================================
# Dev Environment Verification
# =============================================================================
# Checks that all tools are installed and working.
# Run after setup.sh to confirm everything is ready.
#
# Usage:
#   bash scripts/verify.sh
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
    local name="$1"
    local cmd="$2"
    local required="$3"  # "required" or "optional"

    if command -v "$cmd" &>/dev/null; then
        local ver
        case "$cmd" in
            node)     ver=$(node -v 2>/dev/null) ;;
            npm)      ver="v$(npm -v 2>/dev/null)" ;;
            git)      ver=$(git --version 2>/dev/null | awk '{print "v"$3}') ;;
            gh)       ver=$(gh --version 2>/dev/null | head -1 | awk '{print "v"$3}') ;;
            python3)  ver="v$($cmd --version 2>&1 | awk '{print $2}')" ;;
            python)   ver="v$($cmd --version 2>&1 | awk '{print $2}')" ;;
            vercel)   ver="v$(vercel --version 2>/dev/null | head -1)" ;;
            supabase) ver="$(supabase --version 2>/dev/null)" ;;
            jq)       ver="v$(jq --version 2>/dev/null | sed 's/jq-//')" ;;
            tree)     ver="$(tree --version 2>/dev/null | head -1)" ;;
            *)        ver="installed" ;;
        esac
        printf "${GREEN}✅${NC} %-14s %s\n" "$name" "$ver"
        ((PASS++))
    else
        if [[ "$required" == "required" ]]; then
            printf "${RED}❌${NC} %-14s %s\n" "$name" "NOT FOUND"
            ((FAIL++))
        else
            printf "${YELLOW}⚠️${NC}  %-14s %s\n" "$name" "not installed (optional)"
            ((WARN++))
        fi
    fi
}

check_mcp() {
    local name="$1"
    local mcp_config="$HOME/.cursor/mcp.json"

    if [[ -f "$mcp_config" ]] && command -v jq &>/dev/null; then
        if jq -e ".mcpServers.\"$name\"" "$mcp_config" &>/dev/null; then
            printf "${GREEN}✅${NC} %-14s %s\n" "MCP: $name" "configured"
            ((PASS++))
        else
            printf "${RED}❌${NC} %-14s %s\n" "MCP: $name" "NOT configured"
            ((FAIL++))
        fi
    elif [[ -f "$mcp_config" ]]; then
        # No jq, just check if the name appears in the file
        if grep -q "\"$name\"" "$mcp_config" 2>/dev/null; then
            printf "${GREEN}✅${NC} %-14s %s\n" "MCP: $name" "configured (unverified)"
            ((PASS++))
        else
            printf "${RED}❌${NC} %-14s %s\n" "MCP: $name" "NOT configured"
            ((FAIL++))
        fi
    else
        printf "${RED}❌${NC} %-14s %s\n" "MCP config" "~/.cursor/mcp.json not found"
        ((FAIL++))
    fi
}

check_gh_auth() {
    if command -v gh &>/dev/null; then
        if gh auth status &>/dev/null 2>&1; then
            local user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
            printf "${GREEN}✅${NC} %-14s %s\n" "GitHub auth" "logged in as $user"
            ((PASS++))
        else
            printf "${YELLOW}⚠️${NC}  %-14s %s\n" "GitHub auth" "not authenticated (run: gh auth login)"
            ((WARN++))
        fi
    fi
}

check_env_var() {
    local name="$1"
    local required="$2"

    if [[ -n "${!name:-}" ]]; then
        # Show first 8 chars only for security
        local preview="${!name:0:8}..."
        printf "${GREEN}✅${NC} %-14s %s\n" "$name" "set ($preview)"
        ((PASS++))
    else
        if [[ "$required" == "required" ]]; then
            printf "${RED}❌${NC} %-14s %s\n" "$name" "NOT SET"
            ((FAIL++))
        else
            printf "${YELLOW}⚠️${NC}  %-14s %s\n" "$name" "not set (optional)"
            ((WARN++))
        fi
    fi
}

# ---------------------------------------------------------------------------
echo -e "\n${BLUE}━━━ Dev Environment Verification ━━━${NC}\n"

echo -e "${BLUE}Core Tools:${NC}"
check "Node.js"      "node"     "required"
check "npm"          "npm"      "required"
check "Git"          "git"      "required"
check "GitHub CLI"   "gh"       "required"

echo ""
echo -e "${BLUE}Languages:${NC}"
check "Python"       "python3"  "optional"
# Fallback: check 'python' if 'python3' not found
if ! command -v python3 &>/dev/null; then
    check "Python"   "python"   "optional"
fi

echo ""
echo -e "${BLUE}Deployment & Database:${NC}"
check "Vercel CLI"   "vercel"   "optional"
check "Supabase CLI" "supabase" "optional"

echo ""
echo -e "${BLUE}Utilities:${NC}"
check "jq"           "jq"       "optional"
check "tree"         "tree"     "optional"

echo ""
echo -e "${BLUE}Authentication:${NC}"
check_gh_auth

echo ""
echo -e "${BLUE}MCP Servers:${NC}"
check_mcp "GitHub"
check_mcp "playwright"
check_mcp "context7"

echo ""
echo -e "${BLUE}Environment Variables:${NC}"
check_env_var "GITHUB_TOKEN" "optional"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}━━━ Summary ━━━${NC}"
echo ""
printf "  ${GREEN}✅ Passed:${NC}  %d\n" "$PASS"
printf "  ${YELLOW}⚠️  Warned:${NC} %d\n" "$WARN"
printf "  ${RED}❌ Failed:${NC}  %d\n" "$FAIL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}🎉 All required tools are installed. You're ready to build!${NC}"
    exit 0
elif [[ $FAIL -le 2 ]]; then
    echo -e "${YELLOW}Almost there! Fix the failed items above and re-run this script.${NC}"
    exit 1
else
    echo -e "${RED}Several tools are missing. Run setup.sh first, then re-verify.${NC}"
    exit 1
fi
