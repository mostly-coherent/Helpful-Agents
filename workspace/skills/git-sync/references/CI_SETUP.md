# GitSync — GitHub Actions CI/CD Setup

## Purpose

Catch build errors before they reach your deployment platform (e.g., Vercel, Netlify) by running `npm run build` on every push. Without CI, broken code gets pushed and fails during deployment — wasting time waiting for the build, discovering errors, then fixing and re-deploying.

## Setup Command

**When:** User says "set up GitHub Actions for [project]" or "add CI/CD to [project]"

```bash
cd "<WORKSPACE_ROOT>/<PROJECT_NAME>" && \
mkdir -p .github/workflows && \
cat > .github/workflows/ci.yml << 'EOF'
name: CI Build Check

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run build
      run: npm run build
    
    - name: Run tests (if available)
      run: npm test --if-present
      continue-on-error: true
EOF
git add .github/workflows/ci.yml && \
git commit -m "ci: add GitHub Actions build check" && \
git push origin main
```

**Replace:** `<PROJECT_NAME>` with actual folder name.

## Verification

```bash
cd "<WORKSPACE_ROOT>/<PROJECT_NAME>"
gh run list --limit 3
```

## What Happens

**On push to main:** GitHub Actions triggers → Ubuntu container → installs Node.js + deps → runs `npm run build` → green checkmark (pass) or red X (fail).

**On pull requests:** Same checks run before merge. Can enforce "require passing checks" in branch protection.

## Which Projects Need This?

| Recommended | Not Needed |
|-------------|------------|
| Next.js/React apps with auto-deployment | Documentation-only repos |
| TypeScript projects with strict type checking | Python scripts without CI requirements |
| Any project with automated deployments | Local-only tools |

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Action fails with "npm ERR!" | Check if `package-lock.json` is committed |
| Action skipped | Check if `.github/workflows/ci.yml` is on main branch |
| Build passes locally but fails in CI | Check Node version (CI uses 20, local might differ) |
| Tests fail but build succeeds | `continue-on-error: true` allows non-critical test failures |

## Branch Protection (Optional)

1. GitHub repo → Settings → Branches
2. Add rule for `main` branch
3. Enable: "Require status checks to pass before merging"
4. Select: "CI Build Check"

Not needed for direct push workflow (default), but useful if using PR workflow.
