---
name: multi-llm-rigorous-analysis
description: Orchestrates 4 LLMs (Sonnet, Opus, GPT, Gemini) to rigorously analyze and critically critique any write-up, then auto-synthesizes findings. Works in both Claude Code and Cursor. Use when user says "rigorous analysis", "multi-LLM critique", "deep critique", or wants multiple AI perspectives on a document.
---

# Multi-LLM Rigorous Analysis

Produces 4 independent, rigorous critiques of any write-up, then synthesizes them into a unified assessment. Each subagent fetches research from 12 thought-leader sources, mirrors the source's style, and writes a full analysis.

## When to Use

- User wants multiple AI perspectives on a document
- User says "rigorous analysis", "multi-LLM critique", "deep critique"
- User wants to identify blind spots, validate strong points, get counter-arguments with provenance
- Analysis can run in background (each run may take 15–45+ min due to web research)

## How to Run

### In Claude Code

Launch all 4 subagents in parallel using the Agent tool:

```
Agent(subagent_type="rigorous-analysis-sonnet", prompt="Analyze @path/to/source.md")
Agent(subagent_type="rigorous-analysis-opus", prompt="Analyze @path/to/source.md")
Agent(subagent_type="rigorous-analysis-gpt", prompt="Analyze @path/to/source.md")
Agent(subagent_type="rigorous-analysis-gemini", prompt="Analyze @path/to/source.md")
```

After all 4 complete, run synthesis (see Phase 2 below).

### In Cursor

Invoke each subagent in a separate Composer chat:

1. **Sonnet** — `@rigorous-analysis-sonnet @path/to/source.md`
2. **Opus** — `@rigorous-analysis-opus @path/to/source.md`
3. **GPT** — `@rigorous-analysis-gpt @path/to/source.md`
4. **Gemini** — `@rigorous-analysis-gemini @path/to/source.md`

After all 4 complete, run synthesis (see Phase 2 below).

## Phase 1: What Each Critique Does

1. **Understand the Source** — Reads the document, extracts key themes, entities, and search-relevant terms. Required before web research.
2. **Web Research (Theme-Guided)** — Fetches from 12 thought-leader sources. Uses Step 0 themes to identify and extract relevant excerpts with provenance.
3. **Style Analysis** — Analyzes the source's tone, structure, formatting, length. Mirrors it in the output.
4. **Critique** — Writes: blind spots, misled/ill-informed points, spot-on insights, counter-points with citations, synthesis.
5. **Output** — Saves to `{source_dir}/analyses/{basename}_analysis_{model}.md`

## Phase 2: Auto-Synthesis (After All 4 Critiques)

Once all 4 analysis files exist in `{source_dir}/analyses/`, produce a synthesis that reconciles the competing critiques.

### When to run

- **Automatically:** After the 4th critique is saved, check if all 4 `*_analysis_{model}.md` files exist. If yes, proceed to synthesis.
- **Manually:** User can say "synthesize" or "run synthesis" if the 4 files already exist.

### Synthesis process

1. **Read all inputs:** The original source file + all 4 critique files.
2. **Identify convergence:** Points where 3+ models agree. These are high-confidence findings.
3. **Identify divergence:** Points where models disagree. Flag as open questions — explain each side.
4. **Identify unique insights:** Something only one model surfaced that others missed. These are often the most valuable.
5. **Produce verdict:** Overall assessment with confidence level, informed by convergence/divergence pattern.

### Synthesis output structure

```markdown
# Synthesis: [Source Title] — Multi-LLM Analysis

## Executive Summary
[2-3 paragraph overall verdict]

## High-Confidence Findings (3+ Models Agree)
[Bulleted findings with which models support each]

## Contested Points (Models Disagree)
[For each: the disagreement, who says what, and why it matters]

## Unique Insights (Single Model)
[Insights surfaced by only one model — flag which one and why it's worth noting]

## Open Questions
[What remains unresolved — areas for further research or monitoring]

## Model Comparison
| Dimension | Sonnet | Opus | GPT | Gemini |
|---|---|---|---|---|
| Overall stance | | | | |
| Strongest section | | | | |
| Blindest spot | | | | |

## Sources Cited Across All Analyses
[Deduplicated list of external sources referenced by any model]
```

### Output location

Save to: `{source_dir}/analyses/SYNTHESIS_{source_basename}.md`

---

## Thought Leader Sources (12, Scoped)

| Source | URL |
|--------|-----|
| Exponential View | exponentialview.co |
| Benedict Evans | ben-evans.com |
| Stratechery | stratechery.com |
| Import AI | importai.substack.com |
| Hannah Ritchie | hannahritchie.substack.com |
| Not Boring | notboring.co |
| Interconnects | interconnects.ai |
| Noahpinion | noahpinion.blog |
| Uncharted Territories | unchartedterritories.tomaspueyo.com |
| Wait But Why | waitbutwhy.com |
| Kevin Kelly | kk.org |
| Citrini Research | citriniresearch.com |

See `references/THOUGHT_LEADERS.md` and `references/FETCH_URLS.md` for full URLs.

## Style Mirroring (Dynamic)

Works for any input write-up. Each subagent:
- Analyzes tone (formal, conversational, technical)
- Analyzes structure (headers, tables, lists)
- Analyzes formatting (bold, italics, em-dashes)
- Mirrors these in the critique output

## Models (Latest Extended Thinking / Reasoning)

| Subagent | Model |
|----------|-------|
| Sonnet | claude-sonnet-4-6 |
| Opus | claude-opus-4-6 |
| GPT | gpt-5.3-codex |
| Gemini | gemini-3.1-pro |

## Subagent Location

- **Claude Code:** `~/.claude/agents/` — available as Agent tool subagent types
- **Cursor:** `~/.cursor/agents/` — invokable via `@rigorous-analysis-{model}`

Files:
- `rigorous-analysis-sonnet.md`
- `rigorous-analysis-opus.md`
- `rigorous-analysis-gpt.md`
- `rigorous-analysis-gemini.md`
