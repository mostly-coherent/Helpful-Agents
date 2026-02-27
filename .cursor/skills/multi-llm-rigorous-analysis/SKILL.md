---
name: multi-llm-rigorous-analysis
description: Orchestrates 4 LLMs (Sonnet, Opus, GPT, Gemini) to rigorously analyze and critically critique any write-up. Each run uses Cursor's built-in models—no API keys. Invoke 4 subagents (one per model). Use when user says "rigorous analysis", "multi-LLM critique", "deep critique", or wants multiple AI perspectives on a document.
---

# Multi-LLM Rigorous Analysis

Produces 4 independent, rigorous critiques of any write-up. Each subagent fetches research from 12 thought-leader sources, mirrors the source's style, and writes a full analysis. **Uses Cursor's models—no external API keys.**

## When to Use

- User wants multiple AI perspectives on a document
- User says "rigorous analysis", "multi-LLM critique", "deep critique"
- User wants to identify blind spots, validate strong points, get counter-arguments with provenance
- Analysis can run in background (each run may take 15–45+ min due to web research)

## How to Run (Click 4 Times)

**Invoke each subagent once** with the source file. Each uses a different model.

1. **Sonnet** — `@rigorous-analysis-sonnet @path/to/source.md`
2. **Opus** — `@rigorous-analysis-opus @path/to/source.md`
3. **GPT** — `@rigorous-analysis-gpt @path/to/source.md`
4. **Gemini** — `@rigorous-analysis-gemini @path/to/source.md`

Example for the moat document:
```
@rigorous-analysis-sonnet @moat/Adobe_Through_the_Lens_of_the_10_Moat_Framework.md
```

## What Each Run Does

1. **Understand the Source** — Reads the document, extracts key themes, entities, and search-relevant terms. Required before web research.
2. **Web Research (Theme-Guided)** — Fetches from 12 thought-leader sources. Uses Step 0 themes to identify and extract relevant excerpts with provenance.
3. **Style Analysis** — Analyzes the source's tone, structure, formatting, length. Mirrors it in the output.
4. **Critique** — Writes: blind spots, misled/ill-informed points, spot-on insights, counter-points with citations, synthesis.
5. **Output** — Saves to `{source_dir}/analyses/{basename}_analysis_{model}.md`

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

| Subagent | Model | Cursor Display |
|----------|-------|----------------|
| Sonnet | claude-sonnet-4-6 | Claude 4.6 Sonnet |
| Opus | claude-opus-4-6 | Claude 4.6 Opus |
| GPT | gpt-5.3-codex | GPT-5.3 Codex |
| Gemini | gemini-3.1-pro | Gemini 3.1 Pro |

If a model ID isn't available in Cursor, edit the subagent's `model:` line to match Cursor's model selector.

## Subagent Location

User-level (`~/.cursor/agents/`) — installed by Helpful Agents `install.sh`:
- `rigorous-analysis-sonnet.md`
- `rigorous-analysis-opus.md`
- `rigorous-analysis-gpt.md`
- `rigorous-analysis-gemini.md`
