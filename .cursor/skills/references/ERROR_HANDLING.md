# GitSync Error Handling & Troubleshooting

## Error Resolution Table

| Error | Resolution |
|-------|------------|
| Remote points to wrong org | **STOP** — Fix remote: `git remote set-url origin https://github.com/<GITHUB_USERNAME>/<folder>.git` |
| Auth failure (permission denied) | Run: `gh auth switch --user <GH_CLI_USER>` |
| **Repository not found** (SSH push) | SSH key may be tied to another account. Switch to HTTPS: `git remote set-url origin https://github.com/<GITHUB_USERNAME>/<folder>.git` |
| **OAuth App... without `workflow` scope** (HTTPS push) | Push creates/updates `.github/workflows/*`. Fix: `gh auth refresh -h github.com -s workflow` (opens browser). Then re-run sync. |
| **"received credentials for X" when refreshing Y** | gh stores account under one name but GitHub returns another. **One-time fix:** `gh auth logout -h github.com` (choose old name), then `gh auth login -h github.com -p https -s repo,workflow,gist,read:org` (sign in with current username). |
| Push rejected (non-fast-forward) | Pull first: `git pull origin main --rebase` |
| Commit fails (wrong email) | Fix: `git config user.email "<GIT_EMAIL>"` |

## Why Sync Might "Stop Working Smoothly"

| Symptom | Cause | Fix |
|---------|-------|-----|
| One repo always fails with "OAuth App... without workflow scope" | Repo has `.github/workflows/*` changes; gh CLI's cached token lacks `workflow` scope | `gh auth refresh -h github.com -s workflow` then re-run sync |
| Auth refresh says "received credentials for X" | gh stores account under legacy name but GitHub returns current username; gh rejects as "wrong account" | Log out old name, log in fresh with current username (see error table above) |
| Batch sync reports ❌ for one repo but others succeed | Usually workflow-scope issue, or wrong remote | Check `gh auth status` (scopes) and `git remote -v` in failed repo |
| Repo shows "ahead 1" after failed push | Sync committed locally but push was rejected | Fix scope/remote, then `git push origin main` (no need to commit again) |

## PII Scan — Safe Alternatives

When PII is found in a PUBLIC repo diff, replace with these generic placeholders:

| PII Pattern | Safe Alternative |
|-------------|-----------------|
| Real workspace path | `/path/to/workspace/...` |
| Personal email | `user@example.com` |
| Work email | `work@example.com` |
| GitHub username (in docs/configs) | `your-github-username` |
| Workspace name | `your-workspace` |
| Real name / username | `your-name` / `your-username` |

**Note:** Your GitHub username in git remote URLs is fine (it's the repo owner, visible on GitHub). The PII scan flags it in *content* (docs, configs, comments) where it reveals personal identity in contexts you might not want public.
