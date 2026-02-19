# Context Advisor Reference

Detailed examples and comparison tables for choosing context methods in Cursor.

## Complete Comparison Table

| Feature | Rules | Commands | Skills | Subagents | .md + @-mention |
|---------|-------|----------|--------|-----------|-----------------|
| **Invocation** | Auto/Manual | `/command` | Auto/Manual | Auto/Manual | Manual `@file` |
| **Context Window** | Main | Main | Main | Separate | Main |
| **Version Control** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Portable** | ❌ Cursor-specific | ❌ Cursor-specific | ✅ Agent Skills standard | ❌ Cursor-specific | ✅ Universal |
| **Can Include Scripts** | ❌ No | ❌ No | ✅ Yes | ❌ No | ❌ No |
| **Progressive Loading** | ❌ No | ❌ No | ✅ Yes (references/) | ❌ No | ❌ No |
| **Model Selection** | ❌ Inherits | ❌ Inherits | ❌ Inherits | ✅ Configurable | ❌ Inherits |
| **Background Execution** | ❌ No | ❌ No | ❌ No | ✅ Yes | ❌ No |
| **File Pattern Matching** | ✅ Globs | ❌ No | ❌ No | ❌ No | ❌ No |
| **Team Management** | ✅ Dashboard | ✅ Dashboard | ❌ No | ❌ No | ❌ No |
| **Best For** | Standards | Quick actions | Workflows | Complex tasks | Ad-hoc reference |

## Real-World Examples

### Example 1: Enforcing TypeScript Conventions

**Need**: Always use strict TypeScript conventions across the codebase

**Best Choice**: Rule (Always Apply)

**Why**: 
- Needs to apply to every conversation
- Project-specific coding standard
- Should be version-controlled for team

**Implementation**:
```markdown
---
description: "TypeScript coding conventions for this project"
alwaysApply: true
---

# TypeScript Standards

- Always use `interface` for object types, not `type`
- Prefer readonly properties where possible
- Use strict null checks
- Avoid `any` type - use `unknown` if type is truly unknown
```

**Location**: `.cursor/rules/typescript-standards.mdc`

---

### Example 2: Git Commit Message Helper

**Need**: Quick way to generate commit messages from staged changes

**Best Choice**: Command

**Why**:
- Single-purpose action
- User explicitly invokes it
- Completes in one shot
- No context isolation needed

**Implementation**:
```markdown
# Generate Commit Message

Review the staged changes using `git diff --staged` and generate a descriptive commit message following conventional commits format:

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **refactor**: Code refactoring
- **test**: Adding tests

Format:
```
type(scope): brief description

Detailed explanation if needed
```

Keep the first line under 72 characters.
```

**Location**: `.cursor/commands/commit.md`

**Usage**: `/commit` or `/commit fix auth bug`

---

### Example 3: PDF Processing Workflows

**Need**: Comprehensive guidance for working with PDF files including extraction, validation, and merging

**Best Choice**: Skill

**Why**:
- Domain-specific knowledge
- Multi-step workflow
- Can include utility scripts
- Portable across projects
- AI should auto-apply when working with PDFs

**Implementation**:

`.cursor/skills/pdf-processing/SKILL.md`:
```markdown
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Text Extraction

Use pdfplumber for reliable text extraction:

\`\`\`python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
\`\`\`

## Validation

After processing, run validation:
\`\`\`bash
python scripts/validate_pdf.py output.pdf
\`\`\`

For detailed API reference, see [REFERENCE.md](REFERENCE.md)
```

`.cursor/skills/pdf-processing/scripts/validate_pdf.py`:
```python
#!/usr/bin/env python3
import sys
import pdfplumber

def validate_pdf(filepath):
    try:
        with pdfplumber.open(filepath) as pdf:
            if len(pdf.pages) == 0:
                print("ERROR: PDF has no pages")
                return False
            print(f"OK: PDF has {len(pdf.pages)} pages")
            return True
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    sys.exit(0 if validate_pdf(sys.argv[1]) else 1)
```

---

### Example 4: Security Audit Agent

**Need**: Independent security review of auth/payment code that doesn't bloat main conversation

**Best Choice**: Subagent

**Why**:
- Specialized expertise
- Context isolation (security analysis generates verbose output)
- Independent verification
- Can use faster model for parallel execution

**Implementation**:

`.cursor/agents/security-auditor.md`:
```markdown
---
name: security-auditor
description: Security specialist for reviewing auth, payments, and sensitive data handling. Use when implementing authentication, processing payments, or handling PII.
model: fast
readonly: true
---

You are a security expert auditing code for vulnerabilities.

When invoked:

1. Identify security-sensitive code paths
2. Check for common vulnerabilities:
   - SQL injection
   - XSS (Cross-Site Scripting)
   - CSRF (Cross-Site Request Forgery)
   - Auth bypass
   - Insecure deserialization
3. Verify secrets are not hardcoded
4. Review input validation and sanitization
5. Check authentication and authorization logic

Report findings by severity:
- 🔴 **Critical**: Must fix before deploy
- 🟡 **High**: Fix soon
- 🟢 **Medium**: Address when possible

For each finding, provide:
- Location (file:line)
- Vulnerability description
- Recommended fix
- Example secure code
```

**Usage**: AI invokes automatically when working with auth/payments, or manually: `/security-auditor` or "Use security-auditor to review this"

---

### Example 5: API Specification Reference

**Need**: Sometimes reference API spec, but not always needed

**Best Choice**: .md file + @-mention

**Why**:
- Reference only (not workflow)
- Ad-hoc usage
- Simple, no automation needed
- Manual control over when to include

**Implementation**:

`docs/api-spec.md`:
```markdown
# Payment API Specification

## POST /api/payments

Creates a new payment.

**Request**:
\`\`\`json
{
  "amount": 1000,
  "currency": "USD",
  "customer_id": "cus_123"
}
\`\`\`

**Response**:
\`\`\`json
{
  "id": "pay_456",
  "status": "succeeded"
}
\`\`\`
```

**Usage**: `@api-spec.md when you need it in conversation`

---

## When to Upgrade

### .md file → Rule
Upgrade when:
- You find yourself @-mentioning it frequently
- Should apply automatically to relevant conversations
- Contains standards/conventions, not just reference

### Command → Skill
Upgrade when:
- Need to include executable scripts
- Workflow becomes multi-step
- Want it portable across projects
- Need progressive loading (references/)

### Skill → Subagent
Upgrade when:
- Task requires context isolation
- Generate verbose intermediate output
- Need independent verification
- Want parallel execution with different model

### Rule → Team Rule
Upgrade when:
- Need to enforce across entire team
- Want centralized management
- On Team/Enterprise plan

## Anti-Pattern Examples

### ❌ BAD: Subagent for Simple Task

```markdown
---
name: format-imports
description: Formats import statements
---

Sort imports alphabetically.
```

**Why bad**: This is a single-purpose task that doesn't need context isolation. Use a command or skill instead.

---

### ❌ BAD: Rule for One-Time Context

```markdown
---
alwaysApply: true
---

Here is the context for feature X we're building this week...
```

**Why bad**: This is temporary context that shouldn't apply forever. Use .md + @-mention instead.

---

### ❌ BAD: Command for Complex Workflow

```markdown
# Deploy Application

This will deploy the application through multiple stages...
(50 lines of complex instructions)
```

**Why bad**: Complex workflows should be skills (if in main context) or subagents (if need isolation).

---

### ❌ BAD: Skill with disable-model-invocation

```markdown
---
name: quick-action
description: Does a simple thing
disable-model-invocation: true
---

Quick action instructions
```

**Why bad**: If you're disabling auto-invocation, it's behaving like a command. Just use a command instead.

---

## Troubleshooting

### "My rule isn't being applied"

**Check**:
1. Rule type - is it "Apply Intelligently"? Check description is specific
2. For "Apply to Specific Files", verify globs pattern matches
3. For "Apply Manually", are you @-mentioning it?

---

### "My skill never gets triggered"

**Fix description**:
- ✅ Include trigger terms: "Use when working with PDFs, forms, or document extraction"
- ✅ Be specific about capabilities: "Extract text and tables from PDF files"
- ❌ Avoid vague: "Helps with documents"

---

### "My subagent is slow/expensive"

**Consider**:
1. Is this really complex enough for a subagent?
2. Can you use `model: fast` for this task?
3. Is the task actually more suited to a skill?

---

### "I have 50+ rules/skills and it's confusing"

**Consolidate**:
- Merge related rules into single comprehensive rule
- Delete rarely-used rules
- Use project rules for project-specific, user rules for universal
- Keep descriptions specific to help AI decide

---

## Migration Guide

### From .cursorrules (legacy) to Project Rules

1. Open `.cursorrules` file
2. Create new rule via Cursor Settings → Rules
3. Copy content to new rule
4. Set appropriate rule type
5. Delete `.cursorrules` when ready

### From AGENTS.md to Project Rules

1. Open `AGENTS.md`
2. Create appropriate rule/skill based on content
3. Use migration skill: `/migrate-to-skills` (Cursor 2.4+)

---

## Quick Decision Flowchart

```
Start: What's your need?
│
├─ Enforce standards/conventions always?
│  └─ Rule (Always Apply)
│
├─ Quick one-shot action on demand?
│  └─ Command
│
├─ Domain knowledge with workflows/scripts?
│  └─ Skill
│
├─ Complex task needing context isolation?
│  └─ Subagent
│
└─ Simple reference, manual control?
   └─ .md + @-mention
```

---

## Creation Templates

Use these templates when creating context methods:

### Rule Template

**File**: `.cursor/rules/rule-name.mdc`

```markdown
---
description: "Clear, specific description of when this rule applies and what it does"
alwaysApply: false
# Optional: globs: ["**/*.tsx", "**/*.ts"]
---

# Rule Title

## Purpose
[Brief explanation of what this rule enforces/provides]

## Guidelines

- Guideline 1 with specific examples
- Guideline 2 with concrete patterns
- Reference existing files: @example-file.ts

## Examples

**Good**:
\`\`\`typescript
// Example of following the rule
\`\`\`

**Bad**:
\`\`\`typescript
// Example of what to avoid
\`\`\`

## Additional Context
[Any domain-specific knowledge needed]
```

---

### Command Template

**File**: `.cursor/commands/command-name.md`

```markdown
# Command Name

## Overview
Brief description of what this command does

## Process

1. **Step 1**: First action
   - Detail about step 1
   - Expected outcome

2. **Step 2**: Second action  
   - Detail about step 2
   - Expected outcome

3. **Step 3**: Final action
   - Detail about step 3
   - Expected outcome

## Example Usage

Input: [Example input]
Output: [Example output]

## Notes
- Important consideration 1
- Important consideration 2
```

---

### Skill Template

**File**: `.cursor/skills/skill-name/SKILL.md`

```markdown
---
name: skill-name
description: Specific description of what this skill does and when to use it. Include trigger terms like "Use when working with X, Y, or Z" or "when the user mentions A, B, or C".
# Optional: disable-model-invocation: false
---

# Skill Name

## Overview
Brief explanation of what this skill teaches or enables

## When to Use

- Use case 1
- Use case 2
- Use case 3

## Instructions

### Main Workflow

1. **Step 1**: [Action]
   - Specific guidance
   - Code example if applicable

2. **Step 2**: [Action]
   - Specific guidance
   - Reference scripts: `scripts/helper.py`

3. **Step 3**: [Action]
   - Specific guidance

## Examples

### Example 1: [Scenario]
Input: [What you're working with]
Output: [Expected result]

### Example 2: [Scenario]
Input: [What you're working with]
Output: [Expected result]

## Utility Scripts

**script-name.py**: [Description]
\`\`\`bash
python scripts/script-name.py [args]
\`\`\`

## Additional Resources

For detailed information, see [REFERENCE.md](REFERENCE.md)
```

**Optional**: `.cursor/skills/skill-name/REFERENCE.md`

```markdown
# Skill Name - Reference

Detailed documentation that supplements SKILL.md

## Advanced Usage
[Deep dive into complex scenarios]

## API Reference
[Detailed API information if applicable]

## Troubleshooting
[Common issues and solutions]
```

---

### Subagent Template

**File**: `.cursor/agents/agent-name.md`

```markdown
---
name: agent-name
description: Clear description of what this agent specializes in and when to use it. Include trigger scenarios.
model: inherit  # Options: inherit, fast, or specific model ID
readonly: false  # Set true to restrict writes
is_background: false  # Set true for non-blocking execution
---

# Agent Role

You are a [specialized role] expert focused on [domain].

## Responsibilities

When invoked, you should:

1. [Primary responsibility 1]
2. [Primary responsibility 2]  
3. [Primary responsibility 3]

## Analysis Process

1. **Identify**: [What to identify]
2. **Analyze**: [How to analyze]
3. **Report**: [What to report]

## Output Format

Provide findings in this structure:

### Summary
[Brief overview of findings]

### Detailed Findings

**Category 1**:
- Finding 1: [Description and location]
- Finding 2: [Description and location]

**Category 2**:
- Finding 1: [Description and location]

### Recommendations

1. **Priority**: [Recommendation with specific action]
2. **Priority**: [Recommendation with specific action]

## Quality Standards

- Be specific with file and line references
- Provide concrete examples
- Explain the "why" behind recommendations
- Prioritize findings by impact/severity
```

---

### .md File Template (for @-mention)

**File**: `docs/reference-name.md` or `reference-name.md`

```markdown
# Reference Title

## Overview
[Brief description of this reference material]

## Section 1

[Content for section 1]

### Subsection 1.1
[Detailed information]

## Section 2

[Content for section 2]

### Examples

\`\`\`language
// Example code or configuration
\`\`\`

## Additional Information

[Any other relevant details]
```

---

## Best Practices from Cursor Documentation

### Rules Best Practices
- ✅ Keep rules under 500 lines (split large rules into composable rules)
- ✅ Provide concrete examples or reference files with @filename
- ✅ Avoid vague guidance - be specific and actionable
- ✅ Reference files instead of copying entire contents
- ✅ Don't duplicate what's already in codebase
- ✅ Avoid documenting edge cases that rarely apply
- ✅ Write clear descriptions for "Apply Intelligently" rules
- ❌ Don't copy entire style guides (use linter instead)
- ❌ Don't document every possible command
- ❌ Don't add instructions for rare edge cases

### Commands Best Practices
- ✅ Store as plain Markdown files (no frontmatter)
- ✅ Use descriptive names (file name becomes command)
- ✅ Include clear structure (overview, steps, checklist)
- ✅ Support parameters (additional context after command name)
- ✅ Organize by workflow

### Skills Best Practices
- ✅ Write focused skills (single, clear responsibility)
- ✅ Invest in descriptions - determines when agent uses skill
- ✅ Keep SKILL.md under 500 lines
- ✅ Use progressive loading (references/ for detailed docs)
- ✅ Include executable scripts in scripts/ when helpful
- ✅ Write descriptions in third person
- ✅ Be specific and include trigger terms in description
- ✅ Test descriptions to ensure right skill gets triggered
- ❌ Don't create dozens of generic skills with vague instructions
- ❌ Don't use overly long prompts (2,000+ words)
- ❌ Don't duplicate slash commands
- ❌ Don't create vague skill names like "helper" or "utils"

### Subagents Best Practices
- ✅ Use for context isolation (long research tasks)
- ✅ Use for parallel execution (multiple workstreams)
- ✅ Use for specialized expertise across many steps
- ✅ Write focused subagents (single, clear responsibility)
- ✅ Invest in descriptions (include "use proactively" if auto-delegation wanted)
- ✅ Keep prompts concise and direct
- ✅ Choose appropriate model (fast for parallel, inherit for complex)
- ✅ Add to version control (.cursor/agents/)
- ❌ Don't use for simple, single-purpose tasks (use skills/commands)
- ❌ Don't create overly long prompts
- ❌ Don't duplicate slash commands
- ❌ Don't create too many subagents (start with 2-3 focused ones)

---

## Validation Checklists

### For Rules
- [ ] File is in `.cursor/rules/` directory
- [ ] Uses `.mdc` extension with frontmatter OR `.md` for simple rules
- [ ] Description field is clear and specific
- [ ] Content is under 500 lines
- [ ] References files with @filename (doesn't copy entire contents)
- [ ] Avoids vague guidance like "use best practices"
- [ ] Doesn't duplicate what linters check
- [ ] Examples are concrete, not abstract

### For Commands
- [ ] File is in `.cursor/commands/` directory
- [ ] Uses `.md` extension
- [ ] NO frontmatter (plain markdown)
- [ ] File name is descriptive
- [ ] Has clear structure (overview, steps, examples)
- [ ] Single-purpose (not complex workflow)

### For Skills
- [ ] Directory is in `.cursor/skills/skill-name/`
- [ ] SKILL.md has YAML frontmatter with name and description
- [ ] Name: lowercase, hyphens, max 64 chars, not generic
- [ ] Description: third person, specific, includes trigger terms
- [ ] SKILL.md is under 500 lines
- [ ] Detailed content moved to references/ if needed
- [ ] Single, clear responsibility
- [ ] Scripts use Unix paths (not Windows backslashes)
- [ ] File references are one level deep
- [ ] Consistent terminology throughout

### For Subagents
- [ ] File is in `.cursor/agents/` directory
- [ ] Uses `.md` extension with YAML frontmatter
- [ ] Name, description, model fields present
- [ ] Description includes when to use (or "use proactively")
- [ ] Prompt is concise (not 2,000+ words)
- [ ] Single, clear responsibility
- [ ] Model choice is appropriate (fast vs inherit)
- [ ] Task needs context isolation (not simple one-shot)

### For .md Files (@-mention)
- [ ] Placed in appropriate location (docs/, project root)
- [ ] Plain markdown, no special formatting
- [ ] User informed to use `@filename.md` to reference

---

## Example Complete Session

**User**: "I want guidance for our React component patterns"

**Agent (Discovery)**:
```
I'll help you set up context for React component patterns. Let me ask a few questions:
1. Should this apply to every conversation or only when working with React components?
2. Is this for this project only or all your projects?
3. Do you need executable scripts or just guidance/examples?
```

**User**: "Only when relevant, project-only, just guidance"

**Agent (Recommend)**:
```
Based on your needs, I recommend a **Skill**:
- ✅ Domain-specific knowledge (React patterns)
- ✅ Should apply intelligently when working with React
- ✅ Project-level guidance
- ✅ Portable and version-controlled

Alternative: Could use a Rule (Apply Intelligently), but Skills are more portable.
```

**User**: "Sounds good, create it"

**Agent (Gather Details)**:
```
Great! I'll create the skill. A few details:
- Name: react-component-patterns
- Description: Guide for React component structure and patterns in this project. Use when working with React components, JSX, or .tsx files.

Ready to create?
```

**User**: "Yes"

**Agent (Create)**:
```bash
# Create skill directory
mkdir -p .cursor/skills/react-component-patterns

# Write SKILL.md
[Creates SKILL.md with frontmatter and content based on user's requirements]

# Write REFERENCE.md if needed
[Creates additional reference material]
```

**Agent (Verify & Explain)**:
```
✅ Created skill at .cursor/skills/react-component-patterns/

The skill will automatically activate when you work with React components. 
You can also invoke it manually with: /react-component-patterns

Next steps:
- Test it by asking about React component structure
- Add more examples to REFERENCE.md as patterns emerge
- Share with team by committing to version control
```

---

## Additional Resources

- Cursor Documentation: https://cursor.com/docs
- Agent Skills Standard: https://agentskills.io
- Cursor Forum: https://forum.cursor.com
