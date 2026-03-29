---
description: Passively detects when the current task would be better served by Claude Code CLI and advises the user to switch. Evaluates task characteristics every conversation — fires once if a CLI upgrade trigger is detected.
---

# CLI Nudge

Passively monitor every conversation for tasks that hit the ceiling of Desktop tools (Cursor or Claude Code Desktop). When you detect a CLI upgrade trigger, surface a brief, actionable advisory — once per conversation, not repeatedly.

## How This Works

You do NOT wait for the user to ask "should I use CLI?" Instead, you evaluate task characteristics as the conversation unfolds. If a trigger matches, you advise. If none match, you say nothing. This rule is silent by default.

## CLI Upgrade Triggers

Evaluate the user's task against these signals. If one or more match, advise.

| Signal in conversation | Why CLI is better | What to suggest |
|---|---|---|
| Work spans multiple subsystems or repos simultaneously | Desktop apps run one agent at a time | CLI agent teams — parallel agents in separate terminals |
| Task should run unattended (overnight, batch, "while I sleep") | Desktop requires human presence | `claude --print` non-interactive mode |
| Compliance or data residency requirement (Bedrock, Vertex) | Desktop doesn't support provider routing | `claude --provider bedrock` or `--provider vertex` |
| Event-triggered automation (on PR merge, on Slack message, cron) | Desktop is manual-start only | CLI + shell scripting / hooks |
| Need spend control on a long autonomous run | Desktop has no budget cap | `claude --max-budget-usd <amount>` |
| Repeatable pipeline (test, fix, commit, PR — in a loop) | Better as a scripted workflow than interactive chat | CLI piping with `--print` |
| User wants to keep working here while another agent runs | Desktop is single-session | Run CLI in a separate terminal window |
| Bulk refactor across 50+ files with a clear pattern | CLI handles long batch operations without timeout | CLI with focused instructions |

## Advisory Format

Keep it short, specific, and non-blocking. Include: what you detected, why CLI fits, and the specific CLI feature. Offer to draft the command.

**Template:**

> **Heads up — this might be a CLI moment.** [What you detected — e.g., "You're describing simultaneous work across Catalog, Authzn_Metering, and Checkout."] Desktop tools handle one agent at a time. In CLI, you can [specific capability — e.g., "spin up parallel agents on each subsystem"]. Want me to draft the CLI command, or keep going here?

## Rules

1. **Once per conversation.** If you've already advised CLI in this session, don't repeat it.
2. **Advice, not a gate.** The user decides. If they say "keep going here," respect that and continue.
3. **Be specific.** Don't say "consider CLI." Say which trigger you detected and which CLI flag solves it.
4. **No false positives.** Normal coding, doc writing, brainstorming, single-repo work — these don't need CLI. Only fire when a genuine ceiling is hit.
5. **Reference the Builder Guide.** If the user wants more context, point them to `Helpful Agents/Builder-Guide_Cursor-ClaudeDesktop-CLI.md` for the full comparison.
