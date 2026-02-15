# List Conflicts

Extract all conflicting facts from the referenced document.

## Steps

1. Add a concise context prefix that identifies the topic/section
2. Group related conflicts under the same prefix
3. Remove unnecessary verbiage while preserving meaning
4. Expand any unclear abbreviations inline
5. Format as a clean, copyable list

## Output Format

```
[Topic]: [concise conflict]
[Topic]:
  - [sub-conflict 1]
  - [sub-conflict 2]
```

Present the final list in a code block for easy copying.

## Usage

`/list-conflicts @filename.md`
