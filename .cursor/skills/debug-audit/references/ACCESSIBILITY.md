# Accessibility Reference (WCAG 2.1 AA)

## Quick Checklist

| Check | Requirement |
|-------|-------------|
| **Color Contrast** | Text: 4.5:1 minimum; Large text: 3:1; UI components: 3:1 |
| **Focus Visible** | All interactive elements must show focus state |
| **Keyboard Access** | All functionality available via keyboard |
| **Alt Text** | All informative images have descriptive alt text |
| **Form Labels** | Every input has associated label |
| **Error Messages** | Form errors are announced to screen readers |
| **Heading Hierarchy** | Logical h1→h2→h3 structure |
| **Link Purpose** | Link text describes destination (no "click here") |

## Detailed Requirements

### Color Contrast Ratios

| Element Type | Minimum Ratio | Tool to Check |
|--------------|---------------|---------------|
| Normal text (< 18px) | 4.5:1 | WebAIM Contrast Checker |
| Large text (≥ 18px or 14px bold) | 3:1 | |
| UI components (buttons, inputs) | 3:1 | |
| Non-text contrast (icons, borders) | 3:1 | |

### Common Violations

| Issue | Detection | Fix |
|-------|-----------|-----|
| Gray text on white | `.text-gray-400` on `.bg-white` | Use `.text-gray-600` or darker |
| Placeholder text too light | Default placeholder styling | Custom darker placeholder |
| Focus ring invisible | `outline-none` without replacement | Add visible focus state |
| Button without accessible name | `<button><Icon /></button>` | Add `aria-label` |

### Semantic HTML

| Instead of | Use |
|------------|-----|
| `<div onClick>` | `<button>` |
| `<span>` for navigation | `<nav>` |
| `<div>` for sections | `<section>`, `<article>`, `<aside>` |
| `<div>` for lists | `<ul>`, `<ol>`, `<li>` |
| `<b>`, `<i>` for meaning | `<strong>`, `<em>` |

### ARIA Guidelines

**Use ARIA only when native HTML isn't sufficient:**

| Pattern | When to Use |
|---------|-------------|
| `aria-label` | When visible text isn't descriptive enough |
| `aria-describedby` | For additional context (error messages, hints) |
| `aria-hidden="true"` | Decorative elements that should be ignored |
| `aria-live` | Dynamic content updates |
| `role="button"` | Non-button elements acting as buttons (avoid if possible) |

### Keyboard Navigation

| Element | Required Keys |
|---------|---------------|
| Buttons | Enter, Space |
| Links | Enter |
| Dropdowns | Arrow keys, Enter, Escape |
| Modals | Tab trap, Escape to close |
| Tabs | Arrow keys, Tab for content |

### Form Accessibility

```html
<!-- Good: Label associated with input -->
<label for="email">Email</label>
<input id="email" type="email" aria-describedby="email-hint" />
<span id="email-hint">We'll never share your email</span>

<!-- Good: Error handling -->
<input id="email" aria-invalid="true" aria-describedby="email-error" />
<span id="email-error" role="alert">Please enter a valid email</span>
```

### Testing Tools

| Tool | Purpose |
|------|---------|
| **axe DevTools** | Browser extension for automated checks |
| **Lighthouse** | Built into Chrome DevTools |
| **WAVE** | Visual accessibility checker |
| **Screen reader** | VoiceOver (Mac), NVDA (Windows) |
| **Keyboard only** | Navigate without mouse |
