---
name: fact-check
description: Scans edited content for unverified claims, force-fit jargon, and ambiguous phrasing. Use after editing markdown files (tables, posts, docs) to catch factual errors before user has to notice them. Triggers on "fact-check this", "verify claims", or via Hook after file edits.
---

# Fact-Check

**Purpose:** Catch factual errors, unverified generalizations, and force-fit jargon before they ship.

**Use for:**
- Scanning tables, LinkedIn posts, documentation for accuracy
- Detecting unverified claims ("most teams," "everyone," "always")
- Identifying force-fit jargon (terms mentioned without clear tie-in)
- Flagging ambiguous phrasing (unclear connectors, vague references)

**Do NOT use for:**
- Grammar checking (use a linter)
- AI-slop detection (use detect-ai-slop skill)
- Style/voice polishing (use in-my-voice skill)

---

## Scan Categories

### 1. Unverified Generalizations

**What to catch:**
- "Most teams..." (no data to support)
- "Everyone knows..." (no evidence)
- "Always..." / "Never..." (absolute claims without proof)
- "The industry..." (vague authority)

**Examples:**
- ❌ "Most teams aren't there yet" → No data for this claim
- ✅ "We're not there yet" → First-person, factual

### 2. Force-Fit Jargon

**What to catch:**
- Technical terms mentioned without clear context
- Acronyms used without establishing relevance
- Buzzwords added for credibility but not tied to content

**Examples:**
- ❌ "MCP access controls" in Harness column → Not clearly applicable; niche detail
- ✅ "RAG pipelines" in Context column → Clear tie-in (automated retrieval)

### 3. Ambiguous Phrasing

**What to catch:**
- Semicolons creating unclear relationships
- Vague connectors ("also," "too" without antecedent)
- Unclear references ("this," "it" without clear noun)
- Lists mixing categories (artifacts + techniques)

**Examples:**
- ❌ "Rules, Skills; RAG pipelines, MCP servers" → Semicolon suggests two groups but unclear relationship
- ✅ "Rules, Skills (may use RAG, MCP)" → Clear: RAG/MCP are techniques applied within

---

## Scanning Process

When invoked (manually or via Hook):

1. **Read the target file** (user specifies or Hook provides path)
2. **Scan for each category**:
   - Unverified generalizations: Flag any claim about "most," "everyone," "always"
   - Force-fit jargon: Flag technical terms without clear context
   - Ambiguous phrasing: Flag unclear connectors, vague references
3. **Output findings** in structured format:

```markdown
### Fact-Check Findings

**File:** [path]

**Unverified Generalizations (count: N)**
- Line X: "[quote]" — Issue: [no data/evidence]

**Force-Fit Jargon (count: N)**
- Line Y: "[quote]" — Issue: [not clearly applicable]

**Ambiguous Phrasing (count: N)**
- Line Z: "[quote]" — Issue: [unclear relationship/reference]

**Verdict:** [Clean / Minor Issues / Needs Revision]

**Recommendation:**
[Specific fixes or "Ready to ship"]
```

4. **Present to user** — user reviews and approves/rejects

---

## Usage

**Manual invocation:**
```
User: "Fact-check this table"
Agent: [Reads file, runs scan, outputs findings]
```

**Hook invocation (automatic):**
- Hook fires after markdown file edit
- Hook passes file path to this skill
- Skill runs scan and presents findings
- User reviews before continuing

---

## Configuration

**Target file types:** Markdown (.md)
**Scan depth:** Line-by-line for exact quotes
**Output location:** Inline (chat) or temp file (for Hook workflow)

---

## Examples

**Example 1: Unverified Generalization**

Input:
```
Most teams aren't using Harness Engineering yet.
```

Output:
```
**Unverified Generalization (Line 7):**
"Most teams aren't using Harness Engineering yet."
Issue: No data to support this claim. Stick to first-person observations.
Suggested fix: Remove "Most teams" or change to "We're not there yet."
```

**Example 2: Force-Fit Jargon**

Input:
```
Harness Engineering: Guardrails, evals, MCP access controls
```

Output:
```
**Force-Fit Jargon (Line 5):**
"MCP access controls"
Issue: Not clearly applicable in Harness context; niche detail compared to core concerns (guardrails, evals).
Suggested fix: Drop "MCP access controls" or clarify why it's central to Harness.
```

**Example 3: Ambiguous Phrasing**

Input:
```
Rules, Skills, Agents; RAG pipelines, MCP servers
```

Output:
```
**Ambiguous Phrasing (Line 6):**
"Rules, Skills, Agents; RAG pipelines, MCP servers"
Issue: Semicolon creates unclear relationship. Are RAG/MCP separate artifacts or techniques used within?
Suggested fix: "Rules, Skills, Agents (may use RAG for retrieval, MCP for tools)"
```

---

## Integration with Hooks

This skill is designed to be invoked by a Hook after file edits.

**Hook workflow:**
1. User edits markdown file
2. Hook fires `after_file_edit`
3. Hook invokes this skill with file path
4. Skill scans and presents findings
5. User reviews and approves/rejects

**Hook config:** See `.cursor/hooks.json` (user creates manually per Cursor docs)

---

## Validation Checklist

Before running scan:
- [ ] Target file is markdown (.md)
- [ ] File path is accessible
- [ ] Scan categories are clear

After running scan:
- [ ] All findings have line numbers and quotes
- [ ] Issues are specific (not vague)
- [ ] Suggested fixes are actionable
- [ ] Verdict is clear (Clean / Minor / Needs Revision)
