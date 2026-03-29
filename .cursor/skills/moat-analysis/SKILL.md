---
name: moat-analysis
description: Analyzes any company's defensibility in the AI era using the 10-Moat Framework. Phase 1 researches the company in depth, Phase 2 scores all 10 moats per segment, Phase 3 triggers multi-LLM stress test with auto-synthesis. Use when user says "moat analysis", "analyze [company]", "how defensible is [company]", or "run moat framework on [company]".
---

# Moat Analysis — 10-Moat Framework Pipeline

Produces a structured defensibility assessment of any company in the AI/agentic era. Three phases: deep company research → framework scoring → multi-LLM stress test with synthesis.

## When to Use

- User says "moat analysis on [Company]", "analyze [Company]", "how defensible is [Company]"
- User wants to assess a company through the 10-Moat Framework
- User references `framework.md` and a company name together

## Prerequisites

- `framework.md` must exist in the working directory (the 10-Moat Framework spec)
- `multi-llm-rigorous-analysis` skill must be available (for Phase 3)
- If `framework.md` is not found, tell the user and offer to create a stub or point to where it should be

## Cross-Tool Usage

This skill works in both **Claude Code** and **Cursor**.

| Tool | Phase 1+2 | Phase 3 (Multi-LLM) |
|------|-----------|---------------------|
| **Claude Code** | Full support — uses web search + company-research agent | All 4 subagent types available: `rigorous-analysis-sonnet`, `rigorous-analysis-opus`, `rigorous-analysis-gpt`, `rigorous-analysis-gemini`. Invoke via Agent tool. |
| **Cursor** | Full support — uses web search | Invoke subagents via `@rigorous-analysis-{model} @file`. Each runs on its configured model (Claude, GPT, Gemini). |

### Claude Code — How to run Phase 3

In Claude Code, launch the 4 critique agents in parallel:

```
Agent(subagent_type="rigorous-analysis-sonnet", prompt="@path/to/file.md")
Agent(subagent_type="rigorous-analysis-opus", prompt="@path/to/file.md")
Agent(subagent_type="rigorous-analysis-gpt", prompt="@path/to/file.md")
Agent(subagent_type="rigorous-analysis-gemini", prompt="@path/to/file.md")
```

After all 4 complete, run synthesis (see multi-llm-rigorous-analysis skill for synthesis instructions).

### Cursor — How to run Phase 3

Invoke each subagent in a separate Composer chat:

```
@rigorous-analysis-sonnet @path/to/file.md
@rigorous-analysis-opus @path/to/file.md
@rigorous-analysis-gpt @path/to/file.md
@rigorous-analysis-gemini @path/to/file.md
```

---

## Phase 1: Company Research

**Goal:** Build a thorough company profile BEFORE applying the framework. The quality of the moat analysis depends on the depth of this research.

### Step 1A: Classify the company type

Determine which category the company falls into — this drives the source strategy:

| Company Type | Signals |
|---|---|
| **Public (large cap)** | Listed on major exchange, market cap >$10B, analyst coverage |
| **Public (small/mid)** | Listed but thinner coverage, market cap <$10B |
| **Late-stage private** | Known funding rounds (Series C+), press coverage, 100+ employees |
| **Early-stage / stealth** | Seed–Series B, limited press, <100 employees |
| **Very limited info** | Minimal public footprint |

### Step 1B: Research using adaptive source strategy

**For ALL companies, cover these dimensions:**

| Dimension | What to find |
|---|---|
| **Products & segments** | What does the company sell? How is revenue segmented? What's the core vs. adjacent? |
| **Business model** | How does it make money? Subscription, transaction, licensing, marketplace? |
| **Revenue / financials** | Revenue, growth rate, margins, segment mix. For private: estimated ARR, funding, burn rate if available. |
| **Customers & market** | Who buys? Enterprise, SMB, consumer? TAM/SAM estimates. |
| **Founders / executives** | Background, strategic vision, public statements on AI/technology direction. |
| **Competitive landscape** | Direct competitors, substitutes, new AI-native entrants. |
| **AI / technology strategy** | How is the company responding to AI? Building, buying, partnering? Public statements, product launches. |
| **Recent developments** | Last 12 months: earnings, acquisitions, partnerships, product launches, leadership changes. |

**Source priority by company type:**

| Source | Public (large) | Public (small) | Late-stage private | Early-stage |
|---|---|---|---|---|
| SEC filings (10-K, 10-Q) | Primary | Primary | N/A | N/A |
| Earnings transcripts | Primary | Primary | N/A | N/A |
| Investor presentations | Primary | Check | N/A | N/A |
| Analyst reports / press | Primary | Secondary | Secondary | Rare |
| Company website / blog | Always | Always | Always | Always |
| Crunchbase / PitchBook | Reference | Reference | Primary | Primary |
| Founder Twitter/X + LinkedIn | Supplementary | Supplementary | Primary | Primary |
| Job postings | Supplementary | Supplementary | Primary (reveals priorities) | Primary (reveals stack) |
| G2 / Capterra / App Store reviews | Supplementary | Supplementary | Secondary | Primary |
| GitHub (if OSS components) | Check | Check | Check | Primary |
| ProductHunt | Rare | Rare | Check | Primary |
| Investor portfolio / thesis blogs | Rare | Rare | Secondary | Primary |
| Patent filings | Check | Check | Check | Check |
| Conference talks / podcasts | Supplementary | Supplementary | Secondary | Secondary |

### Step 1C: Assess data confidence

After research, produce a confidence table:

```markdown
## Data Confidence

| Dimension | Coverage (1-5) | Best source |
|---|---|---|
| Products & segments | | |
| Business model | | |
| Revenue / financials | | |
| Customers & market | | |
| Founders / executives | | |
| Competitive landscape | | |
| AI / technology strategy | | |
| Recent developments | | |

**Overall confidence:** [High / Medium-High / Medium / Low-Medium / Low]
**Key gaps:** [What's missing or uncertain — flag these for Phase 2]
```

Coverage scale: 5 = rich multi-source data, 4 = solid single-source, 3 = adequate, 2 = thin/dated, 1 = speculative/absent.

### Step 1D: Output

Save to: `{Company}/{Company}_Company_Research.md`

Structure:
1. Company Overview (1-2 paragraphs)
2. Products & Segments (table preferred)
3. Business Model & Revenue
4. Customers & Market
5. Leadership & Strategic Direction
6. Competitive Landscape
7. AI / Technology Strategy
8. Recent Developments (last 12 months)
9. Data Confidence (table from 1C)
10. Sources & Provenance

---

## Phase 2: Framework Analysis

**Goal:** Score the company against all 10 moats from `framework.md`, segmented by business line where applicable.

### Step 2A: Read inputs

- Read `framework.md` (the 10-Moat Framework spec — look in current working directory or project root)
- Read `{Company}/{Company}_Company_Research.md` (Phase 1 output)

### Step 2B: Segment the business

Most companies have multiple segments with different moat profiles. Identify 2-5 segments based on the research.

### Step 2C: Score each of the 10 moats

For each segment, evaluate each moat:

| # | Moat | Status for this segment | Evidence | Exposure level |
|---|---|---|---|---|
| 1 | Learned Interfaces | [Destroyed / Weakened / Intact / Strengthening] | [Specific evidence] | [High / Medium / Low] |
| 2 | Custom Workflows | ... | ... | ... |
| ... | ... | ... | ... | ... |
| 10 | System of Record | ... | ... | ... |

### Step 2D: Apply the 3-Question Risk Test

Per segment:

| Question | Answer | Implication |
|---|---|---|
| Is the data proprietary? | [Yes/No + evidence] | |
| Is there regulatory lock-in? | [Yes/No + evidence] | |
| Is it embedded in the transaction? | [Yes/No + evidence] | |

**Risk level:** [High / Medium / Low]

### Step 2E: Identify blind spots and counter-points

- Where might the company's management or analysts be wrong?
- What are they not seeing?
- Surface counter-points with citations where possible.
- Flag any Data Confidence gaps from Phase 1 that weaken specific moat assessments.

### Step 2F: Output

Save to: `{Company}/{Company}_10_Moat_Framework.md`

Structure:
1. Executive Summary (overall defensibility verdict, 2-3 paragraphs)
2. Business Segments (table overview)
3. Moat-by-Moat Analysis (per segment where relevant)
4. 3-Question Risk Test (per segment)
5. Blind Spots & Counter-Points
6. Data Confidence Caveats (from Phase 1 gaps)
7. Overall Risk Assessment
8. Sources & Provenance

---

## Phase 3: Multi-LLM Stress Test

**Goal:** Challenge the Phase 2 analysis with 4 independent LLM critiques, then synthesize.

### Step 3A: Offer to run

After Phase 2 output is saved, ask the user:

> "Phase 2 complete — `{Company}/{Company}_10_Moat_Framework.md` is ready. Want me to run the multi-LLM stress test? This will produce 4 independent critiques (Sonnet, Opus, GPT, Gemini) and an auto-synthesis."

### Step 3B: If user confirms

Invoke `/multi-llm-rigorous-analysis` on the Phase 2 output file. See the "Cross-Tool Usage" section above for how to invoke in Claude Code vs. Cursor.

The analyses and synthesis will be saved to `{Company}/analyses/`.

### Step 3C: If user declines

Phase 2 output stands on its own. The user can run Phase 3 later.

---

## Folder Convention

All outputs for a given company live in one folder relative to the working directory:

```
{working_dir}/
├── framework.md
├── {Company}/
│   ├── {Company}_Company_Research.md          ← Phase 1
│   ├── {Company}_10_Moat_Framework.md         ← Phase 2
│   └── analyses/                              ← Phase 3
│       ├── {basename}_analysis_sonnet.md
│       ├── {basename}_analysis_opus.md
│       ├── {basename}_analysis_gpt.md
│       ├── {basename}_analysis_gemini.md
│       └── SYNTHESIS_{Company}_10_Moat_Framework.md
```

---

## Tips for Best Results

- **Private companies:** Be upfront about data gaps. A moat analysis on thin data is still valuable — it identifies what you DON'T know, which is itself a finding.
- **Conglomerates:** Segment aggressively. A company like Amazon has radically different moat profiles for AWS vs. Marketplace vs. Devices.
- **Startups:** Focus on which moats they're TRYING to build vs. which they actually have. Aspiration ≠ reality.
- **Framework evolution:** `framework.md` is the single source of truth for moat definitions. If it changes, future analyses automatically pick up the new version. Past analyses reflect the framework version at time of writing.
