---
name: extract-page-shallow
description: Extract complete content from a single webpage and its direct links only (depth 0 + depth 1). Does NOT recursively follow links beyond the first level. Use when you need focused extraction without deep crawling. Use when user requests extracting a webpage and its immediate linked pages, shallow extraction, or wants to avoid deep recursive crawling.
---

# Extract Page Shallow

Extract complete content from a single webpage and its direct links only (depth 0 + depth 1). Does NOT recursively follow links beyond the first level. Use when you need focused extraction without deep crawling.

## When to Use

Use this skill when:
- User requests extracting a webpage and its immediate linked pages
- User wants shallow extraction (page + direct links only)
- User mentions "extract this page and links" or "shallow extraction"
- User wants to avoid deep recursive crawling

**Do NOT use when:**
- User needs deep recursive extraction (use `extract-webpage-content` instead)
- User wants to browse or navigate pages manually

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `extract-webpage-content` | Use instead for deeper extraction (depth 0 + 1 + 2) or sitemap-based extraction |
| `extract-sitemap` | Use first to preview site structure before deciding extraction depth |

## Execution Model

**Execute autonomously** - Complete the entire workflow without user approval for each action.

**CRITICAL - NO CONFIRMATION REQUESTS:**
- NEVER ask "Should I continue?" or for approval between pages
- ALWAYS continue until all direct links are extracted
- ONLY report progress updates, never ask for permission

**Required tools:** Playwright MCP (`user-playwright`) - does NOT require per-action approval
**Do NOT use:** cursor-ide-browser MCP - requires per-action approval (not suitable)

## Scope

| Depth | What | Extracted? |
|-------|------|-----------|
| 0 | Starting page (user-provided URL) | Yes |
| 1 | Direct links found on starting page | Yes |
| 2+ | Links from depth 1 pages | **NO** (key difference from extract-webpage-content) |

## Workflow

1. **Navigate to starting page** (Depth 0)
   - Clean up Chrome processes: `pkill -f "mcp-chrome-" && sleep 2`
   - Navigate to target URL
   - Expand all dynamic content (accordions, tabs, etc.) — see `references/REFERENCE.md`

2. **Extract starting page content** (Depth 0)
   - Extract all text content (headings, paragraphs, lists)
   - Capture full-page screenshot
   - Extract all internal links found on this page
   - Save to folder: `[Page_Title]/[Page_Title]_Full_Content.md`

3. **Extract direct linked pages** (Depth 1)
   - For each internal link found on starting page:
     - Navigate to linked page
     - Expand dynamic content
     - Extract text content
     - Capture screenshot if needed
     - Save to: `[Page_Title]/[Linked_Page_Title]/[Linked_Page_Title]_Full_Content.md`
   - **DO NOT extract links from depth 1 pages** (no depth 2)

4. **Progress tracking** - Report every 5-10 pages

5. **Completion verification** - Verify all gates pass before reporting done

6. **Save output** - Markdown files in nested folder structure, images alongside

## Output Format

**Directory Structure:**
```
[Page_Title]/
  [Page_Title]_Full_Content.md
  [page-title]-image-1.png
  [Linked_Page_1]/
    [Linked_Page_1]_Full_Content.md
  [Linked_Page_2]/
    [Linked_Page_2]_Full_Content.md
```

**Markdown Format:**
- Images inserted at position in content flow
- Images saved as files in same folder (NO `screenshots/` subfolder)
- Document references: `![alt](filename.png)` (relative path)

## Requirements

1. **Autonomous execution** - No user approval needed between pages
2. **Complete extraction** - Expand all dynamic elements
3. **Filter decorative images** - Only content images (skip logos, icons, nav)
4. **Shallow only** - NEVER extract beyond depth 1
5. **Structured output** - Nested folders with descriptive names
6. **Progress reporting** - Log every 5-10 pages

## Error Recovery

**NEVER stop processing due to errors. Always continue with next page.**

| Error | Action |
|-------|--------|
| "Failed to launch browser" | `pkill -f "mcp-chrome-" && sleep 2`, retry up to 3 times |
| Navigation timeout | Mark as error, continue with next page |
| 404/403/500 | Log error, skip page, continue |
| Authentication required | Log warning, skip page, continue |

## Completion Gates

**ALL gates must pass before reporting work complete.**

| Gate | Checks | If fails |
|------|--------|----------|
| Gate 1: Depth 0 | Starting page extracted successfully | Re-extract starting page |
| Gate 2: Depth 1 | All direct links extracted or marked as error | Extract remaining links |
| Gate 3: Output | All extracted pages have output files | Generate missing files |
| Gate 4: No depth 2 | Zero depth 2 pages extracted | Remove any depth 2 extractions |

**Completion criteria (ALL must be true):**
1. Starting page extracted
2. All direct links processed (extracted or error)
3. All output files exist and are non-empty
4. NO depth 2 pages extracted

**No state persistence needed** — this skill runs quickly (minutes, not hours). If interrupted, start fresh.

## Example Usage

**User:** "Extract this page and its direct links: https://example.com/course"

**Agent:**
1. Extracts https://example.com/course (depth 0)
2. Finds 15 internal links on the page
3. Extracts each of those 15 pages (depth 1)
4. **STOPS** - does not follow links from those 15 pages
5. Reports: "Extracted 1 page at depth 0, 15 pages at depth 1. Total: 16 pages."

## Detailed Reference

See `references/REFERENCE.md` for:
- Complete extraction algorithm pseudocode
- Dynamic content expansion logic
- Link filtering and normalization
- Content extraction and markdown formatting
- Error recovery with exponential backoff
- Completion verification implementation
