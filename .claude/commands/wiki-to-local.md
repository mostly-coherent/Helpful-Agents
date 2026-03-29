# Wiki to Local

Convert a Confluence page (storage format or HTML) into clean, human-editable Markdown.

## Conversion Rules

1. Capture the main title as top-level heading (`# Title`)
2. Keep headings (H2 → `##`, H3 → `###`), lists, blockquotes
3. Convert Confluence tables to GitHub-flavored Markdown tables
4. Keep code blocks as fenced ``` blocks with language if specified
5. Convert internal page anchors/links to standard Markdown links
6. Inline images: use Markdown image syntax, preserve relative paths

## Strip These

- `ac:structured-macro`, span styles, inline font sizes/colors, width attributes
- Non-semantic `<div>`/`<span>` wrappers
- Empty formatting blocks

## Post-Processing

- Ensure top-level sections use `##`
- Collapse multiple blank lines to single
- Keep code fences, links, images intact
- Do not generate new content or paraphrase — only normalize format

## Output

Save as a new `.md` file in the current directory. Report the file path.

## Usage

`/wiki-to-local` (provide Confluence page content in chat)
