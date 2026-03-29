# Create Builder Brief

Generate a Builder Brief from the template — a lightweight, prototype-driven requirements document for fast MVP development.

## Steps

1. Ask for: **Project name**, **immediate goal**, **problem/opportunity**
2. Scaffold the Builder Brief using the template structure:
   - Vision (optional), Immediate Goal, Problem/Opportunity
   - Objectives & Success Metrics
   - Scope (In/Out with rationale)
   - Requirements (Functional P0 only + Data Requirements)
   - Approach (what we're building, stretch goals, how to test)
   - Non-Functional Requirements, Risks, Open Questions
   - Next Increment preview, References, Evidence Log
3. Save as `<ProjectName>_Builder_Brief.md`

## Template Structure

| Section | Purpose |
|---------|---------|
| Vision | Strategic context (1-2 sentences) |
| Immediate Goal | One-line description |
| Problem/Opportunity | 2-3 sentences on the pain |
| Objectives & Success | What + how to measure + target |
| Scope | In/Out with rationale |
| Requirements | Functional (P0), Data requirements |
| Approach | UX flow, tech choices, dependencies |
| Non-Functional | Performance, security, reliability |
| Risks | Impact + mitigation + owner |
| Open Questions | Decision needed + owner + due date |

## Key Rules

- Keep to 2 pages max — if longer, narrow scope
- Group related items into subcategories/themes
- No tech stack decisions or effort estimates
- Tables over prose, bullets over paragraphs

## Usage

`/create-builder-brief` or `/create-builder-brief @context-doc.md`
