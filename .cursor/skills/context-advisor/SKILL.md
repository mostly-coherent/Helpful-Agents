---
name: context-advisor
description: Helps decide whether to use rules, commands, skills, subagents, or .md files for providing context to Cursor AI. Use when the user asks about the best way to provide context, mentions rules/commands/skills/subagents, or is unsure how to structure AI guidance.
---

# Context Advisor

Helps you choose the optimal context method for your needs in Cursor. Analyzes requirements and recommends whether to use rules, commands, skills, subagents, or simple .md files.

## When to Use This Skill

Use this skill when:
- User asks "Should I create a rule, command, or skill?"
- User mentions wanting to provide context but is unsure of the method
- User asks about differences between context methods
- User needs guidance on structuring AI instructions

## Decision Framework

### Step 1: Understand the Need

Ask these questions (use AskQuestion tool if available, otherwise conversationally):

1. **What is the primary goal?**
   - Enforce coding standards/conventions
   - Execute a quick, repeatable action
   - Teach domain-specific knowledge
   - Handle complex, multi-step workflows
   - Provide reference documentation

2. **When should it apply?**
   - Always (every conversation)
   - Intelligently (when AI decides it's relevant)
   - To specific file types/paths
   - On explicit invocation only
   - For specialized, isolated tasks

3. **Scope**
   - Single project only
   - All projects (user-level)
   - Team-wide enforcement

4. **Complexity level**
   - Simple prompt/instruction
   - Requires examples or templates
   - Needs executable scripts
   - Multi-step workflow with context isolation

### Step 2: Apply Decision Logic

Apply the decision tree logic:

**Rules**: Standards/conventions that apply always or intelligently
**Commands**: Quick, single-purpose actions invoked with `/`
**Skills**: Domain knowledge with workflows/scripts
**Subagents**: Complex tasks needing context isolation
**.md + @-mention**: Ad-hoc reference material

For detailed decision tree with all criteria, see [REFERENCE.md](REFERENCE.md) section "Complete Comparison Table" and "When to Use What".

### Step 3: Recommend and Explain

After analyzing the need, provide:

1. **Primary recommendation** with reasoning
2. **Alternative approaches** if applicable
3. **Implementation steps** (specific commands or file locations)
4. **Example structure** if helpful
5. **Gotchas or limitations** to be aware of

### Step 4: Verify Best Practices

**Key practices from Cursor docs (detailed in REFERENCE.md)**:

**Rules**: < 500 lines, concrete examples, reference files not copy, specific descriptions
**Commands**: Plain markdown, descriptive names, clear structure  
**Skills**: SKILL.md < 500 lines, third-person descriptions with triggers, focused responsibility
**Subagents**: Concise prompts, appropriate model, for complex/isolated tasks only

See [REFERENCE.md](REFERENCE.md) for complete best practices and anti-patterns.

### Step 5: Create the Context Method

**After confirming recommendation and verifying best practices**, proceed to create the appropriate structure.

**If converting from an existing @-mention .md file:** Delete the original .md after creating the skill/command/rule. No duplication — keep workspace tidy.

#### Creating a Rule

**Pre-flight checks**:
- [ ] Content is under 500 lines (split if longer)
- [ ] Description is clear and specific
- [ ] References files instead of copying code
- [ ] Avoids vague guidance like "use best practices"
- [ ] Doesn't duplicate what linters already check

**Creation steps**:

1. Determine storage location:
   - Project: `.cursor/rules/`
   - User: Via Cursor Settings (explain this requires manual creation)

2. Create the rule file:
```bash
# For project rules
mkdir -p .cursor/rules
# Create .mdc file with frontmatter for metadata
# OR .md file for simple rules
```

3. Write rule content with appropriate frontmatter:
```markdown
---
description: "Clear, specific description of when this rule applies and what it does"
alwaysApply: false  # true = every conversation, false = agent decides
globs: ["**/*.tsx", "**/*.ts"]  # optional: specific file patterns
---

# Rule Title

## Purpose
[What this rule enforces - be specific]

## Guidelines
- Concrete guideline 1 with examples
- Concrete guideline 2 with examples
- Reference files: @example-file.ts (don't copy entire contents)

## Examples

**Good**:
\`\`\`typescript
// Specific good example
\`\`\`

**Avoid**:
\`\`\`typescript
// Specific bad example
\`\`\`
```

4. Verify: 
   - Check `.cursor/rules/` directory contains the new file
   - Confirm file is under 500 lines
   - Test that description is clear for "Apply Intelligently" mode

#### Creating a Command

**Pre-flight checks**:
- [ ] Task is single-purpose (not complex multi-step workflow)
- [ ] Completes in one shot (doesn't need context isolation)
- [ ] Name is descriptive (file name becomes command)
- [ ] Clear structure planned (overview, steps, examples)

**Creation steps**:

1. Create command directory if needed:
```bash
mkdir -p .cursor/commands
```

2. Create markdown file (name becomes command):
```bash
# File: .cursor/commands/your-command.md
# Name should be descriptive (e.g., create-pr.md, review-code.md)
```

3. Write plain markdown (NO frontmatter needed):
```markdown
# Command Name

## Overview
Brief description of what this command does

## Steps

1. **Step 1**: [Action]
   - Specific detail
   - Expected outcome

2. **Step 2**: [Action]
   - Specific detail
   - Expected outcome

3. **Step 3**: [Action]
   - Specific detail
   - Expected outcome

## Example Usage

Input: [Example scenario]
Output: [Expected result]

## Notes
- Important consideration 1
- Important consideration 2
```

4. Verify:
   - [ ] File is in `.cursor/commands/`
   - [ ] File name is descriptive (not generic)
   - [ ] Content has clear structure
   - [ ] User can invoke with `/command-name`
   - [ ] Supports parameters: `/command-name additional context`

#### Creating a Skill

**Pre-flight checks**:
- [ ] SKILL.md will be under 500 lines (move detailed content to references/)
- [ ] Description includes WHAT it does and WHEN to use it
- [ ] Description written in third person
- [ ] Description includes specific trigger terms
- [ ] Skill has single, clear responsibility (not generic "helper")
- [ ] Name uses lowercase, hyphens, max 64 chars
- [ ] Name is descriptive (not "utils" or "helper")

**Creation steps**:

1. Determine location:
   - Project: `.cursor/skills/skill-name/`
   - User: `~/.cursor/skills/skill-name/`
   - **NEVER**: `~/.cursor/skills-cursor/` (reserved for Cursor built-ins)

2. Create skill directory structure:
```bash
mkdir -p .cursor/skills/skill-name
# Optional subdirectories:
mkdir -p .cursor/skills/skill-name/scripts    # For executable code
mkdir -p .cursor/skills/skill-name/references # For detailed docs
mkdir -p .cursor/skills/skill-name/assets     # For templates/configs
```

3. Create SKILL.md with frontmatter:
```markdown
---
name: skill-name
description: Specific description of what this does and when to use it. Include trigger terms like "Use when working with X, Y, or Z" or "when user mentions A, B, or C".
# Optional: disable-model-invocation: true  # Only if should behave like slash command
---

# Skill Name

## Overview
[Brief, focused explanation - remember agent is already smart]

## When to Use
- Use case 1
- Use case 2

## Instructions

### Main Process
[Concise, step-by-step - avoid verbose explanations]

1. **Step 1**: Action
   - Specific guidance
   
2. **Step 2**: Action
   - Reference script: `scripts/helper.py`

## Examples
[Concrete examples, not abstract descriptions]

## Additional Resources
For detailed information, see [REFERENCE.md](REFERENCE.md)
```

4. Create supporting files if needed:
   - `scripts/`: Executable code (.py, .sh, .js) - use Unix paths
   - `references/REFERENCE.md`: Detailed docs loaded on demand
   - `assets/`: Templates, configs, data

5. Verify:
   - [ ] SKILL.md is under 500 lines
   - [ ] Description is specific with trigger terms
   - [ ] Name follows naming conventions
   - [ ] References are one level deep
   - [ ] Consistent terminology throughout
   - [ ] If has scripts, clear whether to execute or read them

#### Creating a Subagent

**Pre-flight checks**:
- [ ] Task truly needs context isolation (not a simple one-shot action)
- [ ] Subagent has single, clear responsibility
- [ ] Description includes "use proactively" if want auto-delegation
- [ ] Prompt is concise and direct (not 2,000+ words)
- [ ] Appropriate model selected (fast for parallel, inherit for complex)
- [ ] Name uses lowercase, hyphens

**Creation steps**:

1. Determine location:
   - Project: `.cursor/agents/` (project-only)
   - User: `~/.cursor/agents/` (all projects)
   - Also supported: `.claude/agents/` and `.codex/agents/` (compatibility)

2. Create agents directory if needed:
```bash
mkdir -p .cursor/agents
```

3. Create subagent markdown file:
```markdown
---
name: agent-name
description: Clear description of specialization and when to use. Include "use proactively" for auto-delegation or "use when [scenarios]" for specific triggers.
model: inherit  # Options: inherit (default), fast (for parallel/speed), or specific model ID
readonly: false  # Set true to restrict write permissions
is_background: false  # Set true for non-blocking execution (long-running tasks)
---

You are a [specialized role] expert.

## Your Responsibilities

When invoked:
1. [Primary responsibility 1]
2. [Primary responsibility 2]
3. [Primary responsibility 3]

## Process

[Concise, specific steps - avoid rambling]

## Output Format

[How to structure findings/results]

## Quality Standards

[Specific expectations for thoroughness, evidence, etc.]
```

4. Verify:
   - [ ] Check `.cursor/agents/` contains the new agent file
   - [ ] Prompt is focused and concise
   - [ ] Description signals when to use
   - [ ] Model choice is appropriate
   - [ ] Consider adding to version control

#### Creating .md File for @-mention

1. Choose location (`docs/`, project root)
2. Create markdown file
3. Write plain markdown content
4. Usage: `@filename.md` in chat

## Quick Decision Matrix

| Need | Use This |
|------|----------|
| Coding standards, always enforced | Rule (Always Apply) |
| Domain knowledge, context-dependent | Rule (Intelligently) or Skill |
| File-specific patterns | Rule (Specific Files with globs) |
| Quick repeatable action | Command |
| Domain workflow with scripts | Skill |
| Complex multi-step isolation | Subagent |
| Manual reference only | .md file + @-mention |

See [REFERENCE.md](REFERENCE.md) for detailed comparison table and examples.

## Common Scenarios

For detailed examples, see [REFERENCE.md](REFERENCE.md)

Quick reference:
- **Enforce coding style** → Rule (Always Apply)
- **Quick PR workflow** → Command
- **Domain knowledge with scripts** → Skill
- **Independent verification** → Subagent
- **Ad-hoc reference** → .md file + @-mention

## Official Cursor Documentation

**IMPORTANT**: Before creating any context method, reference official Cursor documentation to ensure best practices:

- Rules: https://cursor.com/docs/context/rules
- Commands: https://cursor.com/docs/context/commands
- Skills: https://cursor.com/docs/context/skills
- Subagents: https://cursor.com/docs/context/subagents
- @-mentions: https://cursor.com/docs/context/mentions
- Semantic Search: https://cursor.com/docs/context/semantic-search

**When creating, verify against documentation for current best practices and any updates.**

## Complete Workflow

When helping a user, follow this end-to-end process:

### Phase 0: Prepare (Check Documentation)

**BEFORE starting, optionally fetch latest Cursor documentation**:
- If WebFetch tool is available, fetch relevant docs:
  - Rules: https://cursor.com/docs/context/rules
  - Commands: https://cursor.com/docs/context/commands
  - Skills: https://cursor.com/docs/context/skills
  - Subagents: https://cursor.com/docs/context/subagents
- Review latest best practices and anti-patterns
- Note any recent changes or updates

**This skill embeds best practices from Cursor docs, but checking for updates ensures accuracy.**

### Phase 1: Discovery (Ask Questions)

Gather requirements using AskQuestion tool if available, otherwise conversationally:

```
Questions to ask:
1. What's the primary goal? (enforce standards / quick action / teach domain knowledge / complex workflow / reference)
2. When should it apply? (always / intelligently / specific files / on demand / manual)
3. Scope? (project only / all projects / team-wide)
4. Complexity? (simple instructions / needs examples / needs scripts / multi-step)
5. Any specific requirements? (file patterns, model selection, readonly, etc.)
```

### Phase 2: Analyze & Recommend

Based on answers, apply decision logic and provide:
1. **Primary recommendation** with clear reasoning
2. **Alternative approaches** if applicable
3. **Trade-offs** to consider

### Phase 3: Confirm & Gather Details

Before creating, confirm:
- User agrees with recommendation
- Gather specific details needed:
  - **Name**: What should it be called?
  - **Description/content**: Summarize the guidance/instructions
  - **Location**: Project or user-level?
  - **Additional options**: Any special configuration?

### Phase 4: Create the Structure

**Execute creation steps**:
1. Create necessary directories using Shell tool
2. Write files with appropriate content using Write tool
3. Verify structure is correct using LS and Read tools

### Phase 5: Verify & Test

1. Confirm files created successfully
2. **Validate against Cursor best practices**:
   - [ ] File size appropriate (< 500 lines for rules/skills)
   - [ ] Naming conventions followed
   - [ ] Descriptions are specific with trigger terms
   - [ ] Structure matches official templates
   - [ ] No anti-patterns present
3. Show user the created structure
4. Explain how to use/invoke it
5. Provide next steps or improvements

### Documentation Check

**When in doubt, reference official docs**:
- If creating a rule, check: https://cursor.com/docs/context/rules
- If creating a command, check: https://cursor.com/docs/context/commands
- If creating a skill, check: https://cursor.com/docs/context/skills
- If creating a subagent, check: https://cursor.com/docs/context/subagents

**Use WebFetch tool if available to get latest guidance from Cursor documentation.**

## Example Complete Session

See [REFERENCE.md](REFERENCE.md) for detailed end-to-end example sessions showing the complete workflow from discovery through creation.

## Key Differences & Anti-Patterns

**Rules**: Cursor-specific | **Skills**: Portable (Agent Skills standard)
**Commands**: Simple | **Skills**: Can have scripts/references  
**Skills**: Main context | **Subagents**: Separate context

**Anti-patterns**: Subagent for simple tasks, rule for one-time reference, skill with `disable-model-invocation` (use command), command for complex workflow, dozens of generic items

## Validation Checklist Before Finalization

After creating any context method, verify:

**All types**:
- [ ] Correct location and file structure
- [ ] Naming conventions followed
- [ ] Content is appropriate length

**Rules**: < 500 lines, specific description, references files not copies
**Commands**: Plain markdown, no frontmatter, descriptive name
**Skills**: SKILL.md < 500 lines, third-person description with triggers, single responsibility
**Subagents**: Concise prompt, appropriate model, needs context isolation

For detailed checklists, see [REFERENCE.md](REFERENCE.md) section "Validation Checklists".

## Critical: Always Create After Recommending

**When user confirms recommendation, immediately proceed to creation**:
1. **Check documentation first** - Use WebFetch if available to get latest Cursor guidance
2. **Verify best practices** - Use validation checklist above
3. Don't just provide instructions - actually create the files
4. Use Shell tool to create directories
5. Use Write tool to create files with proper formatting
6. Use LS/Read tools to verify
7. **Run validation checklist** - Confirm no anti-patterns
8. **If converting from @-mention .md** - Delete the original .md file (no duplication)
9. Show user what was created and how to use it
