---
name: extract-webpage-content
description: Extract all content from internal webpages including text, images, collapsible sections (accordions, tabs, carousels), and embedded links. Accepts either a single URL or a sitemap file (from extract-sitemap) as input. Use Playwright MCP to navigate, expand all dynamic elements, capture screenshots, and extract pages. Save output as Markdown or Word documents. Extracts depth 0 + 1 + 2 only (starting page + direct links + links-from-links, no deeper). Use when the user requests extracting webpage content, copying page content, archiving internal documentation, or extracting from a sitemap file.
---

# Extract Webpage Content

Extract complete content from internal authenticated webpages, including all visible text, images, collapsed content (accordions, tabs, carousels), and embedded links. Accepts either a single URL (with recursive link following) or a sitemap file (from `extract-sitemap`) for curated extraction.

## When to Use

Use this skill when:
- User requests extracting webpage content
- User wants to copy or archive internal documentation
- User needs to capture content from authenticated sites
- User mentions "extract page," "copy page content," or "archive documentation"
- User provides a sitemap file (from `extract-sitemap`) to extract content from curated URLs

**Do NOT use when:**
- User wants to browse or navigate pages manually
- User needs real-time page interaction (use cursor-ide-browser instead)

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `extract-sitemap` | Run first to preview site structure; its output file can be used as input to this skill |
| `extract-page-shallow` | Lighter alternative for depth 0 + 1 only (no depth 2) |

## Execution Model

**Execute autonomously** - Complete the entire workflow without user approval for each action.

**CRITICAL - NO CONFIRMATION REQUESTS:**
- NEVER ask "Should I continue?" or "Do you want me to pause?"
- NEVER ask for approval between pages or batches
- ALWAYS continue until all pages are extracted
- ONLY report progress updates, never ask for permission

**Required tools:** Playwright MCP (`user-playwright`) - does NOT require per-action approval
**Do NOT use:** cursor-ide-browser MCP - requires per-action approval (not suitable)

## Input Types

**Single URL Mode:**
- Extract from one URL plus 2 levels of linked pages (depth 0 + 1 + 2)
- Depth 0: Starting page | Depth 1: Direct links (hop 1) | Depth 2: Links from depth 1 (hop 2)
- **Stops at depth 2** - does NOT follow links from depth 2 pages

**Sitemap Mode:**
- Extract from all URLs in sitemap file, respecting depth levels from sitemap
- Do NOT recursively follow links (sitemap already contains all URLs)
- Parse URLs from machine-readable section using `references/sitemap-parser.js`

## Workflow

1. **Resume Logic** - Check for `extraction-state.json`, resume if found (see `references/COMPLETION_GATES.md`)
2. **Determine Input Type** - Check if user provided sitemap file or single URL
3. **Navigate** - Clean up Chrome processes, navigate to target URL(s)
4. **Expand Dynamic Content** - Click all tabs, expand all accordions, navigate carousels (see `references/expand-dynamic-content.js`)
5. **Extract Text** - Capture text content with image position markers, filter navigation elements
6. **Filter & Capture Images** - Identify content images (skip decorative), take screenshots (see `references/image-filtering.js`)
7. **Extract Links** - Find all internal links on the page (see `references/link-extraction.js`)
8. **Recursive Extraction** - Extract each linked page using queue algorithm (see `references/RECURSIVE_EXTRACTION_ALGORITHM.md`)
   - **NEVER ask for confirmation** - Continue extracting all pages automatically
9. **Progress tracking** - Log progress after every 5-10 pages (see `references/COMPLETION_GATES.md`)
10. **Completion gates** - Verify all gates pass before proceeding (see `references/COMPLETION_GATES.md`)
11. **Save Output** - Format as Markdown, save to nested folder structure (only after gates pass)

## Output Format

**Markdown Format (Default):**
- Images inserted at their exact position in content flow
- Images saved as files in same folder as Markdown
- Document references: `![alt]([exact-filename])` (relative path)

**Word Format (Optional - on request):**
- Images embedded directly in document
- Maintain heading hierarchy
- Default: Markdown unless user explicitly requests Word format

## Directory Structure

**Main Page (Depth 0):** `[base-directory]/[Page_Title]/[Page_Title]_Full_Content.md` + images
**Nested Pages (Depth 1-2):** `[parent-folder]/[Nested_Page_Title]/[Nested_Page_Title]_Full_Content.md` + images
**Base Directory:** Use directory specified by user, or workspace root if not specified
**FORBIDDEN:** Never save to paths containing `Internal-Helpx Archive`

## File Naming

| Type | Format | Example |
|------|--------|---------|
| Markdown | `[Page_Title]_Full_Content.md` | `Retention_Policy_Full_Content.md` |
| Images | `[page-slug]-image-[N]-[context].[ext]` | `retention-policy-image-1-overview.png` |

Images saved to same folder as Markdown (NO `screenshots/` subfolder). Filename in document reference MUST match saved filename.

## Requirements

1. **Autonomous execution** - Execute entire workflow without user approval (NEVER ask for confirmation)
2. **Complete extraction** - Expand all dynamic elements, capture all content
3. **Filter decorative images** - Only content images (screenshots, diagrams), skip logos/icons/navigation
4. **Follow embedded links** - Extract depth 0 + 1 + 2 only (single URL mode only)
5. **Track visited URLs** - Prevent duplicate extractions and infinite loops
6. **Structured output** - Nested folder structure with descriptive names from page headlines
7. **State persistence** - Save progress to `extraction-state.json` after every 5-10 pages
8. **Queue-based extraction** - Use algorithm from `references/RECURSIVE_EXTRACTION_ALGORITHM.md`
9. **Completion verification** - Verify all gates pass (see `references/COMPLETION_GATES.md`)

## State Persistence

Save progress to `extraction-state.json` after every 5-10 pages:

```json
{
  "startingUrl": "https://...",
  "startingTitle": "...",
  "visitedUrls": ["url1", "url2"],
  "extractedPages": [
    {"title": "...", "url": "...", "depth": 0, "folder": "...", "status": "complete"}
  ],
  "pendingUrls": [
    {"url": "...", "depth": 1, "parentFolder": "..."}
  ],
  "lastUpdated": "2026-01-28T14:00:00Z"
}
```

**Resume:** ALWAYS check for state file at start. If exists, resume from `pendingUrls` queue. On completion, delete state file.

## Recursive Extraction Algorithm

**You MUST implement the queue-based algorithm from `references/RECURSIVE_EXTRACTION_ALGORITHM.md`.**

Summary:
1. Initialize: `visitedUrls` (Set), `extractedPages` (Array), `pendingUrls` (Queue)
2. Process starting page (depth 0), extract links, add to queue with depth 1
3. Process queue until empty: pop item, skip if visited or depth > 2, process page, add new links
4. Save state every 5-10 pages
5. Verify completion when queue is empty

**For file downloads:** Download directly, save to parent folder, do NOT add to queue.

## Error Recovery

**NEVER stop processing due to errors. Always continue with next item in queue.**

| Error | Action |
|-------|--------|
| "Failed to launch browser process" | Run `pkill -f "mcp-chrome-" && sleep 2`, retry up to 3 times, then mark as error and continue |
| Navigation timeout | Mark as timeout, continue with next URL |
| 404/403/500 | Mark with appropriate status, continue with next URL |
| State file corrupted | Backup (`mv extraction-state.json extraction-state.json.backup`), start fresh |

## Troubleshooting

If navigation fails:
1. Chrome processes cleaned? → `pkill -f "mcp-chrome-" && sleep 2`
2. Browser installed? → Call `browser_install`
3. Tab exists? → `browser_tabs(action: "list")`, create if needed
4. URL valid? → Check `https://`, no typos
5. Authenticated? → Ensure user is logged in

## Completion Gates

**BEFORE marking complete, ALL 3 gates must pass. See `references/COMPLETION_GATES.md` for full implementation.**

| Gate | Checks | If fails |
|------|--------|----------|
| Gate 1: State | Queue is empty (`pendingUrls.length === 0`) | Continue extracting |
| Gate 2: Progress | All discovered links processed or marked as error | Process remaining URLs |
| Gate 3: Output | All extracted pages have output files | Generate missing files |

**Completion criteria (ALL must be true):**
1. Queue empty | 2. All links extracted | 3. State saved | 4. Output generated | 5. All gates passed

**If ANY criterion fails, work is NOT complete. Continue extracting.**

## Detailed Reference

- `references/DETAILED_WORKFLOW.md` - Complete step-by-step workflow with checklists
- `references/RECURSIVE_EXTRACTION_ALGORITHM.md` - Queue algorithm pseudocode
- `references/COMPLETION_GATES.md` - Gate implementation, resume logic, progress tracking
- `references/expand-dynamic-content.js` - Tab/accordion expansion logic
- `references/image-filtering.js` - Image identification and filtering
- `references/link-extraction.js` - Link discovery and normalization
- `references/sitemap-parser.js` - Sitemap file parsing
