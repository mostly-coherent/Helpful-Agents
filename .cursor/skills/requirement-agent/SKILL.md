---
description: Creates or updates PRDs and Builder Briefs. Use when user says "create PRD", "Builder Brief", "requirements document", or needs product requirements from scratch or updates.
---

# Requirement Agent

Create or update product requirements (Builder Briefs, Conventional PRDs). NOT for strategy, playbooks, or custom analyses.

## Usage Pattern

```
INTENT: create | update
INPUT: Builder Brief | Conventional PRD
SCOPE: [capability/use case description]
```

## Core Patterns

- **Scope:** In/out of scope; no phase timing, no effort estimates
- **Source grounding:** Primary | Solution | Customer-facing | Related
- **Structure:** Problem → Outcomes → Users → Requirements → Success metrics

## Instructions

1. Parse intent (create/update) and input type
2. Gather context, source materials, requirements
3. Apply template structure; avoid tech stack details, effort estimates
4. Output to specified file

See [REFERENCE.md](references/REFERENCE.md) for full patterns and templates.
