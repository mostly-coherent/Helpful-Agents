# Install Commands Reference

Detailed per-tool installation commands with primary and fallback methods. The agent reads this when it needs specific commands for a tool.

---

## Homebrew (Mac Only)

**Primary:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Apple Silicon PATH fix (run after install):**
```bash
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi
```

If Homebrew fails, use direct download methods for subsequent tools.

---

## Git

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install git` | `xcode-select --install` |
| Windows | `winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements` | Download from https://git-scm.com |
| Linux (apt) | `sudo apt-get update -qq && sudo apt-get install -y -qq git` | — |
| Linux (dnf) | `sudo dnf install -y git` | — |
| Linux (pacman) | `sudo pacman -S --noconfirm git` | — |

**Verify:** `git --version`

---

## Node.js 20 LTS

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install node@20 && brew link --overwrite node@20 2>/dev/null \|\| true` | `curl -fsSL https://nodejs.org/dist/v20.18.1/node-v20.18.1.pkg -o /tmp/node.pkg && sudo installer -pkg /tmp/node.pkg -target / && rm /tmp/node.pkg` |
| Windows | `winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements` | Download from https://nodejs.org |
| Linux (apt) | `curl -fsSL https://deb.nodesource.com/setup_20.x \| sudo -E bash - && sudo apt-get install -y nodejs` | — |

**Verify:** `node -v` (should show v20+) and `npm -v`

---

## Python 3.12+

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install python@3.12` | macOS ships with Python 3 via Xcode CLI tools. Check `python3 --version`. |
| Windows | `winget install --id Python.Python.3.12 -e --accept-package-agreements --accept-source-agreements` | Download from https://python.org |
| Linux (apt) | `sudo apt-get install -y -qq python3 python3-pip python3-venv` | — |
| Linux (dnf) | `sudo dnf install -y python3 python3-pip` | — |
| Linux (pacman) | `sudo pacman -S --noconfirm python python-pip` | — |

**Verify:** `python3 --version` or `python --version`

---

## GitHub CLI

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install gh` | `curl -fsSL https://github.com/cli/cli/releases/latest/download/gh_*_macOS_arm64.zip -o /tmp/gh.zip && unzip -o /tmp/gh.zip -d /tmp/gh && sudo cp /tmp/gh/*/bin/gh /usr/local/bin/ && rm -rf /tmp/gh /tmp/gh.zip` |
| Windows | `winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements` | Download from https://cli.github.com |
| Linux (apt) | `curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \| sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt-get update -qq && sudo apt-get install -y -qq gh` | — |

**Verify:** `gh --version`

**Authenticate:** `gh auth login --web --git-protocol https` — tell user a browser window will open.

---

## Vercel CLI

**All OS:** `npm install -g vercel`

**Verify:** `vercel --version`

---

## Supabase CLI

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install supabase/tap/supabase` | `npm install -g supabase` |
| Windows/Linux | `npm install -g supabase` | — |

**Verify:** `supabase --version`

---

## Docker Desktop

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install --cask docker` | Download from https://docker.com/products/docker-desktop |
| Windows | `winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements` | Download from https://docker.com/products/docker-desktop |

**Verify:** `docker --version`

**Note:** Docker Desktop may require a restart and user to open the app once.

---

## jq

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install jq` | `curl -fsSL https://github.com/jqlang/jq/releases/latest/download/jq-macos-arm64 -o /usr/local/bin/jq && chmod +x /usr/local/bin/jq` |
| Windows | `winget install --id jqlang.jq -e --accept-package-agreements --accept-source-agreements` | — |
| Linux (apt) | `sudo apt-get install -y -qq jq` | — |

**Verify:** `jq --version`

---

## tree

| OS | Primary | Notes |
|----|---------|-------|
| Mac | `brew install tree` | — |
| Windows | Built-in | `tree` command exists natively. Skip install. |
| Linux (apt) | `sudo apt-get install -y -qq tree` | — |

**Verify:** `tree --version` (Mac/Linux) or `tree /?` (Windows)

---

## wget

| OS | Primary | Fallback |
|----|---------|----------|
| Mac | `brew install wget` | Skip — `curl` is available as alternative |
| Windows | `winget install --id JernejSimoncic.Wget -e --accept-package-agreements --accept-source-agreements` | Skip — `curl` is available |

**Verify:** `wget --version | head -1`
