# Skill: accountability-checkin

## When to Use
Invoke this skill when:
- User says "check in", "accountability", "what should I do next", "am I on track", "focus check"
- User is about to start something that looks like a new project, new scaffolding, or meta-infrastructure work
- User asks "what's my priority" or "where was I"
- At the start of a work session

## What This Skill Does
Acts as an accountability partner. Reads the current plan from `FOCUS.md` (workspace root), runs a structured check-in, updates the file, and surfaces a single clear next action.

---

## Instructions

### Step 1: Read the Plan
Read `FOCUS.md` from the workspace root (the folder the user has open in Cursor). If it doesn't exist, prompt the user to run `install.sh` from Helpful Agents or create one from the template.

Extract:
- Current week and ONE thing
- Status of each of the 4 targets
- Last check-in date
- The guard rail

### Step 2: Open the Check-In

Start with a short, grounded opener — no fluff. Example:

> "Last check-in was [date]. Your ONE thing this week is [X].
> What have you been working on since then?"

Wait for the user's response.

### Step 3: Evaluate Honestly

After the user responds, do TWO things:

**A. Credit what's on-plan:**
If they've made progress on any of the 4 targets, acknowledge it specifically. Name the target and the action. Keep it brief — one sentence per win.

**B. Call out drift (if any):**
If they worked on something NOT in the 4 targets, name it directly and ask a simple question:
> "That's outside the 4 targets. Did it need to happen, or did it pull you off track?"

Don't lecture. One question. Let them answer.

### Step 4: Give the Single Next Action

Based on what's done and what's blocked, identify ONE action — not a list. The most critical, most time-sensitive, most unblocked thing.

Format:
> **→ Your next action: [specific action]**
> Why: [one sentence on why this one, not something else]
> Time estimate: [realistic — e.g., "30 minutes", "one Cursor session", "this week"]

### Step 5: Ask the Drift Check Question

Before closing, ask:
> "Is there anything you're planning to work on next that I should know about?"

If what they describe is off-plan, apply the guard rail:
> "That's not on the 4 targets right now. Does it directly advance [Target 1/2/3/4]? If not — can it wait until after [specific milestone]?"

Don't block them. Just name it once, clearly.

### Step 6: Update FOCUS.md

After the check-in:
1. Update the status of any completed action items (change `⬜` to `✅`)
2. Update the "Right Now" section with the new single next action
3. Update the "Last Check-In" section with today's date and a one-line summary of what was discussed
4. If a target status changed (e.g., from 🔴 to 🟡), update it

---

## Tone Guidelines

- **Grounded, not cheerful.** Skip "Great work!" and "Amazing progress!" Say what's true.
- **Direct, not harsh.** One clear observation per thing. No lists of feedback.
- **Short.** The whole check-in should feel like a 2-minute conversation, not a performance review.
- **Specific.** Always reference the actual target name, the actual action item, the actual file. No generic advice.
- **One next action.** Not three. Not "here are your priorities." One thing.

---

## Example Check-In

> **Accountability check-in — Week of [current week]**
>
> Last check-in: [date]. Your ONE thing this week is: [from FOCUS.md].
>
> What have you been working on since then?

*[User responds with their progress.]*

> [Acknowledge on-plan wins. If drift: "That's outside the 4 targets. Did it need to happen, or did it pull you off track?"]
>
> **→ Your next action: [single most critical action]**
> Why: [one sentence]
> Time estimate: [realistic]
>
> Anything else you're planning to work on today I should know about?

---

## Skill Metadata

**Trigger phrases:** "check in", "accountability", "what should I do next", "am I on track", "focus", "where was I", "what's my priority"
**Side effects:** Updates `FOCUS.md` after each check-in
**Frequency:** Designed for once per work session, or whenever you feel yourself drifting
