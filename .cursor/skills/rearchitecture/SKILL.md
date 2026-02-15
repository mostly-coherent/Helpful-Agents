---
description: Documents component architecture, boundaries, and patterns. Use when user says "document architecture", "re-architecture", "component boundaries", or needs ARCHITECTURE.md created/updated after refactoring.
---

# Rearchitecture

Document component architecture, separation of concerns, bounded contexts, and design principles. Creates/updates ARCHITECTURE.md.

## When to Use

- After splitting large components
- Establishing architecture patterns for new project
- Documenting structure during refactoring
- Onboarding developers to codebase

## Instructions

1. **Analyze** — Map components, sizes, shared utilities; find large components (>500 lines)
2. **Establish boundaries** — Feature vs UI vs Infrastructure; bounded contexts; data flow
3. **Document** — Separation diagram, component table, design principles, state/error handling
4. **Identify improvements** — Violations, missing separation, coupling, performance

**Output:** Create/update ARCHITECTURE.md with structure, diagrams, tables.

For full template and output format, see [REFERENCE.md](references/REFERENCE.md).
