---
name: extract-sitemap
description: Map all links from a starting webpage recursively up to 2 hops deep (depth 0, 1, 2 only - depth 3 is descoped), check link accessibility, and generate a sitemap markdown file. Use when the user wants to preview what pages would be extracted, discover site structure, or identify dead links before running extract-webpage-content.
---

# Extract Sitemap

Map all links from a starting webpage recursively up to 2 hops deep, check accessibility of each link, and generate a structured sitemap markdown file.

## When to Use

Use this skill when:
- User wants to preview what pages would be extracted before running `extract-webpage-content`
- User needs to discover site structure and understand link relationships
- User wants to identify dead links (404, 403, etc.) before extraction
- User mentions "map links," "sitemap," "preview extraction," or "check dead links"

**Do NOT use when:**
- User wants to extract actual page content (use `extract-webpage-content` instead)
- User only wants to check a single page's links (use browser tools instead)

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `extract-webpage-content` | Run after this skill; accepts this skill's sitemap file as input for curated extraction |
| `extract-page-shallow` | Alternative when user only needs depth 0 + 1 without sitemap preview |

## Execution Model

**Execute autonomously** - Complete the entire workflow without user approval for each action.

**CRITICAL - NO CONFIRMATION REQUESTS:**
- NEVER ask "Should I continue?" or for approval between pages
- ALWAYS continue until queue is empty and sitemap is generated
- ONLY report progress updates, never ask for permission

**Required tools:** Playwright MCP (`user-playwright`) - does NOT require per-action approval
**Do NOT use:** cursor-ide-browser MCP - requires per-action approval (not suitable)

## Workflow

1. **Resume Logic** - Check for `sitemap-state.json`, resume if found (see `references/COMPLETION_GATES.md`)
2. **Clean up Chrome processes** - `pkill -f "mcp-chrome-" && sleep 2`
3. **Initialize or resume** - Start fresh or resume from saved state
4. **Navigate** - Install browser if needed, create tab, navigate to starting URL
5. **Extract links** - Find all internal links using `references/link-extraction.js`
6. **Check accessibility** - Verify each link using `references/status-check.js`
7. **Process queue exhaustively** - Follow algorithm from `references/QUEUE_ALGORITHM.md` until empty
8. **Progress tracking** - Log after every 10-20 pages (see `references/COMPLETION_GATES.md`)
9. **Completion gates** - Verify all gates pass (see `references/COMPLETION_GATES.md`)
10. **Generate sitemap** - Format as markdown table, save to workspace root
11. **Clean up** - Delete `sitemap-state.json` after successful completion

## Output Format

```markdown
# Sitemap: [Starting Page Title]

**Starting URL:** [URL]
**Generated:** [Date/Time]
**Total Pages Mapped:** [count]
**Dead Links:** [count]
**Max Depth:** 2 hops

## Summary Statistics

- Accessible Pages: [count]
- Dead Links (404): [count]
- Forbidden (403): [count]
- Server Errors (500): [count]
- Timeouts: [count]
- Files: [count]

## Pages

| Title | URL | Depth | Status | Links Found |
|-------|-----|-------|--------|-------------|
| [Page Title] | [URL] | 0 | Accessible (200) | [count] |
| [Page Title] | [URL] | 1 | Accessible (200) | [count] |
| [Page Title] | [URL] | 2 | Dead Link (404) | N/A |
```

**Status values:** Accessible (200) | Dead Link (404) | Forbidden (403) | Server Error (500) | Timeout | File (downloadable)

**Depth values:** 0 (starting page) | 1 (links from starting page) | 2 (links from depth 1 — max depth)

**File naming:** `sitemap-[sanitized-starting-url]-[timestamp].md` saved to workspace root

## Requirements

1. **Autonomous execution** - No confirmation requests, process until complete
2. **Complete link discovery** - Find ALL internal links on each page
3. **Exhaustive recursive mapping** - Follow ALL internal links up to 2 hops deep
4. **Accessibility checking** - Check HTTP status for every link
5. **Track visited URLs** - Normalize: remove hash fragments and trailing slashes
6. **State persistence** - Save to `sitemap-state.json` after every 10-20 pages
7. **Completion verification** - Verify queue empty and all links processed before generating sitemap

## Queue-Based Algorithm

**Implement the algorithm from `references/QUEUE_ALGORITHM.md`.**

Summary:
1. Initialize: `visitedUrls` (Set), `pages` (Array), `queue` (Array of `{url, depth}`)
2. Process starting page (depth 0), extract links, add to queue with depth 1
3. Process queue until empty:
   - Pop next item, normalize URL
   - Skip if visited or depth > 2
   - Navigate, check accessibility, extract links
   - If accessible and depth < 2: add discovered links to queue with depth + 1
   - If error: add to pages with error status, do NOT add links
4. Save state every 10-20 pages
5. Verify completion when queue is empty

**For file downloads:** Check accessibility but do NOT add to queue. Mark as File status.

## State Persistence

```json
{
  "startingUrl": "https://...",
  "startingTitle": "...",
  "visitedUrls": ["url1", "url2"],
  "pages": [
    {"title": "...", "url": "...", "depth": 0, "status": "Accessible (200)", "linksFound": 16}
  ],
  "queue": [
    {"url": "...", "depth": 1}
  ],
  "lastUpdated": "2026-01-28T14:00:00Z"
}
```

**Resume:** ALWAYS check for state file at start. If exists, resume from queue. On completion, delete state file.

## Error Recovery

**NEVER stop processing due to errors. Always continue with next item in queue.**

| Error | Action |
|-------|--------|
| "Failed to launch browser process" | `pkill -f "mcp-chrome-" && sleep 2`, retry up to 3 times, mark as error |
| Navigation timeout | Mark as timeout, continue |
| 404/403/500 | Mark with appropriate status, continue |
| State file corrupted | Backup, start fresh |

## Troubleshooting

If navigation fails:
1. Chrome processes cleaned? → `pkill -f "mcp-chrome-" && sleep 2`
2. Browser installed? → Call `browser_install`
3. Tab exists? → `browser_tabs(action: "list")`, create if needed
4. URL valid? → Check `https://`, no typos
5. Authenticated? → Ensure user is logged in

## Completion Gates

**ALL 3 gates must pass before generating sitemap. See `references/COMPLETION_GATES.md` for full implementation.**

| Gate | Checks | If fails |
|------|--------|----------|
| Gate 1: State | Queue is empty (`queue.length === 0`) | Continue processing |
| Gate 2: Progress | All discovered links processed or marked as error | Process remaining |
| Gate 3: Output | Sitemap file exists and is non-empty | Generate sitemap |

**Completion criteria (ALL must be true):**
1. Queue empty | 2. All links processed | 3. State saved | 4. Output generated | 5. All gates passed

**If ANY criterion fails, work is NOT complete. Continue processing.**

## Common Mistakes to Avoid

- DO NOT stop when you've "demonstrated the pattern" — process ALL links
- DO NOT skip URLs because "there are too many"
- DO NOT mark URLs as visited before actually processing them
- DO NOT generate sitemap while queue still has items
- DO extract ALL links from every accessible page before moving on

## Handoff to extract-webpage-content

The sitemap file can be used as input to `extract-webpage-content`. Users can edit the sitemap file to remove URLs they don't want extracted before running content extraction.

## Detailed Reference

- `references/QUEUE_ALGORITHM.md` - Queue-based recursive mapping algorithm
- `references/COMPLETION_GATES.md` - Gate implementation, resume logic, progress tracking
- `references/link-extraction.js` - Link discovery and normalization (canonical version)
- `references/status-check.js` - Page accessibility checking
