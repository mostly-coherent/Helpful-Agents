# Detailed Workflow Implementation Guide

This document contains detailed implementation notes for extract-webpage-content that complement the main SKILL.md file.

## Step 1: Determine Input Type and Extract URLs

### Sitemap File Parsing

When a sitemap file is provided:
1. Read the sitemap file from workspace root or path provided by user
2. Find machine-readable section: `## Machine-Readable URL List (for extract-webpage-content)`
3. Extract URLs using `references/sitemap-parser.js`
4. Only extract accessible URLs (✅ status) and files (📄)
5. Skip dead links (❌), forbidden (🔒), and errors (⚠️)
6. Group URLs by depth level (0, 1, 2, 3) and separate files

**Processing Mode:**
- **Single URL mode:** Extract from one URL, recursively follow links up to 2 hops deep
- **Sitemap mode:** Extract from all URLs in sitemap file, respecting depth levels from sitemap (no additional recursive following)

### Navigation Workflow

1. **CRITICAL: Clean Up Conflicting Chrome Processes (AUTOMATIC):**
   - Run `pkill -f "mcp-chrome-" && sleep 2` via terminal
   - This prevents "Failed to launch the browser process" errors
   - Execute automatically FIRST before any browser operations

2. **Check/Install Browser:**
   - Call `browser_install` if browser is not installed
   - If fails with "Failed to launch" error: Go back to step 1 and retry cleanup

3. **Check Existing Tabs:**
   - Call `browser_tabs` with `action: "list"` to see if any tabs exist
   - If no tabs exist, create one: `browser_tabs` with `action: "new"`
   - If fails with "Failed to launch" error: Go back to step 1 and retry cleanup

4. **Navigate to URL:**
   - Call `browser_navigate` with the target URL
   - URL must be complete, valid URL (include `https://`)
   - If fails with "Failed to launch" error: Go back to step 1 and retry cleanup

5. **Wait for Page Load:**
   - Use `browser_wait_for` with `time: 3` to allow page to load
   - Or wait for specific text: `browser_wait_for` with `text: "[expected page content]"`

6. **Verify Navigation Success:**
   - Use `browser_snapshot` to verify page loaded correctly
   - Check for error messages or redirects

## Step 2: Expand All Dynamic Content

**CRITICAL:** This step must extract content from ALL tabs, not just click them. Each tab panel's content must be captured.

Use `references/expand-dynamic-content.js` via `browser_evaluate`:
- Finds tabs using multiple selectors (`[role="tab"]`, `.tab`, `button[class*="tab"]`, etc.)
- Clicks each tab sequentially, waits for content to load (1500ms per tab)
- Extracts content from each tab panel (`[role="tabpanel"]` or visible content)
- Filters out navigation elements before extracting text
- Expands all accordions/collapsible sections
- Navigates carousel slides (if present)

**After expanding tabs:** The extraction step (Step 3) must include the extracted tab content. Tab content should be inserted into the document in the appropriate section where the tabs appear.

## Step 3: Extract Text Content with Image Position Markers

**CRITICAL:** Extract text while marking where images appear in the content flow. **MUST incorporate tab content extracted in Step 2.** **MUST filter out navigation elements before extracting text.**

**Navigation Element Removal (CRITICAL):**
- Remove DOM elements: `nav, header, footer, .nav, .header, .footer, .navigation, [role="navigation"], [role="banner"], [role="complementary"], script, style`
- Remove text patterns: "User Guide Cancel", "Search", "Get help faster...Create an account", "On this page:", JavaScript code blocks, CSS rules
- Clean excessive whitespace: Replace 3+ spaces with single space, replace 3+ newlines with double newline

**Tab Content Insertion:**
- Find the section heading that precedes the tabs (e.g., "Important Terms and Definitions")
- Insert all tab content as subsections under that heading
- Format each tab as: `### [Tab Name]\n\n[Tab Content]\n`
- Maintain the order of tabs as they appear on the page

## Step 4: Identify and Capture Content Images

**CRITICAL:** Only capture images that are **core content**, not decorative elements.

**IMPORTANT:** This step MUST always be executed, even if no content images are found. Some pages (especially text-heavy policy documents) may legitimately have no content images - this is not an error.

**🚨 CRITICAL FOR RECURSIVE EXTRACTION:** This step MUST execute for EVERY page at EVERY depth level (initial page AND all recursive pages). Image extraction is NOT optional during recursive extraction.

**Content Images to Capture:**
- ✅ Images containing text/instructions (screenshots that should have been text)
- ✅ Screenshots of applications showing where to click/look
- ✅ Diagrams, charts, or visual guides that convey information
- ✅ Images that are essential to understanding the page content

**Decorative Images to Skip:**
- ❌ Logos and branding elements
- ❌ Navigation arrows and buttons
- ❌ Wayfinding icons (home, search, menu icons)
- ❌ Decorative backgrounds or patterns
- ❌ Social media icons
- ❌ Small icons used for visual decoration only

Use `references/image-filtering.js` via `browser_evaluate` to identify content images.

**Image Saving (ALWAYS performed, regardless of output format):**

**Filename Generation:**
- Format: `[page-slug]-image-[N]-[context].png`
- `[page-slug]`: Sanitized page title (lowercase, hyphens)
- `[N]`: Sequential number (1, 2, 3...) based on document order
- `[context]`: Short context identifier from nearby text (optional, max 30 chars)
- `[ext]`: Original format (.png, .jpg, .svg) or .png for screenshots

**Saving Process:**
1. Extract page headline/title from the webpage (use `<h1>` or page title)
2. Sanitize folder name from headline (lowercase, hyphens, no spaces, remove special chars)
3. Determine base directory (from user request or default to workspace/current directory)
4. Create page folder: `[base-directory]/[Page_Title]/` (if it doesn't exist)
5. Sort images by document position (top to bottom, left to right)
6. For each image (in order):
   - Generate filename: `[page-slug]-image-[N]-[context].[ext]`
   - **If `canDownload: true`:** Attempt direct download via `browser_evaluate` (fetch as blob/base64)
   - **If `canDownload: false`:** Use `browser_take_screenshot` with coordinates `{x, y, width, height}`
   - Save to `[base-directory]/[Page_Title]/[exact-filename]` (same folder as Markdown file)
   - Store mapping: `{filename, alt, title, position}` for document insertion

7. **Track image-to-filename mapping** to ensure document references match saved files exactly
8. **For nested/embedded links:** Repeat process in `[base-directory]/[Page_Title]/[Nested_Page_Title]/` folder

**Image Position Tracking:**
- Images are inserted in the document **at their original position** in the content flow
- Not all dumped at the end - they appear where they belong in the text
- Filename includes position number to maintain order

## Step 5: Extract Embedded Links

**CRITICAL:** This step MUST identify all internal links that should be extracted recursively.

**🚨 IMPORTANT:** Links include BOTH HTML pages (for recursive extraction) AND downloadable files (PDFs, DOCs, etc. for direct download). The extraction process handles these differently:
- **HTML pages:** Extracted recursively (navigate, extract content, create nested folders)
- **Downloadable files:** Downloaded directly (fetch file, save to parent folder, no recursive extraction)

Use `references/link-extraction.js` via `browser_evaluate`:
- Extracts all internal links (same domain)
- Identifies downloadable files (PDFs, DOCs, etc.) - mapped but not recursively followed
- Normalizes URLs (removes hash fragments, trailing slashes)
- Filters out anchors (#), javascript:, mailto:, tel: links

## Step 6: Recursive Link Extraction (2-Hop Limit)

**🚨 CRITICAL: This step behavior depends on input mode:**

**Single URL Mode:**
- MUST execute for ALL internal links found in Step 5
- Recursive extraction is NOT optional
- Follow links recursively up to 2 hops deep

**Sitemap Mode:**
- Extract URLs from sitemap file in order (already parsed in Step 1a)
- Do NOT recursively follow links from extracted pages (sitemap already contains all URLs to extract)
- Respect depth levels from sitemap (extract depth 0, then depth 1, then depth 2)
- Process files (📄) separately for download only
- **CRITICAL:** In sitemap mode, Step 5 (Extract Embedded Links) is still executed for reference, but Step 6 uses URLs from sitemap instead of recursively following links

**Depth tracking:** Track extraction depth from the original URL.
- **Original URL:** Depth = 0 (main page folder)
- **Links from original page:** Depth = 1 (nested folder inside main folder)
- **Links from depth-1 pages:** Depth = 2 (maximum, nested folder inside depth-1 folder)

**Extraction process (MUST be executed for each link):**

1. **MUST execute for ALL internal links** found in Step 5 (not optional) - includes both HTML pages AND downloadable files (PDFs, DOCs, etc.)
2. **Track visited URLs globally** (across all depths) to prevent duplicate page/file extractions - if a URL has been extracted at any depth, skip it
3. **Normalize URLs before checking** - Remove hash fragments and trailing slashes for comparison
4. **Handle file downloads separately from page extraction:**
   - **For downloadable files (PDF, DOC, XLS, PPT, ZIP, etc.):**
     - Download file directly using `browser_evaluate` to fetch as blob/base64
     - Extract filename from URL or use link text
     - Save file to parent folder (same folder as the page that links to it)
     - Do NOT create nested folder for files - files go in the same folder as the linking page
     - Do NOT extract links from files (files don't have extractable links)
     - Reference downloaded file in Markdown: `[Link Text](filename.pdf)`
   - **For HTML pages:**
     - Navigate to the page
     - Extract headline/title
     - Create nested folder: `[parent-folder]/[Nested_Page_Title]/`
     - **Execute Steps 2-4 (expand dynamic content, extract text, capture images)**
       - **Step 2:** Expand all dynamic content (tabs, accordions, carousels)
       - **Step 3:** Extract text content with image position markers
       - **Step 4:** **MANDATORY** - Identify and capture ALL content images (filter decorative, save content images)
         - **CRITICAL:** Image extraction MUST execute for EVERY recursive page, not just initial page
         - Filter decorative images (logos, icons, navigation)
         - Capture content images (screenshots, diagrams, visual guides)
         - Save images to: `[parent-folder]/[Nested_Page_Title]/[image-filename]`
         - Generate image references for Markdown document
     - Save Markdown file: `[parent-folder]/[Nested_Page_Title]/[Nested_Page_Title]_Full_Content.md`
     - Extract links from this page
     - Recursively extract those links (depth + 1)
5. **Stop at depth 2** (do not go deeper) - applies only to HTML pages, not file downloads
6. **Handle errors gracefully** - if a linked page fails to load or file fails to download, log error and continue with next link

**Folder structure:**
- Main page: `[base-directory]/[Page_Title]/` (depth 0)
- First hop: `[base-directory]/[Page_Title]/[Nested_Page_Title]/` (depth 1)
- Second hop: `[base-directory]/[Page_Title]/[Nested_Page_Title]/[Nested_Page_Title_2]/` (depth 2)

## Step 7: Format and Save Output

**IMPORTANT:** Images are **ALWAYS saved as files** before creating the document. The output format choice only affects how images are referenced in the document.

**Markdown Format (Default):**

**CRITICAL:** Images must be inserted **at their exact position** in the content flow, not all at the end.

```markdown
# [Page Title]

## Content

[Text content before first image]

![Image 1: [alt text]]([page-slug]-image-1-[context].png)
*Caption: [alt text or title]*

[Text content between images]

![Image 2: [alt text]]([page-slug]-image-2-[context].png)
*Caption: [alt text or title]*

[Text content after images]

## Related Links

- [Link Text](link-url) → Extracted in: [Nested_Page_Title]/[Nested_Page_Title]_Full_Content.md
```

**Image Insertion Process:**
1. Extract text content with image position markers
2. For each image (in document order):
   - Find insertion point in text (where image appears in DOM)
   - Insert image reference: `![alt text]([exact-filename])` (same folder as Markdown file)
   - Use the **exact filename** that was saved (must match exactly)
   - **NO `screenshots/` prefix** - images are in the same folder as the Markdown file
3. Verify: Every image filename referenced in document exists in the same folder
4. Verify: Every image file in the folder is referenced in document

**Filename-Reference Matching:**
- Document references: `![alt](retention-policy-image-1-overview.png)`
- Saved file: `[Page_Title]/retention-policy-image-1-overview.png`
- **Must match exactly** - no mismatches allowed
- **Images and Markdown file are in the same folder**

**Word Format (Optional - on request):**
- Use appropriate library (e.g., `docx` for Node.js) to create structured Word documents
- **Embed images directly** in the document (images already saved in the page folder)
- Maintain heading hierarchy
- **Default:** Markdown format unless user explicitly requests Word format
- **Images are preserved either way** - Word format embeds them, Markdown references file paths

## Directory Structure & File Naming

### Base Directory Rules

**Base Directory:**
- **If user specifies a folder/directory in their request:**
  - Use that directory as the base path
  - Example: "Save to Commerce_Agent folder" → Base path is `Commerce_Agent/`
- **If no directory specified:**
  - Default to current workspace directory or the directory where the command was invoked
  - For `/extract-page` command: Use the directory of the file that's currently open, or workspace root

**🚨 CRITICAL: FORBIDDEN FOLDERS - NEVER save to these paths:**
- ❌ **NEVER save to:** `Commerce_Agent/Internal-Helpx Archive` or any path containing `Internal-Helpx Archive`
- ❌ **NEVER save to:** Any folder named `Internal-Helpx Archive` regardless of parent directory
- ✅ **If user requests saving to forbidden folder:** Use parent directory instead (e.g., if user says "Save to Commerce_Agent/Internal-Helpx Archive", save to `Commerce_Agent/` instead)
- ✅ **If current directory is forbidden:** Use workspace root or parent directory instead

### Directory Structure Example

```
[base-directory]/
└── individual-and-teams-retention-policy/          # Main page folder (from headline)
    ├── Individual_and_Teams_Retention_Policy_Full_Content.md
    ├── retention-policy-image-1-overview.png       # Images directly in folder
    ├── retention-policy-image-2-workflow.png
    └── cci-and-cct-retention-offers/              # Nested folder (from embedded link)
        ├── CCI_and_CCT_Retention_Offers_Full_Content.md
        ├── retention-offers-image-1-diagram.png
        └── process-privacy-requests/              # Nested again (depth 2)
            ├── Process_Privacy_Requests_Full_Content.md
            └── privacy-image-1-workflow.png
```

### File Naming

**Markdown Files:**
- **Main page:** `[Page_Title]_Full_Content.md` (inside `[Page_Title]/` folder)
- **Nested pages:** `[Nested_Page_Title]_Full_Content.md` (inside `[Nested_Page_Title]/` folder)

**Image Filenames (CRITICAL - must match document references exactly):**
- Format: `[page-slug]-image-[N]-[context].[ext]`
- `[page-slug]`: Sanitized page title (lowercase, hyphens, no spaces)
- `[N]`: Sequential number starting from 1 (based on document order)
- `[context]`: Short context identifier from nearby text (optional, max 30 chars)
- `[ext]`: Original format (.png, .jpg, .svg) or .png for screenshots
- Examples:
  - `retention-policy-image-1-overview.png`
  - `retention-policy-image-2-workflow-diagram.png`
  - `case-management-image-1-survey-triggers.png`

**Image File Location:**
- **All images saved to:** `[base-directory]/[Page_Title]/[exact-filename]` (same folder as Markdown file)
- **For nested pages:** `[base-directory]/[Page_Title]/[Nested_Page_Title]/[exact-filename]`
- **Document references:** `![alt]([exact-filename])` (relative path - same folder as Markdown file)
- **NO `screenshots/` subfolder** - images go directly in the page folder
- **Filename in document reference MUST match saved filename exactly**

## Error Handling & Troubleshooting

### Navigation Errors

- **"Failed to launch the browser process" / "Opening in existing browser session":**
  - **Error:** Chrome detects existing browser session and exits immediately
  - **Root cause:** Conflicting Chrome processes using Playwright's user data directory (`mcp-chrome-*`)
  - **Fix:** AUTOMATIC - Run `pkill -f "mcp-chrome-" && sleep 2` via terminal before attempting browser launch
  - **Prevention:** Always run cleanup step (step 1) before browser_install/browser_tabs/browser_navigate
  - **This is the most common failure mode** - handle automatically without user intervention

- **Browser not installed:** Call `browser_install` first, then retry navigation
- **No browser tabs:** Call `browser_tabs(action: "new")` to create a tab, then navigate
- **Navigation timeout:** Increase wait time with `browser_wait_for(time: 5)`, verify URL is correct
- **Invalid URL:** Ensure URL includes `https://` protocol, check for typos
- **Authentication redirect:** Expected for authenticated/internal sites - user must be authenticated in their browser session

### Content Extraction Errors

- **Authentication failures:** Inform user that page requires authentication (may need manual login first)
- **Dynamic content not expanding:** Retry with longer wait times, check for different selectors
- **Tab content not extracted:**
  - **Problem:** Tabs clicked but content not captured
  - **Causes:** Tab panels use non-standard selectors, content loads asynchronously, tabs use custom JavaScript
  - **Fix:** 
    1. Try multiple tab panel selectors (`[role="tabpanel"]`, `.tab-panel`, `[class*="tab-content"]`)
    2. Increase wait time after clicking tabs (500-1000ms)
    3. Check if content is injected directly into page (not in separate panel)
    4. Use fallback: Extract visible content after each tab click
    5. Verify tab content appears in final document (check verification checklist)
- **Recursive link extraction not executed:**
  - **Problem:** Main page extracted but linked pages not extracted
  - **Causes:** Step 6 not implemented, recursive logic skipped, depth tracking not working
  - **Fix:**
    1. **Verify Step 5 executed** - Check that embedded links were identified
    2. **Verify Step 6 executed** - Must iterate through ALL links from Step 5
    3. **Check depth tracking** - Ensure visited URLs tracked per depth level
    4. **Verify folder structure** - Check that nested folders were created
    5. **If no nested folders exist** - Step 6 was not executed, must re-run extraction
    6. **Log each link extraction** - Track which links succeeded/failed for debugging
- **Linked page extraction failures:** Log the failed URL and reason, continue with next link (don't stop entire extraction)
- **Image capture failures:** Log which images failed, continue with text extraction
- **Link extraction failures:** Log failed links, continue with successfully extracted content

### Troubleshooting Checklist

If navigation fails:
1. ✅ **Chrome processes cleaned?** → Run `pkill -f "mcp-chrome-" && sleep 2` FIRST (most common issue)
2. ✅ Browser installed? → Call `browser_install`
3. ✅ Tab exists? → Call `browser_tabs(action: "list")`, create if needed
4. ✅ URL valid? → Check includes `https://`, no typos
5. ✅ Page accessible? → Try opening URL manually in browser first
6. ✅ Authenticated? → For internal sites, ensure user is logged in
7. ✅ Wait sufficient? → Increase `browser_wait_for` time

**Priority Order:** Always check for conflicting Chrome processes FIRST (step 1) before attempting browser operations. This resolves 90% of launch failures.

## Quality Assurance

### Verification Checklist

Before marking extraction complete:
- [ ] **Base directory validated** - Checked that base directory does NOT contain `Internal-Helpx Archive` (if detected, parent directory used instead)
- [ ] **All tabs identified** (using multiple selectors: `[role="tab"]`, `.tab`, `button[class*="tab"]`, etc.)
- [ ] **All tabs clicked** (each tab clicked sequentially with wait time for content to load)
- [ ] **Tab content extracted from each tab panel** (content captured from `[role="tabpanel"]` or visible content after clicking)
- [ ] **Tab content stored** (each tab's content stored with tab name as key)
- [ ] **Tab content inserted into document** (tab content appears in correct section of final Markdown, formatted as subsections)
- [ ] All accordions expanded and content extracted
- [ ] All carousel slides navigated
- [ ] **Image extraction step executed** (Step 4 always executed, even if no images found)
- [ ] **CRITICAL:** Image extraction executed for BOTH initial page AND all recursive pages (every depth level)
- [ ] Content images identified and filtered (decorative images skipped)
- [ ] **If no content images found:** This is OK - some pages (especially text-heavy policy documents) have no content images
- [ ] **If images found:** Images sorted by document position (top to bottom, left to right)
- [ ] **If images found:** Filenames generated: `[page-slug]-image-[N]-[context].[ext]`
- [ ] **If images found:** All content images captured (downloaded or screenshotted)
- [ ] Page folder created: `[base-directory]/[Page_Title]/` (from sanitized headline)
- [ ] **If images found:** Images saved to `[base-directory]/[Page_Title]/[exact-filename]` (same folder as Markdown)
- [ ] **If images found:** Images inserted in document at their original position (not all at end)
- [ ] **If images found:** Document references use relative paths: `![alt]([filename])` (no `screenshots/` prefix)
- [ ] **For recursive pages:** Image extraction executed identically - images captured and saved to nested folders
- [ ] **If images found:** Document references match saved filenames exactly
- [ ] **If images found:** Verification: Every image file referenced in document exists in the same folder
- [ ] **If images found:** Verification: Every image file in folder is referenced in document
- [ ] **All embedded links identified** (Step 5 executed - all internal links extracted)
- [ ] **Recursive extraction executed** (Step 6 executed - Single URL mode: extract all linked pages recursively; Sitemap mode: extract URLs from sitemap in depth order)
- [ ] **Duplicate prevention** (URLs normalized and tracked globally across all depths - same URL extracted only once)
- [ ] **Nested folders created** for each embedded link: `[Page_Title]/[Nested_Page_Title]/`
- [ ] **Each linked page extracted** (navigate, expand dynamic content, extract text, capture images)
- [ ] **CRITICAL: Image extraction executed for ALL recursive pages** (Step 4 executed at every depth level - images captured identically for initial AND nested pages)
- [ ] **Nested pages saved** with their own Markdown + images in nested folders
- [ ] **Images saved for nested pages** (images captured and saved to nested folders: `[parent-folder]/[Nested_Page_Title]/[image-filename]`)
- [ ] **Linked pages extracted up to 2 hops deep** (depth 0 → depth 1 → depth 2, then stop)
- [ ] **Duplicate URLs skipped** (if a URL was extracted at any depth, skip it at other depths)
- [ ] **Links from nested pages also extracted** (Single URL mode: recursive extraction continues for links found in nested pages; Sitemap mode: only extract URLs from sitemap, do not follow additional links)
- [ ] **File downloads handled** (PDFs, DOCs, etc. downloaded and saved to parent folder, not extracted as pages)
- [ ] **Downloaded files referenced in Markdown** (file links in document point to downloaded files)
- [ ] **No files saved to forbidden folder** - Verify that NO files were saved to any path containing `Internal-Helpx Archive`
- [ ] Output file saved with proper formatting
- [ ] No content sections missed
