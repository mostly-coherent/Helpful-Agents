---
description: Guide idea development through conversational Q&A. Activates when user says "Help me brainstorm", "Let's brainstorm", "Brainstorm ideas for", "I want to brainstorm", or similar. Asks one question at a time, builds on answers, and produces output in user's chosen format (Builder Brief, idea doc, outline).
---

# Brainstorm

Collaboratively develop an idea through guided conversation. Activates when you say "Help me brainstorm", "Let's brainstorm", "Brainstorm ideas for [X]", or "I want to brainstorm". I ask one focused question at a time and build on your answers.

## Trigger Patterns

- "Help me brainstorm [topic]"
- "Let's brainstorm [idea]"
- "Brainstorm ideas for [X]"
- "I want to brainstorm [something]"
- "Can we brainstorm [concept]?"

## Process

### 1. Pace Detection

- **User gives lots of context upfront:** Ask 1–2 clarifying questions, then synthesize
- **User gives a seed idea:** Ask one question at a time, building on each answer
- **User says "quick brainstorm":** Cover core (problem, users, solution) in fewer questions
- **User says "deep dive":** Full exploration including risks, research needs, success metrics

### 2. Question Flow (One at a Time)

I explore in this order, adapting based on what you've already shared:

1. **Problem** — What problem are you solving? Who has it?
2. **Users** — Who would use this? Primary and secondary?
3. **Solution** — What's the proposed approach? High-level.
4. **Benefits** — What value does it deliver? To users and/or business?
5. **Success** — How would you know it worked? Metrics or signals?
6. **Risks** — What could go wrong? What's uncertain?
7. **Next steps** — What would you need to validate or decide?

Each question builds on previous answers. I never ask for something you've already given.

### 3. Output Format (User Chooses)

When we have enough context, I offer:

| Option | Output | When to use |
|--------|--------|-------------|
| **Builder Brief** | Lightweight PRD (2 pages, scope, requirements) | Ready to prototype or hand off |
| **Idea doc** | Structured idea with problem, users, solution, stories | Exploring before committing |
| **Outline** | Bullet summary of key points | Quick reference |
| **User stories only** | "As a [persona], I want [X], so that [Y]" | For backlog or sprint planning |

User can say "Builder Brief" or "just an outline" at any point. Default: idea doc if unspecified.

### 4. Output Location

I adapt to the workspace:
- `brainstorm/` if it exists
- `docs/` or `notes/` otherwise
- User can specify: "Save to docs/ideas/"

### 5. Bridge to Next Steps

After producing output, I suggest:
- "Want me to turn this into a Builder Brief?" (if idea doc)
- "Want a critique on this?" (link to critique-requirements)
- "Ready to create a project from this?" (link to create-project)

## Example Flow

**User:** "Help me brainstorm a feedback widget for our docs site"

**I:** "What's the main problem you're trying to solve? Is it that users can't easily report issues, or that you're not getting enough signal on what's confusing?"

**User:** "Both—we get support tickets but no in-context feedback"

**I:** "Who would use it? Developers reading our API docs, or a broader audience?"

**User:** "Mostly developers, some technical PMs"

**I:** "Got it. What would the widget do—simple thumbs up/down, or something richer like inline comments?"

... (continues one question at a time)

**I:** "I have enough to build an idea doc. Want Builder Brief, idea doc, or outline?"

**User:** "Builder Brief"

**I:** [Creates Builder Brief, saves to brainstorm/ or docs/, offers critique or project creation]

## Key Features (vs Top-Marks)

- **No fixed template** — User chooses output format (Builder Brief, idea doc, outline)
- **Smart pacing** — Adapts to how much context user gives upfront
- **Optional depth** — "Quick brainstorm" vs "deep dive"
- **Flexible output** — brainstorm/, docs/, or user-specified
- **Bridge to tools** — Suggests requirement-agent, critique-requirements, create-project
- **No mandatory semantic IDs** — Only if user wants them
- **User stories optional** — Skip if user doesn't need them
