---
name: context-engineer
description: Creates the right AI context primitives (rules, skills, agents, hooks) by referencing the latest official guidance from Claude Code and Cursor. Use when the user asks "should I create a rule or skill?", mentions context engineering, wants to give persistent instructions to AI, asks about rules/skills/agents/hooks/CLAUDE.md, or needs to structure multi-step workflows for AI tools.
---

# Context Engineer

Creates the right AI context primitives — rules, skills, subagents, hooks, or standing instructions — so you can focus on your use case instead of figuring out which primitive to use. Always references the latest official docs from Claude Code and Cursor before creating anything.

## When to Use

- User asks "Should I create a rule, skill, or hook?"
- User wants to give persistent instructions to AI but isn't sure how
- User asks about differences between context methods
- User needs to structure a multi-step workflow for an AI tool
- User mentions context engineering, CLAUDE.md, rules, skills, agents, or hooks

## Phase 0: Fetch Latest Guidance (MANDATORY)

**Before recommending or creating anything, fetch current docs.** Primitives evolve — stale advice creates broken configs.

Use WebFetch to pull the relevant docs based on the user's tool:

**Claude Code:**
- Skills: https://code.claude.com/docs/en/skills
- Memory & CLAUDE.md: https://code.claude.com/docs/en/memory
- Subagents: https://code.claude.com/docs/en/sub-agents
- Hooks: https://code.claude.com/docs/en/hooks
- Settings & Permissions: https://code.claude.com/docs/en/settings

**Cursor:**
- Rules: https://cursor.com/docs/context/rules
- Skills: https://cursor.com/docs/context/skills
- Commands: https://cursor.com/docs/context/commands
- Subagents: https://cursor.com/docs/context/subagents
- Hooks: https://cursor.com/docs/agent/hooks

**If WebFetch is unavailable**, fall back to the embedded guidance in [REFERENCE.md](REFERENCE.md), but warn the user it may be slightly behind the latest docs.

## Phase 1: Discover the Need

Ask these questions (one at a time, conversationally):

1. **Which tool?** Cursor, Claude Code, or both?
2. **What's the goal?**
   - Enforce coding standards/conventions
   - Execute a quick, repeatable action
   - Teach domain knowledge or workflows
   - Handle complex, multi-step workflows with context isolation
   - Provide reference documentation
   - Gate, audit, or automate around agent actions
3. **When should it apply?**
   - Always (every conversation)
   - Intelligently (AI decides based on relevance)
   - On specific file types/paths
   - On explicit invocation only (`/name`)
   - As a specialized, isolated role
4. **Scope?** This project only, all projects (user-level), or team-wide?
5. **Complexity?** Simple instruction, needs examples, needs scripts, or multi-step with isolation?

## Phase 2: Apply Decision Logic

### First: Check for Hooks

If the need involves **programmatic control around the agent loop** — gating shell/MCP calls, scanning for secrets, running formatters after edits, auditing actions, auto-approving safe operations, or injecting dynamic context — recommend **Hooks**.

Context-engineer advises on hooks but does **not** create hook configs. Point to the relevant docs and explain the hook type (command, HTTP, prompt, or agent for Claude Code; command-based for Cursor).

### Then: Apply the Decision Tree

| If the need is... | Recommend | Why |
|---|---|---|
| Standards/conventions, always enforced | **Standing instructions** (CLAUDE.md / `.claude/rules/` or `.cursor/rules/`) | Loaded every session, no invocation needed |
| Standards scoped to file types | **Scoped rules** (`.claude/rules/` with `paths:` frontmatter or `.cursor/rules/` with `globs:`) | Only loads when AI works with matching files |
| Quick, single-purpose action on demand | **Skill** with `disable-model-invocation: true` (Claude Code) or **Command** (Cursor) | User controls when it runs |
| Domain knowledge the AI should auto-apply | **Skill** (both tools) | AI loads it when relevant based on description |
| Multi-step workflow with scripts/templates | **Skill** with supporting files | Progressive loading, scripts/, references/ |
| Complex task needing context isolation | **Subagent** (both tools) or **Skill with `context: fork`** (Claude Code) | Separate context window, preserves main conversation |
| Manual reference, occasional use | **.md file + @-mention** | No automation overhead |

### Cross-Tool Mapping

See [REFERENCE.md](REFERENCE.md) for the complete cross-tool primitive mapping.

## Phase 3: Recommend and Confirm

Provide:
1. **Primary recommendation** with reasoning
2. **Alternative approaches** if applicable
3. **Trade-offs** (context cost, maintenance, portability)
4. **Which tool(s)** the primitive works with

Confirm with the user before creating. Gather:
- **Name**: lowercase, hyphens, max 64 chars, descriptive
- **Description/content**: what it should do
- **Location**: project-level or user-level
- **Tool target**: Claude Code, Cursor, or both

## Phase 4: Create

**After user confirms, create the primitive immediately.** Don't just give instructions — build the files.

### Creation Checklist (all types)

- [ ] Fetch latest docs (Phase 0) if not already done
- [ ] Correct directory and file structure for the target tool
- [ ] Naming conventions followed
- [ ] Content under 500 lines (split to references/ if needed)
- [ ] Description is specific with trigger terms (for skills/agents)
- [ ] No anti-patterns present (see REFERENCE.md)
- [ ] If converting from @-mention .md, delete the original

### Tool-Specific Paths

| Primitive | Claude Code (project) | Claude Code (user) | Cursor (project) | Cursor (user) |
|---|---|---|---|---|
| **Standing instructions** | `CLAUDE.md` or `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | `.cursor/rules/*.mdc` | Cursor Settings (UI) |
| **Scoped rules** | `.claude/rules/*.md` (with `paths:` frontmatter) | `~/.claude/rules/*.md` | `.cursor/rules/*.mdc` (with `globs:`) | N/A |
| **Skills** | `.claude/skills/name/SKILL.md` | `~/.claude/skills/name/SKILL.md` | `.cursor/skills/name/SKILL.md` | `~/.cursor/skills/name/SKILL.md` |
| **Subagents** | `.claude/agents/name.md` | `~/.claude/agents/name.md` | `.cursor/agents/name.md` | `~/.cursor/agents/name.md` |
| **Hooks** | `.claude/settings.json` (hooks section) | `~/.claude/settings.json` | `.cursor/hooks.json` | `~/.cursor/hooks.json` |

### Frontmatter Quick Reference

**Claude Code Skills:**
```yaml
---
name: skill-name
description: What it does and when to use it
disable-model-invocation: true  # optional: user-only invocation
user-invocable: false            # optional: AI-only (background knowledge)
allowed-tools: Read, Grep, Glob  # optional: restrict tool access
context: fork                    # optional: run in subagent
agent: Explore                   # optional: which subagent type (with context: fork)
model: sonnet                    # optional: model override
effort: high                     # optional: effort level
hooks:                           # optional: skill-scoped hooks
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/lint.sh"
---
```

**Claude Code Subagents:**
```yaml
---
name: agent-name
description: When to delegate to this agent
tools: Read, Grep, Glob, Bash    # optional: restrict tools
disallowedTools: Write, Edit     # optional: deny specific tools
model: haiku                     # optional: model (sonnet/opus/haiku/inherit)
permissionMode: dontAsk          # optional: permission handling
memory: project                  # optional: persistent memory (user/project/local)
background: true                 # optional: non-blocking execution
isolation: worktree              # optional: git worktree isolation
skills:                          # optional: preload skills
  - api-conventions
hooks:                           # optional: agent-scoped hooks
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./validate.sh"
---
```

**Cursor Rules:**
```yaml
---
description: "Clear description for intelligent application"
alwaysApply: false
globs: ["**/*.tsx", "**/*.ts"]  # optional: file pattern matching
---
```

**Cursor Skills:** Same as Claude Code (Agent Skills standard).

**Cursor Subagents:**
```yaml
---
name: agent-name
description: When to use this agent
model: inherit  # inherit | fast | specific-model-id
readonly: false
is_background: false
---
```

## Phase 5: Verify

After creating:
1. Confirm files exist at the right paths
2. Run validation checklist from REFERENCE.md
3. Show the user what was created and how to invoke it
4. Suggest next steps (test it, version control it, share with team)

## Quick Decision Matrix

| Need | Use This | Works In |
|------|----------|----------|
| Gate/audit/automate agent actions | **Hooks** (advise only) | Both (different configs) |
| Always-on coding standards | **Standing instructions** (CLAUDE.md / rules) | Both |
| File-type-specific standards | **Scoped rules** | Both |
| Quick action, user-triggered | **Skill** (`disable-model-invocation`) or **Command** | Both |
| Domain knowledge, AI auto-applies | **Skill** | Both (Agent Skills standard) |
| Workflow with scripts/templates | **Skill** with supporting files | Both |
| Complex task, context isolation | **Subagent** or **Skill** (`context: fork`) | Both |
| Ad-hoc reference, manual only | **.md file + @-mention** | Both |

## Official Documentation

Always check before creating. Primitives evolve.

| Topic | Claude Code | Cursor |
|-------|-------------|--------|
| Skills | https://code.claude.com/docs/en/skills | https://cursor.com/docs/context/skills |
| Standing Instructions | https://code.claude.com/docs/en/memory | https://cursor.com/docs/context/rules |
| Subagents | https://code.claude.com/docs/en/sub-agents | https://cursor.com/docs/context/subagents |
| Hooks | https://code.claude.com/docs/en/hooks | https://cursor.com/docs/agent/hooks |
| Commands | (merged into skills) | https://cursor.com/docs/context/commands |
| Agent Skills Standard | https://agentskills.io | https://agentskills.io |

For detailed comparison tables, examples, anti-patterns, and creation templates, see [REFERENCE.md](REFERENCE.md).
