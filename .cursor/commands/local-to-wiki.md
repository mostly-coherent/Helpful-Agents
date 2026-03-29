# Local to Wiki

Convert Markdown to Confluence Storage Format, or sync local edits back to a Confluence wiki page.

## Mode 1: Convert Format

Convert a Markdown file to Confluence Storage Format ready for paste.

**Conversion rules:**
- `##` → `<h2>`, `###` → `<h3>` (no injected font-size styles)
- Markdown tables → Confluence table XML (auto-fit columns)
- Code blocks → `{code}` macro with language if specified
- Images → `<ri:attachment>` or absolute URL
- Links → `<ac:link>` where possible, otherwise `<a>`
- Insert info panel: "This page is auto-published from Cursor. Cosmetic edits here may not persist after republish."

Save output as a `.md` file for copy/paste into Confluence.

## Mode 2: Sync to Wiki

When a local markdown file is a newer version of an existing wiki page:

1. List the content differences between local and wiki
2. Ask for confirmation before proceeding
3. Update the Confluence page to align with local markdown

**Requires:** Confluence MCP with wiki access (optional on personal machines; Mode 1 still works for paste).

## Usage

`/local-to-wiki @my-doc.md` (convert format)
`/local-to-wiki @my-doc.md sync to <space>/<page>` (sync to wiki)
