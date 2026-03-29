# List Questions

Extract all open questions from the referenced document.

## Steps

1. Add a concise context prefix that identifies the topic/section
2. Group related questions under the same prefix
3. Remove unnecessary verbiage while preserving meaning
4. Expand any unclear abbreviations inline
5. Format as a clean, copyable list

## Output Format

```
[Topic]: [concise question]
[Topic]:
  - [sub-question 1]
  - [sub-question 2]
```

Present the final list in a code block for easy copying.

## Usage

`/list-questions @filename.md`
