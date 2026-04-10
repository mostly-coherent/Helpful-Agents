# Cursor vs. Claude Code: Configuration Primitives (Builder's Guide)

> **The short version:** Cursor and Claude Code share the same five configuration primitives — skills, commands, standing instructions, hooks, and subagents. Most of what you've built in Cursor transfers directly, with at most a folder name or filename change. Two exceptions: hooks use different formats (rebuild separately), and Cursor User Rules live in Settings (UI) — export or transcribe them manually. The migration prompt at the end handles the rest.

Here's the practical breakdown: for each primitive, what transfers automatically, what needs a small adjustment, and what requires separate handling.

---

## Two Levels: User vs. Project (Plus Org)

Before getting into each primitive, one concept worth understanding: **both tools support the same two levels of configuration** — plus an organizational level for teams.

| Level | What it means | Cursor location | Claude Code location |
|---|---|---|---|
| **Org/Managed** | IT-deployed, applies to all users on a machine | Team Rules (dashboard, Team/Enterprise) | Managed policy CLAUDE.md (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS) |
| **User-level** | Applies to every project on your machine — your personal defaults | `~/.cursor/` | `~/.claude/` |
| **Project-level** | Applies only to the current project — lives inside the repo | `.cursor/` | `.claude/` |

The rule of thumb: anything you'd want everywhere (your writing voice, your coding standards, your go-to skills) lives at user level. Anything specific to one project lives at project level. Org-level is for compliance, security policies, and company-wide standards.

This matters for migration. **User-level Cursor config should migrate to user-level Claude Code (`~/.claude/`), not into the project.** If you accidentally move a user-level skill into `.claude/skills/`, it'll only work in that one project.

---

## The Five Primitives

Both tools share the same five building blocks. Here's what each one does in plain terms, and whether your Cursor setup transfers.

---

### 1. Skills — Custom Workflows You've Packaged

**What they are:** Reusable instructions you've bundled under a name — like `/prd`, `/research`, or `/pr-faq`. You invoke them with a `/` command or a trigger phrase, and the AI follows the workflow inside. Both tools follow the [Agent Skills](https://agentskills.io) open standard.

**Verdict: Identical base format. Claude Code has more frontmatter options.**

Skills live in a `skills/` folder, either at user level or project level. Both tools read from the same locations — if you've built a skill in Cursor, it works in Claude Code without touching it. Claude Code extends the standard with additional frontmatter fields.

| | Cursor | Claude Code |
|---|---|---|
| Project-level skills | `.cursor/skills/[name]/SKILL.md` (also reads `.agents/skills/`, `.claude/skills/`, `.codex/skills/`) | `.claude/skills/[name]/SKILL.md` |
| User-level skills | `~/.cursor/skills/[name]/SKILL.md` (also reads `~/.claude/skills/`, `~/.codex/skills/`) | `~/.claude/skills/[name]/SKILL.md` |
| How you invoke them | `/skill-name` or trigger phrase | Same |
| Cross-tool compatibility | ✅ Cursor reads `.claude/skills/`, `.codex/skills/` too | ✅ Same |
| Disable auto-invocation | `disable-model-invocation: true` | Same |
| Hide from `/` menu | N/A | `user-invocable: false` (AI-only knowledge) |
| Restrict tool access | N/A | `allowed-tools: Read, Grep, Glob` |
| Run in isolated subagent | N/A | `context: fork` + optional `agent: Explore` |
| Override model | N/A | `model: sonnet` (or haiku, opus, inherit) |
| Override effort | N/A | `effort: high` (low/medium/high/max) |
| Dynamic context injection | N/A | `` !`command` `` syntax (shell runs before prompt) |
| Argument substitutions | Parameters after `/name` | `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_SESSION_ID}` |
| Skill-scoped hooks | N/A | `hooks:` frontmatter (runs while skill is active) |
| Remote import | GitHub repo URL via Settings > Rules > Add Rule | N/A (use install scripts or plugins) |
| Migration tool | `/migrate-to-skills` (Cursor 2.4+) | N/A |
| Supporting files | `scripts/`, `references/`, `assets/` subdirectories | Any files alongside SKILL.md |
| Context budget | N/A | Descriptions limited to 2% of context window (override: `SLASH_COMMAND_TOOL_CHAR_BUDGET`) |
| Extended thinking | N/A | Include "ultrathink" in skill content |

**Key takeaway:** A Cursor skill works in Claude Code as-is. Claude Code skills can use additional frontmatter that Cursor ignores — portable in one direction, extended in the other.

---

### 2. Standing Instructions — What the AI Always Knows

**What they are:** The persistent context you give the AI — your coding conventions, your team's terminology, what the project is for. The AI reads this at the start of every session.

**Verdict: Same concept, slightly different file names. Easy to maintain one set.**

In Cursor this is `.cursor/rules/*.mdc` or `AGENTS.md` (project) or User Rules in Cursor Settings (user). Legacy root `.cursorrules` still loads but is deprecated — migrate to `.cursor/rules/`. In Claude Code it's `CLAUDE.md` (project) or `~/.claude/CLAUDE.md` (user). Both serve the same purpose.

Both also support **scoped rules** — instructions that only activate for specific file types or folders.

| | Cursor | Claude Code |
|---|---|---|
| Project-level instructions | `.cursor/rules/*.mdc` or `AGENTS.md` (hierarchical, subdirectory-aware) | `CLAUDE.md` at project root or `.claude/CLAUDE.md` |
| User-level instructions | User Rules in Cursor Settings (UI) — not file-based | `~/.claude/CLAUDE.md` (file-based) |
| Org-level instructions | Team Rules via dashboard (Team/Enterprise). "Enforce" option = mandatory | Managed policy CLAUDE.md (IT-deployed, cannot be excluded via `claudeMdExcludes`) |
| Scoped rules — project | `.cursor/rules/*.mdc` with `globs:` frontmatter | `.claude/rules/*.md` with `paths:` frontmatter |
| Scoped rules — user | User Rules in Settings (no `~/.cursor/rules/`) | `~/.claude/rules/*.md` (file-based, lower priority than project rules) |
| Scope targeting syntax | `globs: ["**/*.tsx"]` | `paths: ["src/api/**/*.ts"]` |
| Application modes | Always Apply, Apply Intelligently, Apply to Specific Files, Apply Manually | Always loaded (CLAUDE.md), on file match (scoped rules with `paths:`), unconditional (rules without `paths:`) |
| Import other files | `@mention` external files in rule content | `@path/to/file` syntax in CLAUDE.md (expands at load, max 5 hops) |
| Remote rules | GitHub repo URL via Settings > Rules > Add Rule | N/A |
| Subdirectory loading | `AGENTS.md` in subdirectories (hierarchical, deeper = higher precedence) | Subdirectory `CLAUDE.md` files load on demand when AI reads files there |
| Directory tree loading | N/A | Walks **up** from CWD, loads each CLAUDE.md found |
| Target size | < 500 lines per rule | < 200 lines per CLAUDE.md for best adherence |
| Exclude irrelevant files | N/A | `claudeMdExcludes` glob patterns in settings (useful for monorepos) |

**For most Builders:** Keep project instructions in `CLAUDE.md` at the project root. Keep personal defaults in `~/.claude/CLAUDE.md`. Both tools will load both. For file-specific conventions, use `.claude/rules/` (with `paths:`) or `.cursor/rules/` (with `globs:`).

---

### 3. Slash Commands — Shortcuts You've Created

**What they are:** Custom `/` commands you've defined that trigger a specific prompt or workflow. Different from skills in that they're simpler — usually a single instruction rather than a full multi-step workflow. (Cursor 2.4+ includes `/migrate-to-skills` to convert commands to skills.)

**Verdict: Identical in Cursor. In Claude Code, commands are merged into skills.**

In Claude Code, `.claude/commands/` is an alias for `.claude/skills/` — both create `/` commands. Any file in `.claude/commands/deploy.md` behaves the same as `.claude/skills/deploy/SKILL.md`. Skills are preferred since they support additional features (supporting files, frontmatter). Your existing command files keep working.

| | Cursor | Claude Code |
|---|---|---|
| Project-level commands | `.cursor/commands/` | `.claude/commands/` (alias for skills) |
| User-level commands | `~/.cursor/commands/` | `~/.claude/commands/` (alias for skills) |
| How you invoke them | `/command-name` | `/command-name` |
| Format | Markdown `.md` file (no frontmatter) | Same (but frontmatter supported since they're skills) |
| Relationship to skills | Separate concept (simpler); `/migrate-to-skills` to convert | **Merged** — commands ARE skills. On naming conflict, skill wins. |

---

### 4. Hooks — Automatic Actions That Fire on Events

**What they are:** Rules that say "whenever X happens, automatically do Y." For example: "before any shell command runs, validate it" or "after a file edit, run the linter." These run automatically without you asking.

**Verdict: Different between the two tools. Config cannot be shared. Claude Code is significantly more capable.**

This is the one primitive that doesn't carry over. The two tools fire hooks on different events and use different config formats.

| | Cursor | Claude Code |
|---|---|---|
| Project-level config | `.cursor/hooks.json` | `.claude/settings.json` → `hooks` section |
| User-level config | `~/.cursor/hooks.json` | `~/.claude/settings.json` → `hooks` section |
| Enterprise config | macOS: `/Library/Application Support/Cursor/hooks.json`; Linux: `/etc/cursor/hooks.json` | Managed policy `managed-settings.json` (+ drop-in `managed-settings.d/`) |
| Hook types | 2: command, prompt (LLM-evaluated) | **4 types:** command, HTTP, prompt (LLM eval), agent (spawns subagent) |
| Hook events (agent) | `sessionStart`, `sessionEnd`, `beforeSubmitPrompt`, `preToolUse`, `postToolUse`, `postToolUseFailure`, `subagentStart`, `subagentStop`, `beforeShellExecution`, `afterShellExecution`, `beforeMCPExecution`, `afterMCPExecution`, `beforeReadFile`, `afterFileEdit`, `preCompact`, `stop`, `afterAgentResponse`, `afterAgentThought` | `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `StopFailure`, `SubagentStart`, `SubagentStop`, `SessionEnd`, `InstructionsLoaded`, `Notification`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `CwdChanged`, `FileChanged`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`, `WorktreeRemove` |
| Hook events (tab/inline) | `beforeTabFileRead`, `afterTabFileEdit` | N/A (CLI tool, no tab completions) |
| Can block actions | Yes (exit code 2) | Yes (exit code 2 = block) |
| Can modify tool input | N/A | Yes (`updatedInput` in PreToolUse) |
| Can auto-approve | N/A | Yes (`PermissionRequest` → `allow`) |
| Async/non-blocking | N/A | Yes (`"async": true`) |
| Scoped to skills/agents | N/A | Yes (frontmatter `hooks:` in skills and agents) |
| Prompt-type hooks | Yes (`"type": "prompt"`, `$ARGUMENTS`, optional `model`) | Yes (`"type": "prompt"`, `$ARGUMENTS`, optional `model`) |
| Matcher pattern | By tool type (`"Shell"`, `"Read"`, `"MCP:github"`) or regex | By tool name (regex, e.g. `"Bash"`, `"Edit|Write"`, `"mcp__memory__.*"`) |
| Loop control | `loop_limit` field (default 5, `null` = unlimited) | N/A |
| Fail behavior | `failClosed: true/false` (default: fail-open) | Exit code 2 = block; other codes = fail-open |
| Auto-reload | Yes (watches `hooks.json` on save) | Yes (settings file watch) |
| Partner integrations | MintMCP, Oasis, Runlayer, Corridor, Semgrep, Snyk, 1Password | N/A |
| Config shareable? | ❌ No | ❌ No |

**Builder bottom line:** Skip hooks until you have a specific repetitive background task that's slowing you down. When that day comes, set them up separately per tool. Both tools now support prompt-type hooks. Claude Code hooks are more capable overall — 4 hook types, more events, permission auto-approval, input modification, and async execution. Cursor hooks cover tab/inline completions that Claude Code (CLI) doesn't have.

---

### 5. Subagents — Specialized AI Roles You've Defined

**What they are:** Named AI "roles" you've created with specific instructions, tools, and sometimes a specific model. For example: a `code-reviewer` subagent that only has read access and focuses on critique, or a `doc-writer` subagent that's tuned for writing rather than coding.

**Verdict: Similar concept. Claude Code gives you significantly more control.**

Both tools support subagents. Claude Code provides many more configuration options for tool access, permissions, memory, isolation, and composability.

| | Cursor | Claude Code |
|---|---|---|
| Project-level agents | `.cursor/agents/` (also reads `.claude/agents/`, `.codex/agents/`) | `.claude/agents/` |
| User-level agents | `~/.cursor/agents/` (also reads `~/.claude/agents/`, `~/.codex/agents/`) | `~/.claude/agents/` |
| CLI-defined (session only) | N/A | `claude --agents '{...}'` (JSON, not saved to disk) |
| How you invoke them | `/agent-name`, mention naturally, or auto-delegation | `@agent-name`, mention naturally, `claude --agent name` (whole session), or auto-delegation |
| Tool access control | `readonly: true/false` (coarse) | `tools: Read, Grep, Bash` (allowlist) + `disallowedTools: Write` (denylist) |
| Subagent spawning control | Inherits all parent tools including MCP | `Agent(worker, researcher)` in tools allowlist. Omit `Agent` = no spawning |
| Model selection | `model: inherit | fast | model-id` | `model: sonnet | opus | haiku | inherit | model-id` (e.g., `claude-opus-4-6`) |
| Permission handling | N/A | `permissionMode: default | acceptEdits | dontAsk | bypassPermissions | plan` |
| Persistent memory | N/A | `memory: user | project | local` (cross-session knowledge at `~/.claude/agent-memory/` or `.claude/agent-memory/`) |
| Git worktree isolation | N/A | `isolation: worktree` (isolated repo copy, auto-cleaned if no changes) |
| Preload skills | N/A | `skills: [api-conventions, error-handling]` (full content injected at startup) |
| Scope MCP servers | Inherits all parent MCP servers | `mcpServers:` (inline definitions or reference existing) |
| Agent-scoped hooks | N/A | `hooks:` frontmatter (runs while agent is active) |
| Background execution | `is_background: true` | `background: true`. `Ctrl+B` to background a running task |
| Limit turns | N/A | `maxTurns: 10` |
| Initial prompt | N/A | `initialPrompt:` (auto-submitted first turn for `--agent` mode) |
| Resume after completion | `Resume agent [ID]` | `SendMessage` with agent ID |
| Built-in agents | Explore, Bash, Browser | Explore (haiku, read-only), Plan (inherit, read-only), general-purpose (inherit, all tools), Bash, statusline-setup, Claude Code Guide |
| Management command | N/A | `/agents` (interactive UI) or `claude agents` (CLI list) |
| Effort override | N/A | `effort: low | medium | high | max` |

**Builder use case:** If you've defined subagents in Cursor, you'll need to recreate them in Claude Code — but you also get the chance to make them more precise. A user-level `doc-writer` agent you use across all projects belongs in `~/.claude/agents/`. A project-specific `api-reviewer` agent belongs in `.claude/agents/` inside that repo.

---

## Summary: What Do You Actually Have to Rebuild?

| Primitive | Transfers? | Action needed |
|---|---|---|
| **Skills** | ✅ Yes | Mirror the level — user-level to `~/.claude/skills/`, project-level to `.claude/skills/`. Optionally add Claude Code-specific frontmatter (`context: fork`, `allowed-tools`, etc.) |
| **Slash Commands** | ✅ Yes | In Claude Code, commands are skills. `.claude/commands/` works as an alias. Consider migrating to `.claude/skills/` for full feature support. |
| **Standing Instructions** | ✅ Mostly | Project: `CLAUDE.md` at root (or `.claude/CLAUDE.md`). Scoped: `.claude/rules/` with `paths:` frontmatter. User: transcribe from Cursor Settings → `~/.claude/CLAUDE.md` |
| **Hooks** | ❌ No | Rebuild separately per tool (only if you use hooks). Both support prompt-type hooks now. Claude Code hooks are more capable overall. |
| **Subagents** | ⚠️ Partially | Recreate at the right level. Add Claude Code-specific features: explicit `tools:`, `memory:`, `permissionMode:`, etc. |

**The gaps that matter:** Hooks need separate configs. Cursor User Rules (in Settings) need manual export — they're not in a folder. Claude Code subagents and skills have many more configuration options worth using. Everything else is either identical or a small filename difference.

---

## Quick Feature Comparison

| Feature | Cursor | Claude Code |
|---|---|---|
| Skill frontmatter fields | ~5 (name, description, disable-model-invocation, license, compatibility, metadata) | ~12 (+ context, agent, allowed-tools, model, effort, hooks, user-invocable, argument-hint) |
| Subagent frontmatter fields | ~5 (name, description, model, readonly, is_background) | ~15 (+ tools, disallowedTools, permissionMode, memory, isolation, skills, mcpServers, hooks, maxTurns, effort, background, initialPrompt) |
| Hook types | 2 (command, prompt) | 4 (command, HTTP, prompt, agent) |
| Hook events (agent) | ~18 | ~24 |
| Hook events (tab/inline) | 2 | N/A (CLI tool) |
| Scoped rule syntax | `globs:` | `paths:` |
| User-level rules | UI only (Cursor Settings) | File-based (`~/.claude/rules/`) |
| Instruction imports | `@mention` files in rules | `@path/to/file` in CLAUDE.md (max 5 hops) |
| Org-wide instructions | Team Rules (dashboard, enforceable) | Managed policy CLAUDE.md + drop-in `managed-settings.d/` |
| Dynamic skill context | N/A | `` !`command` `` syntax |
| Skill arguments | After `/name` | `$ARGUMENTS`, `$N`, `${CLAUDE_SKILL_DIR}` |
| Remote skills/rules | GitHub repo URL import | Plugins system |
| Cross-tool reading | Reads `.claude/`, `.codex/` directories | Reads own `.claude/` only |
| Auto memory | N/A | `~/.claude/projects/<project>/memory/` (toggle: `/memory`) |
| Bundled skills | N/A | `/batch`, `/claude-api`, `/debug`, `/loop`, `/simplify` |
| Settings schema | N/A | `"$schema": "https://json.schemastore.org/claude-code-settings.json"` |

---

## Troubleshooting

Common issues when setting up or migrating primitives between the two tools.

### Skills

| Symptom | Cause | Fix |
|---------|-------|-----|
| Skill doesn't auto-trigger | `description` keywords don't match natural language | Rewrite description with the phrases users would actually say. Test with "What skills are available?" |
| Skill triggers too often | Description too broad | Make description more specific, or add `disable-model-invocation: true` |
| Skill missing from `/` menu | Too many skills exceed context budget (2% of window) | Run `/context` to check warnings. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Or set `user-invocable: false` on background-only skills |
| `context: fork` returns nothing | Skill has guidelines but no actionable task | Only use `context: fork` with explicit task instructions, not reference-only content |
| Skill works in Cursor but not Claude Code | Different folder paths | Cursor reads `.claude/skills/`; Claude Code reads only `.claude/skills/`. Ensure files are in the right location |
| `name` mismatch in Cursor | Folder name doesn't match frontmatter `name` | In Cursor, `name` must match parent folder name exactly |

### Standing Instructions

| Symptom | Cause | Fix |
|---------|-------|-----|
| CLAUDE.md instructions ignored | File too long (reduced adherence) | Keep under 200 lines. Move details to `.claude/rules/` files |
| Scoped rule never loads | Wrong syntax for tool | Cursor uses `globs:`, Claude Code uses `paths:`. They're not interchangeable |
| Instructions vanish after `/compact` | Instructions were given in conversation, not CLAUDE.md | CLAUDE.md survives compaction. Conversation-only instructions don't. Move persistent instructions to CLAUDE.md |
| Cursor "Apply Intelligently" does nothing | Missing `description` field | Required for agent-decided application. Add it. |
| Two CLAUDE.md files conflict | Multiple files in directory hierarchy | Claude Code loads all CLAUDE.md files walking up from CWD. Resolve conflicts or use `claudeMdExcludes` |
| `@import` not expanding | Import depth exceeded or approval not granted | Max 5 hops. First encounter triggers approval dialog. Check nested depth. |

### Hooks

| Symptom | Cause | Fix |
|---------|-------|-----|
| Hook not running | Matcher regex doesn't match actual tool/event names | Check exact tool names: Cursor uses `"Shell"`, `"Read"`, `"MCP:github"`; Claude Code uses `"Bash"`, `"Edit|Write"`, `"mcp__server__tool"` |
| JSON parse error from hook | Script prints non-JSON to stdout (e.g., shell profile banners) | Ensure hook script outputs only JSON. Suppress shell profile output |
| Hook blocks unexpectedly | Exit code 2 returned | Exit code 2 = deny/block. Use exit code 0 for success, non-zero (non-2) for non-blocking warning |
| Cursor project hooks don't run | Workspace not trusted | Trust the workspace in Cursor settings |
| Claude Code hooks silently ignored | Wrong settings file location | Hooks go in `settings.json` (under `"hooks"` key), not a separate `hooks.json` file |
| HTTP hook doesn't fire | URL not in allowlist | Add URL to `allowedHttpHookUrls` in settings |
| `preCompact` hook can't prevent compaction | By design | `preCompact` is observational only in both tools — cannot block |

### Subagents

| Symptom | Cause | Fix |
|---------|-------|-----|
| Subagent can't spawn other subagents | Single-level nesting limit | Both tools: subagents cannot spawn nested subagents. Redesign workflow |
| Subagent ignores `permissionMode` | Parent is in `bypassPermissions` or auto mode | Parent mode overrides subagent frontmatter. This is by design |
| New agent file not recognized | Session doesn't hot-reload agents | Restart session or run `/agents` in Claude Code |
| Cursor overrides agent `model` | Admin block, Max Mode required, or plan restriction | Check team admin settings, plan tier, and Max Mode availability |
| Token usage unexpectedly high | Multiple parallel subagents | 5 parallel subagents ≈ 5x token usage. Use sequentially for cost control |
| Agent memory not persisting | `memory` field not set or wrong scope | Add `memory: project` (shared via VCS) or `memory: local` (gitignored) or `memory: user` (cross-project) |
| Plugin subagent fields silently ignored | `hooks`, `mcpServers`, `permissionMode` not supported for plugins | These fields only work for project/user-level agents, not plugin agents |

### Migration

| Symptom | Cause | Fix |
|---------|-------|-----|
| User-level skill only works in one project | Accidentally placed in `.claude/skills/` instead of `~/.claude/skills/` | Move to user-level directory |
| Cursor User Rules missing after migration | Rules live in Cursor Settings UI, not files | Manually export/transcribe to `~/.claude/CLAUDE.md` |
| `globs:` rules don't work in Claude Code | Wrong frontmatter key | Claude Code uses `paths:`, not `globs:`. Convert syntax |
| Legacy `.cursorrules` at repo root | Deprecated in favor of `.cursor/rules/*.mdc` | Move content into `.cursor/rules/` with frontmatter (`alwaysApply`, `description`, `globs`). Remove `.cursorrules` when done |

---

## Ready to Migrate? Use This Prompt in Cursor

Open Cursor in your project and paste this prompt. It will audit your existing Cursor setup — at both user and project level — and create everything Claude Code needs at the right destination.

```
Look at my Cursor configuration at two levels:
- Project-level: .cursor/ in this repo
- User-level: ~/.cursor/ on this machine

Audit all five primitives — skills, commands, standing instructions, subagents, and hooks — at both levels. Then make everything compatible with Claude Code, following these rules:

IMPORTANT: Mirror the level. User-level Cursor config migrates to ~/.claude/. Project-level Cursor config migrates to .claude/ in this repo. Never promote a user-level config into the project, or demote a project-level config to user level.

1. SKILLS
   - Project: copy anything in .cursor/skills/ to .claude/skills/ (same structure, same filenames)
   - User: copy anything in ~/.cursor/skills/ to ~/.claude/skills/
   - Skills are identical across both tools — straight copy, no changes needed
   - OPTIONAL: Add Claude Code-specific frontmatter (context: fork, allowed-tools, model) where it adds value

2. COMMANDS
   - Project: copy .cursor/commands/ to .claude/commands/ (or .claude/skills/ — commands are skills in Claude Code)
   - User: copy ~/.cursor/commands/ to ~/.claude/commands/
   - Consider migrating to .claude/skills/ for full feature support (frontmatter, supporting files)

3. STANDING INSTRUCTIONS
   - Project: read `.cursor/rules/*.mdc`, AGENTS.md, and legacy `.cursorrules` if present. If CLAUDE.md doesn't exist in the project root, create it with the merged content. If it does exist, compare and merge anything missing. For file-scoped rules with globs:, create matching .claude/rules/ files with paths: frontmatter.
   - User: Cursor User Rules live in Cursor Settings (UI), not in a folder. Export or transcribe them manually. If ~/.claude/CLAUDE.md doesn't exist, create it. If it does, merge in anything missing. Target < 200 lines.

4. SUBAGENTS
   - Project: for each agent in .cursor/agents/, create a matching agent in .claude/agents/ with the same role and instructions. Explicitly declare which tools it gets with tools: field (conservative defaults — read-only unless the agent clearly needs to write or run commands). Set the model field appropriately (haiku for speed, sonnet for capability, inherit for consistency). Consider adding memory: project for persistent cross-session knowledge.
   - User: same process for ~/.cursor/agents/ → ~/.claude/agents/

5. HOOKS
   - Check .cursor/hooks.json (project) and ~/.cursor/hooks.json (user)
   - Do NOT create Claude Code hook configs automatically
   - For any hooks you find, list: what it does in plain English, whether it's project-specific or a personal default, and whether it's worth recreating for Claude Code
   - Note: Claude Code supports 4 hook types (command, HTTP, prompt, agent) and 24+ lifecycle events — some hooks may be more powerful when recreated
   - Note: Cursor uses "Shell"/"Read"/"MCP:name" tool names in matchers; Claude Code uses "Bash"/"Edit|Write"/"mcp__server__tool"

When done, give me a summary: what was created at user level, what was created at project level, what was skipped, and anything I should review manually.
```

**Why this works:** The prompt checks both levels, keeps hooks as a "summarize first, don't act" step, and accounts for both tools' expanded feature sets (tool restrictions, persistent memory, scoped rules, prompt-type hooks, and different matcher syntax).

---

**Freshness:** 2026-03-25. Re-check: https://code.claude.com/docs/en/skills, https://code.claude.com/docs/en/sub-agents, https://code.claude.com/docs/en/hooks, https://code.claude.com/docs/en/memory, https://cursor.com/docs/skills, https://cursor.com/docs/subagents, https://cursor.com/docs/rules, https://cursor.com/docs/hooks
