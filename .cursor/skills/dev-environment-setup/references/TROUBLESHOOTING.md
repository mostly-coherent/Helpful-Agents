# Troubleshooting Guide

Common issues during dev environment setup and how to fix them.

---

## "command not found" After Install

**Symptom:** You installed a tool but the terminal says it's not found.

**Fix (Mac):**
```bash
# Reload your shell profile
source ~/.zshrc
# Or close and reopen the terminal
```

**Fix (Windows):**
```powershell
# Refresh PATH in current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
# Or close and reopen PowerShell / Cursor
```

**Why:** New installs add themselves to your PATH, but the current terminal session doesn't know about the change until reloaded.

---

## Homebrew Issues (Mac)

### "brew: command not found"

**Apple Silicon Macs (M1/M2/M3/M4):**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

**Intel Macs:**
```bash
eval "$(/usr/local/bin/brew shellenv)"
```

### "Permission denied" during brew install

```bash
sudo chown -R $(whoami) /opt/homebrew
# Or for Intel Macs:
sudo chown -R $(whoami) /usr/local
```

---

## Node.js Version Conflicts

### Multiple Node versions installed (nvm)

If you use nvm (Node Version Manager):
```bash
nvm install 20
nvm use 20
nvm alias default 20
```

### "npm: command not found" but Node is installed

npm comes bundled with Node. If it's missing:
```bash
# Mac
brew reinstall node@20

# Or reinstall from nodejs.org
```

---

## MCP Servers Red / Disconnected

### Server shows red dot in Cursor Settings → MCP

1. **Click the refresh button** next to the server
2. **Check the server logs** — click the server name for details
3. **Verify npx works:**
   ```bash
   npx -y @modelcontextprotocol/server-github --help
   ```
4. **Restart Cursor** — MCP servers load on startup

### GitHub MCP: "Bad credentials"

Your `GITHUB_TOKEN` is invalid or expired.

1. Go to https://github.com/settings/tokens
2. Check if your token is expired
3. Generate a new one with `repo` scope
4. Update in Cursor: Settings → MCP → GitHub → Environment Variables

### GitHub MCP: "GITHUB_TOKEN" not set

The token needs to be available as an environment variable:

**Option A: Set in Cursor MCP config** (recommended)
- Settings → MCP → GitHub → edit environment variables

**Option B: Set in shell profile**
```bash
# Mac: add to ~/.zshrc
export GITHUB_TOKEN="ghp_your_token_here"

# Windows: set as system environment variable
# System Properties → Advanced → Environment Variables → New
```

---

## Git Issues

### "xcrun: error: invalid active developer path"

macOS needs Xcode Command Line Tools:
```bash
xcode-select --install
```

### Git asks for password on every push

Switch to SSH or use credential helper:
```bash
# Use GitHub CLI for auth (easiest)
gh auth setup-git
```

---

## Python Issues

### "python: command not found" but python3 works

On Mac, `python` may not exist but `python3` does. This is normal.
```bash
# Use python3 explicitly
python3 --version

# Or create an alias in ~/.zshrc
alias python=python3
alias pip=pip3
```

### pip install fails with "externally-managed-environment"

Python 3.12+ on Mac restricts global pip installs:
```bash
# Use a virtual environment instead
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## Windows-Specific Issues

### "winget: command not found"

Install "App Installer" from the Microsoft Store, or download from:
https://aka.ms/getwinget

### PowerShell execution policy blocks scripts

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Long file paths cause errors

Enable long paths in Windows:
```powershell
# Run as Administrator
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

---

## Vercel CLI Issues

### "vercel: command not found" after npm install -g

```bash
# Check where global npm packages are installed
npm config get prefix

# The bin directory should be in your PATH
# Mac: usually /usr/local/bin or ~/.npm-global/bin
# Windows: usually %APPDATA%\npm
```

### "Error: No token found"

```bash
vercel login
# Follow the browser prompt to authenticate
```

---

## Supabase CLI Issues

### "supabase: command not found"

```bash
# Mac
brew install supabase/tap/supabase

# Or via npm (any OS)
npm install -g supabase
```

---

## General Tips

1. **When in doubt, restart Cursor.** Many issues resolve after a restart.
2. **Check your internet connection.** Most installs need to download packages.
3. **Corporate VPN can block installs.** Disconnect VPN if npm/brew/winget hangs.
4. **Don't run setup scripts as root/admin** unless specifically instructed (only the Linux apt-get commands need sudo).
5. **Re-run verify.sh** after fixing any issue to confirm it's resolved.
