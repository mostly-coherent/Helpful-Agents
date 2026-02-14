# =============================================================================
# Dev Environment Setup — Windows (PowerShell)
# =============================================================================
# One-time setup for building apps with Cursor.
# Idempotent: safe to run multiple times (skips already-installed tools).
# RESILIENT: individual failures do NOT stop the script. Every phase runs
#            regardless of whether the previous one succeeded. A final
#            scorecard tells you exactly what worked and what needs attention.
#
# Usage (run in PowerShell — Administrator recommended for winget):
#   powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
# =============================================================================

# NOTE: We intentionally do NOT use $ErrorActionPreference = "Stop".
# Each phase handles its own errors and continues to the next.
$ErrorActionPreference = "Continue"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Step($msg) { Write-Host "`n━━━ $msg ━━━" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "ℹ  $msg" -ForegroundColor Blue }

function Test-Command($cmd) {
    try { Get-Command $cmd -ErrorAction Stop | Out-Null; return $true }
    catch { return $false }
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Scorecard
$script:Results = @()
function Record-Pass($label) { $script:Results += [PSCustomObject]@{Status="PASS"; Label=$label} }
function Record-Warn($label) { $script:Results += [PSCustomObject]@{Status="WARN"; Label=$label} }
function Record-Fail($label) { $script:Results += [PSCustomObject]@{Status="FAIL"; Label=$label} }

# =====================================================================
# PHASE 1: Package Manager (winget)
# =====================================================================
Write-Step "Phase 1: Package Manager"

$hasWinget = Test-Command "winget"
if ($hasWinget) {
    Write-Ok "winget is available"
    Record-Pass "winget"
} else {
    Write-Fail "winget not found."
    Write-Info "winget comes pre-installed on Windows 10 (1809+) and Windows 11."
    Write-Info "If missing, install 'App Installer' from the Microsoft Store: https://aka.ms/getwinget"
    Record-Fail "winget — install from https://aka.ms/getwinget"
    # Don't exit — npm-based installs can still work if Node is already present
}

# =====================================================================
# PHASE 2: Git
# =====================================================================
Write-Step "Phase 2: Git"

if (Test-Command "git") {
    $gitVer = git --version
    Write-Ok "Git already installed ($gitVer)"
    Record-Pass "Git"
} else {
    Write-Info "Installing Git..."
    try {
        if ($hasWinget) {
            winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "git") {
            Write-Ok "Git installed"
            Record-Pass "Git"
        } else {
            throw "Git not found after install"
        }
    } catch {
        Write-Fail "Git install failed. Install manually from https://git-scm.com"
        Record-Fail "Git — install from https://git-scm.com"
    }
}

# =====================================================================
# PHASE 3: Node.js
# =====================================================================
Write-Step "Phase 3: Node.js"

$needNode = $true
if (Test-Command "node") {
    try {
        $nodeVer = (node -v).TrimStart("v")
        $major = [int]($nodeVer.Split(".")[0])
        if ($major -ge 18) {
            Write-Ok "Node.js already installed (v$nodeVer)"
            Record-Pass "Node.js v$nodeVer"
            $needNode = $false
        } else {
            Write-Warn "Node.js v$nodeVer found but v18+ required. Upgrading..."
        }
    } catch {
        Write-Warn "Could not determine Node.js version. Attempting install..."
    }
}

if ($needNode) {
    Write-Info "Installing Node.js 20 LTS..."
    try {
        if ($hasWinget) {
            winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "node") {
            $nodeVer = (node -v).TrimStart("v")
            Write-Ok "Node.js v$nodeVer installed"
            Record-Pass "Node.js v$nodeVer"
        } else {
            throw "Node not found after install"
        }
    } catch {
        Write-Fail "Node.js install failed. Install manually from https://nodejs.org"
        Record-Fail "Node.js — install from https://nodejs.org"
    }
}

# Verify npm
if (Test-Command "npm") {
    Write-Ok "npm available"
} else {
    Write-Warn "npm not found. Usually comes with Node.js."
    Record-Warn "npm — reinstall Node.js"
}

# =====================================================================
# PHASE 4: Python
# =====================================================================
Write-Step "Phase 4: Python"

$needPython = $true
if (Test-Command "python") {
    try {
        $pyVer = (python --version 2>&1).ToString().Split(" ")[1]
        $pyMajor = [int]($pyVer.Split(".")[0])
        $pyMinor = [int]($pyVer.Split(".")[1])
        if ($pyMajor -ge 3 -and $pyMinor -ge 10) {
            Write-Ok "Python already installed (v$pyVer)"
            Record-Pass "Python v$pyVer"
            $needPython = $false
        } else {
            Write-Warn "Python v$pyVer found but v3.10+ recommended."
        }
    } catch {
        Write-Warn "Could not determine Python version."
    }
}

if ($needPython) {
    Write-Info "Installing Python 3.12..."
    try {
        if ($hasWinget) {
            winget install --id Python.Python.3.12 -e --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "python") {
            Write-Ok "Python installed"
            Record-Pass "Python"
        } else {
            throw "Python not found after install"
        }
    } catch {
        Write-Fail "Python install failed. Install from https://python.org"
        Record-Fail "Python — install from https://python.org"
    }
}

# =====================================================================
# PHASE 5: GitHub CLI
# =====================================================================
Write-Step "Phase 5: GitHub CLI"

if (Test-Command "gh") {
    $ghVer = (gh --version | Select-Object -First 1)
    Write-Ok "GitHub CLI already installed ($ghVer)"
    Record-Pass "GitHub CLI"
} else {
    Write-Info "Installing GitHub CLI..."
    try {
        if ($hasWinget) {
            winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "gh") {
            Write-Ok "GitHub CLI installed"
            Record-Pass "GitHub CLI"
        } else {
            throw "gh not found after install"
        }
    } catch {
        Write-Fail "GitHub CLI install failed. Install from https://cli.github.com"
        Record-Fail "GitHub CLI — install from https://cli.github.com"
    }
}

# Check auth (non-blocking)
if (Test-Command "gh") {
    try {
        $authResult = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "GitHub CLI authenticated"
        } else {
            Write-Warn "GitHub CLI not authenticated. Run: gh auth login"
            Record-Warn "GitHub CLI auth — run: gh auth login"
        }
    } catch {
        Write-Warn "GitHub CLI not authenticated. Run: gh auth login"
        Record-Warn "GitHub CLI auth — run: gh auth login"
    }
}

# =====================================================================
# PHASE 6: Vercel CLI
# =====================================================================
Write-Step "Phase 6: Vercel CLI"

if (Test-Command "vercel") {
    Write-Ok "Vercel CLI already installed"
    Record-Pass "Vercel CLI"
} else {
    Write-Info "Installing Vercel CLI..."
    try {
        if (Test-Command "npm") {
            npm install -g vercel 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "vercel") {
            Write-Ok "Vercel CLI installed"
            Record-Pass "Vercel CLI"
        } else {
            throw "vercel not found after install"
        }
    } catch {
        Write-Fail "Vercel CLI install failed. Try: npm install -g vercel"
        Record-Fail "Vercel CLI — try: npm install -g vercel"
    }
}

# =====================================================================
# PHASE 7: Supabase CLI
# =====================================================================
Write-Step "Phase 7: Supabase CLI"

if (Test-Command "supabase") {
    Write-Ok "Supabase CLI already installed"
    Record-Pass "Supabase CLI"
} else {
    Write-Info "Installing Supabase CLI via npm..."
    try {
        if (Test-Command "npm") {
            npm install -g supabase 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "supabase") {
            Write-Ok "Supabase CLI installed"
            Record-Pass "Supabase CLI"
        } else {
            throw "supabase not found after install"
        }
    } catch {
        Write-Fail "Supabase CLI install failed. Try: npm install -g supabase"
        Record-Fail "Supabase CLI — try: npm install -g supabase"
    }
}

# =====================================================================
# PHASE 8: Utilities
# =====================================================================
Write-Step "Phase 8: Utilities"

if (Test-Command "jq") {
    Write-Ok "jq already installed"
    Record-Pass "jq"
} else {
    Write-Info "Installing jq..."
    try {
        if ($hasWinget) {
            winget install --id jqlang.jq -e --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            Refresh-Path
        }
        if (Test-Command "jq") {
            Write-Ok "jq installed"
            Record-Pass "jq"
        } else {
            throw "jq not found after install"
        }
    } catch {
        Write-Warn "jq install failed. Non-critical — continuing."
        Record-Warn "jq"
    }
}

# =====================================================================
# PHASE 9: MCP Server Configuration
# =====================================================================
Write-Step "Phase 9: Cursor MCP Servers"

$mcpDir = "$env:USERPROFILE\.cursor"
$mcpConfig = "$mcpDir\mcp.json"

if (-not (Test-Path $mcpDir)) {
    New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null
}

$newServers = @{
    "GitHub" = @{
        "command" = "npx"
        "args" = @("-y", "@modelcontextprotocol/server-github")
        "env" = @{
            "GITHUB_TOKEN" = "`${GITHUB_TOKEN}"
        }
    }
    "playwright" = @{
        "command" = "npx"
        "args" = @("@playwright/mcp@latest")
    }
    "context7" = @{
        "command" = "npx"
        "args" = @("-y", "@upstash/context7-mcp@latest")
    }
}

try {
    if (Test-Path $mcpConfig) {
        Write-Info "Existing MCP config found. Merging (your servers won't be overwritten)..."
        $existing = Get-Content $mcpConfig -Raw | ConvertFrom-Json
        if (-not $existing.mcpServers) {
            $existing | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{}) -Force
        }
        foreach ($key in $newServers.Keys) {
            if (-not $existing.mcpServers.PSObject.Properties[$key]) {
                $existing.mcpServers | Add-Member -NotePropertyName $key -NotePropertyValue $newServers[$key] -Force
                Write-Info "  Added MCP server: $key"
            } else {
                Write-Info "  MCP server already configured: $key (kept your version)"
            }
        }
        $existing | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig -Encoding UTF8
    } else {
        Write-Info "No MCP config found. Creating new one..."
        @{ "mcpServers" = $newServers } | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig -Encoding UTF8
    }
    Write-Ok "MCP config updated at $mcpConfig"
    Record-Pass "MCP config"
} catch {
    Write-Fail "MCP config update failed: $_"
    Record-Fail "MCP config"
}

# GITHUB_TOKEN check (informational)
if ($env:GITHUB_TOKEN) {
    Write-Ok "GITHUB_TOKEN is set"
    Record-Pass "GITHUB_TOKEN"
} else {
    Write-Warn "GITHUB_TOKEN not set. GitHub MCP won't work until you set it."
    Write-Host ""
    Write-Host "    To create a token:"
    Write-Host "    1. Go to https://github.com/settings/tokens"
    Write-Host "    2. Generate new token (classic)"
    Write-Host "    3. Select scope: repo"
    Write-Host "    4. Copy the token"
    Write-Host ""
    Write-Host "    Then set it (PowerShell):"
    Write-Host '    $env:GITHUB_TOKEN = "ghp_your_token_here"'
    Write-Host "    # To persist: System Properties → Advanced → Environment Variables → New"
    Write-Host ""
    Write-Host "    Or set it in Cursor: Settings → MCP → GitHub → Environment Variables"
    Record-Warn "GITHUB_TOKEN — not set yet"
}

# =====================================================================
# FINAL SCORECARD
# =====================================================================
Write-Step "Setup Scorecard"

$passCount = 0
$warnCount = 0
$failCount = 0

Write-Host ""
foreach ($r in $script:Results) {
    switch ($r.Status) {
        "PASS" { Write-Host "  ✅ $($r.Label)" -ForegroundColor Green; $passCount++ }
        "WARN" { Write-Host "  ⚠️  $($r.Label)" -ForegroundColor Yellow; $warnCount++ }
        "FAIL" { Write-Host "  ❌ $($r.Label)" -ForegroundColor Red; $failCount++ }
    }
}

Write-Host ""
Write-Host "  Passed:   $passCount" -ForegroundColor Green
Write-Host "  Warnings: $warnCount" -ForegroundColor Yellow
Write-Host "  Failed:   $failCount" -ForegroundColor Red
Write-Host ""

if ($failCount -eq 0 -and $warnCount -eq 0) {
    Write-Host "🎉 Everything installed successfully! You're ready to build." -ForegroundColor Green
} elseif ($failCount -eq 0) {
    Write-Host "Almost there! Review the warnings above, then you're good to go." -ForegroundColor Yellow
} else {
    Write-Host "Some installs failed. Fix the ❌ items above and re-run this script." -ForegroundColor Red
    Write-Host "The script is idempotent — it will skip what's already installed and retry the rest." -ForegroundColor Red
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Fix any ❌ or ⚠️ items above"
Write-Host "  2. Run: gh auth login          (if not already authenticated)"
Write-Host "  3. Set GITHUB_TOKEN             (for GitHub MCP)"
Write-Host "  4. Restart Cursor               (so MCP servers load)"
Write-Host "  5. Get API keys:"
Write-Host "     - Anthropic: https://console.anthropic.com"
Write-Host "     - OpenAI:    https://platform.openai.com (optional)"
Write-Host "     - Supabase:  https://supabase.com/dashboard (optional)"
Write-Host ""
