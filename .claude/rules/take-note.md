---
description: Capture ad-hoc notes from natural language. Activates when user says "Take a note:", "Note:", "Quick note:", "Capture this:", "Jot down:", or similar. Creates or appends to markdown files with smart location detection and optional structure.
---

# Take Note

Capture ad-hoc notes of any length. Activates when you say "Take a note: [content]", "Note:", "Quick note:", "Capture this:", or "Jot down:". No structure required—just type and I'll handle the rest.

## Trigger Patterns

- "Take a note: [content]"
- "Note: [content]"
- "Quick note: [content]"
- "Capture this: [content]"
- "Jot down: [content]"
- "Remember: [content]"

## What I Do

### 1. Semantic Analysis

I analyze the content to understand:
- **Primary topic** — Main subject or theme
- **Context** — Meeting, decision, idea, research, action item
- **Time** — Past events, current thoughts, future commitments (dates, deadlines)
- **People** — Who was mentioned (for attribution)

### 2. Location Intelligence (Workspace-Agnostic)

I scan the workspace structure and adapt to what exists:

| If I find | I use |
|-----------|-------|
| `notes/` | `notes/` or `notes/[topic]/` |
| `docs/notes/` | `docs/notes/` |
| `docs/` | `docs/notes/` |
| Neither | Create `notes/` at project root or use `docs/` |

**No prescriptive structure.** I match existing folders, suggest new ones only when needed, and explain my reasoning.

### 3. Append vs Create

- **Append:** If topic clearly matches an existing note file, I offer: "Append to existing file X or create new?"
- **Create:** If no match or new topic, create a new file with a semantic filename (no timestamps in filename).

### 4. Content Formatting

I structure the note with:

- **Main content** — Preserved as-is, with light formatting (headings, lists) if helpful
- **Action Items** — Future dates, follow-ups, TODOs extracted to a section
- **Upcoming Events** — Explicit dates/deadlines in a dedicated section
- **Tags** — Optional `#topic` tags at top for quick scanning

### 5. User Interaction

Before creating or appending:
- **Propose:** Show the path: `notes/subfolder/filename.md`
- **Explain:** One-line reasoning for why this location
- **Confirm:** If creating a new folder, ask. Otherwise proceed unless user objects.

### 6. Changelog (Optional)

For new files: Add initial changelog entry with date and "Created."
For updated files: Append entry with date and brief description.

Format: `- YYYY-MM-DD: [Description]`

User can say "no changelog" to skip.

## Example

**User:** "Take a note: Discussed agent registry search with Sarah. She suggested prioritizing semantic search over keyword matching. Follow up with engineering by Nov 20."

**I will:**
1. Analyze: Topic = agent registry, context = meeting, action = follow-up by Nov 20
2. Scan: Look for `notes/`, `docs/`, project structure
3. Propose: `notes/agent-registry-search.md` (or appropriate subfolder)
4. Format: Main content + Action Items section with the Nov 20 follow-up
5. Create: File with optional changelog

## Output Template

```markdown
# [Topic Name]

[Main note content—preserved]

## Action Items
- [Date] [Follow-up or commitment]

## Upcoming Events
- [Date] [Event]

---
## Changelog
- YYYY-MM-DD: Created
```

## Key Features (vs Top-Marks)

- **Workspace-agnostic** — Adapts to any project structure, no fixed `notes/` hierarchy
- **Append option** — Can add to existing notes when topic matches
- **Flexible triggers** — Multiple natural phrases
- **Optional changelog** — User preference, not mandatory
- **Minimal friction** — Accept notes as-is; structure only when it adds value
