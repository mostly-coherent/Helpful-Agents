# Context Engineer — Reference

Detailed comparison tables, cross-tool mapping, examples, anti-patterns, and creation templates. Supplements SKILL.md.

---

## Cross-Tool Primitive Mapping

Both Claude Code and Cursor share the same five building blocks. Here's how they map.

| Primitive | Claude Code | Cursor | Portable? |
|-----------|-------------|--------|-----------|
| **Standing instructions** | `CLAUDE.md` (project root or `.claude/CLAUDE.md`) + `~/.claude/CLAUDE.md` (user) | `.cursor/rules/*.mdc` (project) + User Rules in Settings (user) | Content is portable; file format differs |
| **Scoped rules** | `.claude/rules/*.md` with `paths:` YAML frontmatter | `.cursor/rules/*.mdc` with `globs:` YAML frontmatter | Same concept, different frontmatter field names |
| **Skills** | `.claude/skills/name/SKILL.md` | `.cursor/skills/name/SKILL.md` | **Yes — Agent Skills standard** (both tools read each other's skills folders) |
| **Commands** | Merged into skills (`.claude/commands/` still works as alias) | `.cursor/commands/name.md` | Format identical; Claude Code treats them as skills |
| **Subagents** | `.claude/agents/name.md` | `.cursor/agents/name.md` | Similar format; Claude Code has more config options |
| **Hooks** | `.claude/settings.json` → `hooks` section (4 types: command, HTTP, prompt, agent; 24+ events) | `.cursor/hooks.json` (2 types: command, prompt; 18+ agent events + 2 tab events) | **Not portable — different formats, different events, different matcher syntax** |

### Key Differences

| Feature | Claude Code | Cursor |
|---------|-------------|--------|
| **User-level rules** | `~/.claude/rules/*.md` (file-based) | Cursor Settings UI (not file-based) |
| **Scoped rule targeting** | `paths:` frontmatter (glob patterns) | `globs:` frontmatter (glob patterns) |
| **Skills = commands** | Yes — `.claude/commands/` is an alias for skills | No — commands and skills are separate |
| **Skill frontmatter** | `context: fork`, `agent:`, `allowed-tools:`, `model:`, `effort:`, `hooks:`, `user-invocable:` | `disable-model-invocation:` (fewer options) |
| **Subagent features** | `tools:`, `disallowedTools:`, `permissionMode:`, `memory:`, `background:`, `isolation: worktree`, `skills:`, `hooks:`, `mcpServers:` | `model:`, `readonly:`, `is_background:` |
| **Hook types** | command, HTTP, prompt, agent | command only |
| **Hook events** | SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, StopFailure, SubagentStart, SubagentStop, SessionEnd, InstructionsLoaded | beforeShell, afterShell, beforeMCP, afterMCP, beforeReadFile, afterFileEdit, afterTabFileEdit, sessionStart, sessionEnd |
| **Dynamic context in skills** | `` !`command` `` syntax (runs shell before sending to AI) | Not supported |
| **Skill arguments** | `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_SESSION_ID}` | Parameters passed after `/name` |
| **CLAUDE.md imports** | `@path/to/file` syntax in CLAUDE.md | Not supported (use @-mention instead) |
| **Org-wide instructions** | Managed policy CLAUDE.md (IT-deployed) | Team Rules (dashboard) |

---

## Complete Comparison Table

| Feature | Standing Instructions | Scoped Rules | Skills | Subagents | Hooks | .md + @-mention |
|---------|----------------------|--------------|--------|-----------|-------|-----------------|
| **Invocation** | Auto (every session) | Auto (matching files) | Auto or `/name` | Auto or explicit | Auto (lifecycle events) | Manual `@file` |
| **Context window** | Main | Main | Main (or fork) | Separate | N/A (runs scripts) | Main |
| **Version control** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Portable across tools** | Content yes, format varies | Concept yes, syntax varies | **Yes (Agent Skills)** | Partially | **No** | Yes |
| **Can include scripts** | No | No | Yes (`scripts/`) | No | Yes (runs scripts) | No |
| **Progressive loading** | No | Yes (on file match) | Yes (`references/`) | N/A | N/A | No |
| **Model selection** | Inherits | Inherits | Configurable (CC) | Configurable | N/A | Inherits |
| **Background execution** | No | No | Yes (with `context: fork`) | Yes | Yes (async hooks) | No |
| **File pattern matching** | No | Yes | No | No | Yes (matcher) | No |
| **Can block actions** | No | No | No | No | **Yes** | No |
| **Can modify tool input** | No | No | No | No | **Yes** (CC only) | No |
| **Best for** | Global standards | File-specific standards | Workflows & knowledge | Complex isolated tasks | Automation & enforcement | Ad-hoc reference |

---

## When to Use What — Detailed

### Standing Instructions (CLAUDE.md / Rules)

**Use when:**
- Coding conventions that should apply to every conversation
- Project architecture context the AI always needs
- Team terminology and domain knowledge
- Build/test commands the AI should know

**Don't use when:**
- Temporary context for one task (use @-mention instead)
- Complex multi-step workflows (use skill)
- Content that needs to run scripts (use skill or hook)

**Claude Code specifics:**
- `CLAUDE.md` at project root (or `.claude/CLAUDE.md`) — shared with team via git
- `~/.claude/CLAUDE.md` — personal preferences across all projects
- Can import files with `@path/to/file` syntax
- Target < 200 lines for best adherence
- Subdirectory CLAUDE.md files load on demand when AI reads files there

**Cursor specifics:**
- `.cursor/rules/*.mdc` with frontmatter — project rules
- User Rules in Cursor Settings (UI) — personal, not file-based
- Team Rules via dashboard (Team/Enterprise plans)
- `alwaysApply: true` = every session; `false` = AI decides based on description

### Scoped Rules

**Use when:**
- Different standards for different file types (TypeScript vs Python)
- Backend vs frontend conventions in monorepos
- Test-specific guidelines that shouldn't apply to production code

**Claude Code:** `.claude/rules/*.md` with `paths:` frontmatter
```yaml
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---

# API Development Rules
- All API endpoints must include input validation...
```

**Cursor:** `.cursor/rules/*.mdc` with `globs:` frontmatter
```yaml
---
description: "TypeScript API conventions"
alwaysApply: false
globs: ["src/api/**/*.ts"]
---
```

### Skills

**Use when:**
- Domain-specific workflow the AI should auto-apply or user invokes with `/name`
- Multi-step process with supporting files (scripts, templates, examples)
- Reusable across projects (Agent Skills standard)
- Need progressive loading (detailed docs loaded on demand)

**Don't use when:**
- Simple one-liner convention (use standing instruction)
- Need to block or modify agent actions (use hook)
- Need full context isolation (use subagent, or skill with `context: fork`)

**Claude Code features not in Cursor:**
- `context: fork` — run skill in isolated subagent
- `agent: Explore` — pick which subagent type executes it
- `allowed-tools: Read, Grep` — restrict tool access during skill
- `model: haiku` — model override
- `effort: high` — effort level override
- `` !`command` `` — dynamic context injection (shell runs before prompt)
- `$ARGUMENTS[N]`, `${CLAUDE_SKILL_DIR}` — string substitutions
- `hooks:` — skill-scoped hooks
- `user-invocable: false` — hide from `/` menu (AI-only knowledge)

### Subagents

**Use when:**
- Task produces verbose output that would bloat main conversation
- Need context isolation for independent verification
- Want parallel execution with different model/tools
- Specialized expertise across many steps

**Don't use when:**
- Simple, single-purpose task (use skill or command)
- Need frequent back-and-forth with user (stay in main conversation)
- Quick question (use `/btw` in Claude Code)

**Claude Code features not in Cursor:**
- `tools:` / `disallowedTools:` — explicit tool control
- `permissionMode:` — permission handling (default, acceptEdits, dontAsk, bypassPermissions, plan)
- `memory: project` — persistent cross-session knowledge
- `isolation: worktree` — git worktree isolation
- `skills:` — preload skills into subagent context
- `mcpServers:` — scope MCP servers to subagent
- `hooks:` — agent-scoped hooks
- `background: true` — non-blocking execution
- `maxTurns:` — limit agentic turns
- Resume with `SendMessage` using agent ID

### Hooks

**Use when:**
- Gate risky operations (block `rm -rf`, validate SQL)
- Scan for secrets/PII before content reaches the model
- Run formatters/linters after file edits
- Audit or log agent actions
- Auto-approve safe operations
- Inject dynamic context at session start

**Don't use when:**
- Providing guidance or knowledge to AI (use rules/skills)
- Defining a workflow for AI to follow (use skill)

**Context-engineer advises on hooks but does not create hook configs.** Point to docs and explain which hook type fits.

**Claude Code hook types:**
| Type | What it does |
|------|-------------|
| `command` | Runs a shell script |
| `http` | Sends JSON to a remote endpoint |
| `prompt` | Single-turn LLM evaluation |
| `agent` | Spawns a subagent for verification |

**Claude Code hook events:**
SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Stop, StopFailure, SubagentStart, SubagentStop, SessionEnd, InstructionsLoaded

**Cursor hook events:**
beforeShell, afterShell, beforeMCP, afterMCP, beforeReadFile, afterFileEdit, afterTabFileEdit, sessionStart, sessionEnd

---

## Anti-Patterns

### Subagent for a simple task
```yaml
---
name: format-imports
description: Formats import statements
---
Sort imports alphabetically.
```
**Why bad:** Single-purpose task doesn't need context isolation. Use a skill or command.

### Standing instruction for temporary context
```yaml
---
alwaysApply: true
---
Context for the feature X we're building this week...
```
**Why bad:** Temporary context shouldn't load every session. Use @-mention or a skill.

### Skill with `disable-model-invocation` that has no workflow
```yaml
---
name: quick-tip
disable-model-invocation: true
---
Remember to use TypeScript strict mode.
```
**Why bad:** This is a convention, not a workflow. Use a standing instruction or scoped rule.

### Overly long SKILL.md (800+ lines)
**Why bad:** Consumes excessive context. Move detailed content to `references/REFERENCE.md`.

### Dozens of generic skills with vague descriptions
**Why bad:** Descriptions compete for context budget. AI can't distinguish between them. Start with 2-3 focused skills; expand gradually.

### Hook config for something rules handle
**Why bad:** If you just want the AI to "always do X," a standing instruction is simpler. Hooks are for programmatic enforcement, not guidance.

### Copying entire style guides into rules
**Why bad:** Linters handle style enforcement better. Rules should provide judgment calls and patterns that linters can't check.

---

## When to Upgrade

| From | To | Signal |
|------|-----|--------|
| @-mention .md | Standing instruction or scoped rule | You @-mention it every session |
| Standing instruction | Scoped rule | Only relevant to specific file types |
| Command (Cursor) | Skill | Need scripts, templates, or progressive loading |
| Skill | Skill with `context: fork` | Task generates verbose intermediate output |
| Skill | Subagent | Need persistent memory, different model, or tool restrictions |
| Project rule | Managed/Team rule | Need to enforce across entire organization |

---

## Validation Checklists

### Standing Instructions
- [ ] Under 200 lines (Claude Code) or 500 lines (Cursor rules)
- [ ] Specific and actionable (not "use best practices")
- [ ] No conflicts with other instruction files
- [ ] At the right level (project vs user)
- [ ] References files with @path (Claude Code) or @filename (Cursor) — doesn't copy contents

### Skills
- [ ] SKILL.md under 500 lines
- [ ] Name: lowercase, hyphens, max 64 chars, descriptive
- [ ] Description: third person, specific, includes trigger terms
- [ ] Single, clear responsibility
- [ ] Supporting files in references/, scripts/, or assets/
- [ ] Scripts use Unix paths
- [ ] If both tools: skill directory exists in both `.claude/skills/` and `.cursor/skills/`

### Subagents
- [ ] Name and description present
- [ ] Description explains when to delegate (include "use proactively" for auto-delegation)
- [ ] Prompt is concise (not 2000+ words)
- [ ] Tool access explicitly declared (don't inherit all if not needed)
- [ ] Model choice appropriate (haiku for speed, sonnet for capability, inherit for consistency)
- [ ] Task genuinely needs context isolation

### Hooks
- [ ] Need is programmatic control, not guidance (guidance = use rules/skills)
- [ ] Correct lifecycle event identified
- [ ] Exit code semantics understood (exit 2 = block in Claude Code)
- [ ] Matcher pattern targets the right tools
- [ ] Config goes in the right tool's format

---

## Troubleshooting

### "My rule/instruction isn't being followed"

**Claude Code:**
1. Run `/memory` — verify your CLAUDE.md or rule files are listed as loaded
2. Check location: is the file in the right place for its scope? (project root, `.claude/rules/`, `~/.claude/`)
3. Check for conflicts: do two instruction files give contradictory guidance?
4. Check length: CLAUDE.md files > 200 lines reduce adherence
5. Make instructions more specific: "Use 2-space indentation" beats "format code nicely"

**Cursor:**
1. Is the rule set to "Apply Intelligently"? Check that the description is specific enough
2. For file-scoped rules, verify the `globs:` pattern actually matches your files
3. For manual rules, are you @-mentioning it in chat?

### "My skill never gets triggered"

**Fix the description** — it's the #1 cause:
- Include trigger terms: "Use when working with PDFs, forms, or document extraction"
- Be specific: "Extract text and tables from PDF files"
- Avoid vague: "Helps with documents"

**Claude Code:** Check context budget — run `/context` to see if skills were excluded. Budget is 2% of context window (fallback 16,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

### "My subagent is slow or expensive"

1. Is this really complex enough for a subagent? Simple tasks run faster in the main conversation
2. Use `model: haiku` (Claude Code) or `model: fast` (Cursor) for speed
3. Check if a skill with `context: fork` would work instead (lighter than a full subagent)
4. Restrict tools with `tools:` or `disallowedTools:` to reduce unnecessary actions

### "I have too many rules/skills and they compete"

1. Merge related rules into one comprehensive rule
2. Delete rarely-used ones (check `/memory` or `/context` for what's loaded)
3. Make descriptions more specific so the AI can distinguish between them
4. Consider: should some be scoped rules instead of always-on?

---

## Example Sessions

### Example 1: "I want the AI to always follow our API conventions"

**Discovery:** Applies always, project-level, simple conventions, both tools.

**Recommendation:** Standing instructions.
- Claude Code: Add to `.claude/rules/api-conventions.md` with `paths: ["src/api/**"]`
- Cursor: Add to `.cursor/rules/api-conventions.mdc` with `globs: ["src/api/**"]`

### Example 2: "I need a reusable PR review workflow"

**Discovery:** Multi-step, user-invoked, both tools, needs scripts.

**Recommendation:** Skill with `disable-model-invocation: true`.

Create at `.claude/skills/review-pr/SKILL.md` (and mirror to `.cursor/skills/`):
```yaml
---
name: review-pr
description: Review pull requests for quality, security, and conventions
disable-model-invocation: true
---
```

### Example 3: "I want to block dangerous shell commands"

**Discovery:** Programmatic control, needs to block actions.

**Recommendation:** Hooks. Advise only — point to docs.
- Claude Code: `PreToolUse` hook with `matcher: "Bash"` in `.claude/settings.json`
- Cursor: `beforeShell` hook in `.cursor/hooks.json`

### Example 4: "I need a security auditor that reviews code independently"

**Discovery:** Needs context isolation, read-only, specialized expertise.

**Recommendation:** Subagent.

Claude Code (`.claude/agents/security-auditor.md`):
```yaml
---
name: security-auditor
description: Security specialist for reviewing auth, payments, and sensitive data. Use proactively after code changes touching authentication or payments.
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
---
```

Cursor (`.cursor/agents/security-auditor.md`):
```yaml
---
name: security-auditor
description: Security specialist for reviewing auth, payments, and sensitive data. Use when implementing authentication, processing payments, or handling PII.
model: fast
readonly: true
---
```

---

## Agent Skills Standard

Skills follow the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools. A skill created for Claude Code works in Cursor and vice versa (with tool-specific frontmatter features being optional extensions).

**Standard structure:**
```
skill-name/
├── SKILL.md           # Required: main instructions + YAML frontmatter
├── references/        # Optional: detailed docs (loaded on demand)
├── scripts/           # Optional: executable code
└── assets/            # Optional: templates, configs
```

**Discovery paths (both tools check all of these):**
- `.cursor/skills/`, `.claude/skills/`, `.codex/skills/`, `.agents/skills/`
- `~/.cursor/skills/`, `~/.claude/skills/`

---

## Additional Resources

- Claude Code docs index: https://code.claude.com/docs/llms.txt
- Cursor docs: https://cursor.com/docs
- Agent Skills standard: https://agentskills.io
- Cross-tool mapping: See `Cursor-vs-ClaudeCode_Config-Primitives.md` in Helpful Agents repo
