# Create Business Guide

Generate a business-facing onboarding guide from technical documentation. Turns complex backend specs into a concise (2-3 page) guide for non-technical stakeholders.

## Inputs Required

1. **Technical Documentation** — specs, architecture docs, schemas
2. **Target Audience** — e.g., "App Teams", "Partner Developers"
3. **Business Goal** — e.g., "Monetization", "Security", "Compliance"

## Output Structure

1. **Executive Summary** — Value proposition + "Just give us these X decisions"
2. **Key Decisions (The "What")** — 3-5 non-technical decisions with analogies and rationale
3. **Onboarding Checklist (The "Action")** — Copy-pasteable table: Field | Description | Example | Your Input
4. **FAQ** — 3-4 questions covering modern trends (AI/Agents, SaaS, 3P integrations)
5. **Lifecycle/Stages** (optional) — Alpha/Beta/GA expectations

## Style

- Conversational but professional (Formality: 3.5/5)
- No buzzwords ("leverage", "synergy", "seamless", "robust")
- Short sentences, one idea per sentence
- Tables for comparisons, bold for emphasis
- Empower the reader — make them feel capable, not confused

## Usage

`/create-business-guide @technical-docs.md`
