# Critique Doc

Produce a structured 1-page critique of a requirements document (PRD, Builder Brief, or spec).

## Output Format

Single table with these columns:

| Section | Strength | Gap / Risk | Suggested Fix | Priority |
|---------|----------|------------|---------------|----------|

## Rules

- One row per document section
- Be specific: "Missing acceptance criteria for R3" not "needs more detail"
- Priority: P0 (blocking), P1 (should fix), P2 (nice to have)
- Focus on: completeness, testability, clarity, feasibility, and risk coverage
- Flag any requirements without verification methods
- Flag any scope ambiguity or missing non-goals

## Usage

`/critique-doc @requirements.md`
