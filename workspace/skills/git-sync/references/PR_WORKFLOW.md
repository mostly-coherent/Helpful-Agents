# GitSync — PR Workflow (Alternative)

## When to Use

Only when user explicitly requests PR workflow for major changes. User says "create PR", "use PR workflow", or wants documented review history.

**Default workflow (direct push to main) is preferred for routine syncs.** PR workflow adds overhead for solo projects.

## Steps

### Step 1: Create Branch and Push

```bash
cd "<WORKSPACE_ROOT>/<FOLDER_NAME>"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
git checkout -b "feature-$TIMESTAMP"
git add -A
git commit -m "feat: <description>"
git push -u origin "feature-$TIMESTAMP"
```

### Step 2: Create and Auto-Merge PR

```bash
gh pr create --title "Feature: <description>" --body "<details>" --base main
gh pr merge --squash --delete-branch --auto
```

## When PR Workflow Makes Sense

- Major feature additions that benefit from documented review
- Changes that affect multiple systems
- When user wants a clean merge commit history
- Collaborative projects (not solo)

## When to Skip PR (Use Direct Push)

- Routine syncs and small changes
- Solo personal projects
- Documentation updates
- Configuration changes
