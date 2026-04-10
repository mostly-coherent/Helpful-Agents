# Fix Claude Code Permission Prompts (Stop the Madness)

Claude Code asks permission for nearly every action by default. This guide configures maximum autonomy while keeping safety guardrails for destructive operations.

**Applies to:** Claude Code in CLI/Terminal, Claude Desktop app, and VS Code/JetBrains extensions. They all read the same settings file (`~/.claude/settings.json`), so you configure once and it works everywhere.

---

## The Problem

Out of the box, Claude Code prompts you to approve:
- Every shell command (even `ls`, `grep`, piped commands)
- Every file search (`Glob`, `Grep`)
- Every MCP tool call (GitHub, Jira, Slack, Wiki, etc.)
- Every subagent spawn, web fetch, skill invocation

This makes it unusable for real work.

## The Fix

Two settings files control permissions. **User-level** applies to all Claude Code surfaces (CLI, Desktop, IDE extensions). **Workspace-level** applies per project and overrides user-level.

| File | Scope |
|------|-------|
| `~/.claude/settings.json` | All projects (user-level) |
| `<project>/.claude/settings.json` | Single project (workspace-level) |

### What You Need to Know

- **`allow`** — Auto-approved, no prompt
- **`ask`** — Prompts once per action (use for irreversible stuff)
- **`deny`** — Blocked entirely
- **`Bash(*)`** — Allows ALL shell commands including piped (`cmd | cmd`) and chained (`cmd && cmd`). Individual command rules like `Bash(git status *)` only match commands starting with that exact string — they fail on pipes.
- **`mcp__ServerName`** — Allows ALL tools from that MCP server. Use `mcp__ServerName__tool_name` for specific tools only.

---

## Copy-Paste Setup

Create or replace `~/.claude/settings.json` with this. One file, done.

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Glob(*)",
      "Grep(*)",
      "WebFetch(*)",
      "WebSearch(*)",
      "NotebookEdit(*)",
      "Agent(*)",
      "Skill(*)",
      "TodoWrite(*)",
      "CronCreate(*)",
      "CronDelete(*)",
      "CronList(*)",
      "EnterPlanMode(*)",
      "ExitPlanMode(*)",
      "EnterWorktree(*)",
      "ExitWorktree(*)",
      "AskUserQuestion(*)",
      "TaskOutput(*)",
      "TaskStop(*)",
      "RemoteTrigger(*)",
      "mcp__Corp_GitHub",
      "mcp__Corp_Jira",
      "mcp__Slack",
      "mcp__Adobe_Wiki",
      "mcp__PR_Review",
      "mcp__Desktop_Commander",
      "mcp__Claude_Preview",
      "mcp__Control_Chrome",
      "mcp__Claude_in_Chrome",
      "mcp__scheduled-tasks",
      "mcp__mcp-registry"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(rm -rf /*)",
      "Read(.env)",
      "Read(.env.*)",
      "Read(*/.env)",
      "Read(*/.env.*)",
      "Read(*/secrets/*)"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(vercel *)",
      "Bash(npx vercel *)",
      "Bash(npm publish *)",
      "Bash(rm -rf *)",
      "Bash(rm -r *)"
    ]
  }
}
```

**Then restart Claude Code everywhere you use it** — CLI/Terminal, Desktop app, and any IDE extensions. They all pick up the same file, but each needs a restart to reload it.

### Workspace-Level Override (Optional)

If you want per-project overrides, create `<project>/.claude/settings.json` with the same structure. Workspace settings override user-level for that project.

### Additional MCP Servers

If you have MCP servers beyond the Adobe ones above, find their names with `claude mcp list` and add `"mcp__<ServerName>"` to the `allow` array. Names are case-sensitive and must match your `.mcp.json` config exactly.

---

## Customization Guide

### To allow a specific dangerous command without prompting:
Move it from `ask` to `allow`. Example — auto-approve git push:
```json
// Remove from "ask", add to "allow":
"Bash(git push *)"
```

### To block something entirely:
Add to `deny`. Deny always wins over allow.

### To prompt for specific MCP tools (not all):
Replace the server-wide entry with specific tools:
```json
// Instead of:
"mcp__Slack"

// Use specific tools:
"mcp__Slack__slack_search_messages",
"mcp__Slack__slack_get_channel_history"
// (slack_post_message and slack_send_dm would still prompt)
```

### Common additions to `ask` (prompt before executing):
```json
"Bash(docker *)",           // Container operations
"Bash(kubectl *)",          // Kubernetes
"Bash(aws *)",              // AWS CLI
"Bash(terraform *)",        // Infrastructure
"Bash(DROP *)",             // SQL destructive
"Bash(DELETE FROM *)"       // SQL destructive
```

---

## Complete Built-in Tool Reference

These are ALL the tool names Claude Code uses internally. If you're getting prompted for something, its tool name is in the permission dialog — add it to `allow`.

| Tool | What it does |
|------|-------------|
| `Bash` | Shell commands (ALL commands, pipes, chains) |
| `Read` | Read files |
| `Write` | Create/overwrite files |
| `Edit` | Surgical file edits |
| `Glob` | Find files by pattern (`**/*.ts`) |
| `Grep` | Search file contents |
| `WebFetch` | Fetch URL content |
| `WebSearch` | Web search |
| `Agent` | Spawn subagents |
| `Skill` | Run skills/slash commands |
| `TodoWrite` | Task tracking |
| `NotebookEdit` | Jupyter notebooks |
| `CronCreate/Delete/List` | Scheduled tasks |
| `EnterPlanMode/ExitPlanMode` | Planning workflow |
| `EnterWorktree/ExitWorktree` | Git worktrees |
| `AskUserQuestion` | Interactive questions |
| `TaskOutput/TaskStop` | Background task management |
| `RemoteTrigger` | Remote trigger API |

---

## Troubleshooting

**Still getting prompted after restart?**
1. Check the permission dialog — it shows the exact tool name and pattern. Add that to `allow`.
2. Piped commands (`find . | grep foo`) need `Bash(*)` — individual command rules won't match pipes.
3. MCP server names are case-sensitive and must match your `.mcp.json` config exactly.
4. Workspace settings override user settings — check both files.

**Want to see your current effective permissions?**
```bash
cat ~/.claude/settings.json
cat .claude/settings.json  # from project root
```
