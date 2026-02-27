# PDF to Markdown

Convert a PDF document to well-structured Markdown using Docling. Preserves structure, tables, and formatting.

## Usage

`/pdf-to-markdown` or `/pdf-to-markdown @path/to/document.pdf`

Provide the PDF file path (or @-mention it). Outputs Markdown to same directory by default, or to specified path.

## Steps

1. **Resolve input** — Use the @-mentioned file or path from the message
2. **Install Docling** (if needed): `pip install docling`
3. **Convert**: `docling "source.pdf" -o output.md` (or `docling "source.pdf"` for same-name .md)
4. **Verify** — Check that structure, tables, and formulas were preserved
5. **Report** — Confirm output path and any issues

## Commands

```bash
# Basic (creates source.md in same directory)
docling "document.pdf"

# Custom output
docling "document.pdf" -o output-filename.md

# Batch
for f in *.pdf; do docling "$f" -o "${f%.pdf}.md"; done
```

## Notes

- Docling supports PDF, DOCX, PPTX, XLSX, HTML, images
- Runs locally for data privacy
- For installation issues: `pip install docling`
