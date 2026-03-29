---
name: multi-angle-research
description: Conducts structured multi-perspective research on any topic. Use when user says "research the business case for...", "competitor analysis on...", "make the case for and against...", "pros and cons of...", "what should [company] do about...", "analyze [topic] from multiple angles", "devil's advocate on...", or "give me a complete picture of...". Produces 5 research .md files plus 1 executive summary .md. All outputs are markdown.
---

# Multi-Angle Research

**Purpose:** Structured, multi-perspective research on any topic. Delivers 5 granular deep-dives (one per track) and a 1-page executive summary. All outputs are .md files. Built to be objective — affirmative case, counter-case, then synthesis.

## When to Use

- Business case analysis (for/against) on a strategy, product, or initiative
- Competitive landscape or peer analysis
- News/developments research on technologies or companies
- Devil's advocate thinking on a position
- Synthesis recommendation from multiple research streams
- Multiple research documents saved to workspace

## Workflow Overview

**5 tracks** (each → own .md file) + **1 executive summary** (.md):

| Track | Focus |
|-------|-------|
| 1 | Business Strategy (for/against/what you'd learn) |
| 2 | Competitor/Peer Analysis (who's doing it and why) |
| 3 | Key Platform/Technology Developments (latest news) |
| 4 | Devil's Advocate (steelman case against) |
| 5 | Contrarian View & Recommendation (synthesis) |
| — | Executive Summary (1-page) |

**Run Tracks 1–3 in parallel.** Write Tracks 4–5 and exec summary after reviewing results.

---

## Step 0: Clarify (If Needed)

If the request is ambiguous, ask before starting:
- **Perspective:** Whose view? (e.g. "for [Company]", "for a startup", "for a regulator")
- **Time horizon:** Near-term pilot vs long-term commitment?
- **Constraints:** Budget, timeline, regulatory?

If the user already specified these, skip and proceed.

**Output format:** All outputs are .md files. Do not produce .docx or .pdf unless the user explicitly overrides.

---

## Step 1: Todo List

Create a TodoWrite before starting:

```
- Clarify (if needed)
- Research Track 1 (Business Strategy)
- Research Track 2 (Competitors)
- Research Track 3 (Platform/Tech Developments)
- Write Track 4 (Devil's Advocate)
- Write Track 5 (Contrarian View & Recommendation)
- Write Executive Summary
- Save all 6 .md files
- Verify outputs
```

---

## Step 2: Parallel Research (Tracks 1–3)

**Option A (preferred):** Launch 3 `mcp_task` subagents in parallel (subagent_type: generalPurpose). One per track. Each prompt instructs the agent to conduct web research (WebSearch, fetch) for the past 12–24 months and return detailed findings with URLs.

**Option B (fallback):** If subagents cannot access web tools, the main agent conducts research for each track using WebSearch and mcp_web_fetch. Run Track 1, then 2, then 3.

### Track 1 Prompt — Business Strategy

```
Conduct thorough web research on: [TOPIC].

Focus on:
1. Why [company/industry] SHOULD pursue this — market trends, revenue potential, strategic fit, customer behavior shifts
2. Why they MIGHT HESITATE — cost, risk, channel conflict, trust, regulatory complexity
3. What they would LEARN by experimenting — what strategic intelligence would a pilot generate?
4. Current strategy context — what has [company/industry] already done or announced?
5. Broader industry signals — macro trends that support or complicate the case

Use WebSearch and fetch for recent (past 12–24 months) articles, analyst reports, news. Be objective. Return detailed findings with URLs.
```

### Track 2 Prompt — Competitor/Peer Analysis

```
Conduct thorough web research on which companies — competitors, peers, adjacent tech players — are offering [TOPIC capability], and why.

For each company: What are they offering? Live/beta/announced? Strategic logic? Traction if available?

Organize by maturity: full deployment → significant capability → early/adjacent → not pursuing. Include companies NOTABLY NOT pursuing and explain why.

Use WebSearch and fetch. Return detailed findings with URLs.
```

### Track 3 Prompt — Platform/Technology Developments

```
Conduct thorough web research on the latest news from [KEY PLATFORMS/TECHNOLOGIES] regarding [TOPIC].

For each platform: What have they launched or announced? Strategic rationale? What worked, failed, scaled back? What does their trajectory signal?

Synthesize: How do these developments collectively build (or undermine) the case for [company/industry] to pursue [TOPIC]?

Use WebSearch and fetch for past 12–24 months. Return detailed findings with URLs.
```

---

## Step 3: Track 4 — Devil's Advocate

After reviewing Tracks 1–3, write Track 4 yourself. **Steelman the opposing view** — argue as convincingly as possible against pursuing the topic.

**Structure:**
- The Central Argument Against
- Pitfall 1, 2, … N (8–12 named pitfalls, grounded in Track 1–3 evidence)
- Summary: Risk Matrix (Risk | Severity | Likelihood | Mitigation Difficulty)
- Conclusion of the Devil's Advocate Case
- Key Sources

Each pitfall must be named clearly and genuinely challenge the affirmative case — not strawman.

---

## Step 4: Track 5 — Contrarian View & Recommendation

Synthesis. Resist both hype-driven "do it" and risk-averse "don't do it." Land on a **third path**: specific, nuanced action.

**Structure:**
- The Contrarian Position in Brief (1–2 sentence thesis)
- Why the Affirmative Case Is Premature / Overstated
- Why the Defensive Case Misses Something Important
- The Structural Argument (what the mainstream narrative gets wrong)
- Evidence to Look For Before Committing
- A Specific Recommendation (scope, timeline, success criteria, learning value, boundaries)
- The Honest Bottom Line
- Summary Table: What to Do and What to Avoid
- Sources

**Recommendation must include:** Scope, timeline, success criteria (defined in advance), what it generates regardless of outcome, what it does NOT commit to.

---

## Step 5: Executive Summary (1-Pager)

Single .md file. ~400–600 words. Readable in under 3 minutes.

**Structure:**
1. [Section — e.g. The Business Case] — 3–4 sentences
2. [Section — e.g. Competitive Landscape] — 3–4 sentences
3. [Section — e.g. Platform Developments] — 3–4 sentences
4. [Section — e.g. The Honest Risks] — 4–6 tight bullets
5. **Recommendation** — blockquote thesis, why affirmative is premature, why defensive misses something, specific recommendation, immediate actions, overarching insight in italics
6. Sources

Use **bold** for key phrases. Use `>` blockquote for the one-sentence thesis. No padding.

---

## Step 6: Save All Files

**Output location:** Project root from context. Prefer `Requirements/Research Notes/` or `Research/` if present; else create `Research/` or use project root. User can specify a different path.

**File naming** (title-case, underscores, 2–4 word topic slug):

```
Research1_[Topic]_Business_Strategy.md
Research2_[Topic]_Competitor_Analysis.md
Research3_[Topic]_Platform_Developments.md
Research4_[Topic]_Devils_Advocate.md
Research5_[Topic]_Contrarian_View_and_Recommendation.md
Exec_Summary_[Topic].md
```

**Example:** `Research1_ConversationalCommerce_Business_Strategy.md`, `Exec_Summary_ConversationalCommerce.md`

Each file: title, metadata header (topic, date, prepared for), executive summary at top, numbered sections, **Key Sources** at end with linked citations.

---

## Quality Checks

Before marking done:
- [ ] All 6 .md files exist and are non-empty
- [ ] Each has Key Sources with real URLs
- [ ] Track 5 and exec summary recommendations are consistent
- [ ] Track 4 genuinely challenges — not perfunctory risks
- [ ] Track 5 lands on a third path, not "do it" or "don't do it"

---

## Tone & Objectivity

- Tracks 1–3: Present evidence neutrally
- Track 4: Argue opposing case as forcefully as the affirmative
- Track 5: Call out when market narrative is ahead of evidence
- Sources: Real, recent, linked — not invented
- Quantitative claims: Cite figures with sources

---

## Example Invocations

| User says | Topic | Focus |
|-----------|-------|-------|
| "Research the business case for [Company] to launch subscription commerce on [Platform]" | Subscription Commerce via [Platform] | Track 3 = Platform developments |
| "Competitive analysis on AI customer service in retail banking" | AI Customer Service in Retail Banking | Track 2 = competitive field |
| "Make the case for and against [Company] acquiring [Target]" | [Company] acquiring [Target] | Full 5-track |
| "What should [Company] do about agentic commerce?" | Agentic Commerce Strategy for [Company] | Full 5-track |

---

**Reference:** [TRACK_TEMPLATES.md](references/TRACK_TEMPLATES.md) for full markdown templates.
