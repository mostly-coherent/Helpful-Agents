# Extract Design System - Reference

Supplementary material for the extract-design-system skill. Covers edge cases, advanced extraction patterns, and design analysis heuristics.

## CSS Properties to Extract (Complete List)

### Colors (Priority: High)

| Source | Properties | Notes |
|--------|-----------|-------|
| Text | `color` | Primary text, secondary text, muted text, link color |
| Backgrounds | `background-color`, `background-image` (gradients) | Surface colors, overlays |
| Borders | `border-color`, `outline-color` | Subtle borders, focus rings |
| Shadows | `box-shadow` (color component) | Shadow color often reveals accent/brand |
| Accents | `accent-color`, `caret-color` | Form element theming |
| Selection | `::selection` background/color | Often brand-colored |

**Color Grouping Heuristic:**
- **Primary**: Most prominent brand color (buttons, links, CTAs)
- **Secondary**: Supporting brand color (less prominent)
- **Accent**: Highlight/contrast color (badges, notifications)
- **Neutral**: Grays used for text, borders, backgrounds (build a 50-950 scale)
- **Surface**: Background layers (page bg, card bg, modal bg, elevated bg)
- **Semantic**: Success (green), Warning (amber/yellow), Error (red), Info (blue)

### Typography (Priority: High)

| Property | Extract From | Notes |
|----------|-------------|-------|
| `font-family` | h1-h6, p, body, button, input | Usually 2-3 families max |
| `font-size` | All text elements | Build a scale (xs through 5xl) |
| `font-weight` | All text elements | Usually 400 (body), 500-600 (semi), 700+ (bold) |
| `line-height` | All text elements | Usually 1.2-1.4 for headings, 1.5-1.75 for body |
| `letter-spacing` | Headings, uppercase text | Tight for headings, wide for uppercase labels |
| `text-transform` | Buttons, labels, nav | uppercase, capitalize patterns |
| `font-style` | Emphasis, quotes | italic usage |
| `text-decoration` | Links | underline, none, hover behavior |
| `font-variant` | Numbers, small-caps | tabular-nums for data, small-caps for labels |

**Font Loading Clue**: Check `<link>` tags and `@font-face` rules for exact font files/services (Google Fonts, Adobe Fonts, self-hosted).

### Spacing (Priority: High)

| Property | Context | Notes |
|----------|---------|-------|
| `padding` (all sides) | Containers, cards, buttons | Internal spacing |
| `margin` (all sides) | Sections, elements | External spacing |
| `gap`, `row-gap`, `column-gap` | Flex/Grid containers | Grid spacing |
| `max-width` | Containers, content areas | Content width constraints |
| `width` | Fixed-width elements | Column widths, sidebar widths |

**Spacing Scale Heuristic:**
1. Collect all unique spacing values
2. Convert to px
3. Find the base unit (GCD -- usually 4px or 8px)
4. Map to named scale: `0.5` (2px), `1` (4px), `2` (8px), `3` (12px), `4` (16px), `5` (20px), `6` (24px), `8` (32px), `10` (40px), `12` (48px), `16` (64px), `20` (80px), `24` (96px)

### Shadows (Priority: Medium)

| Size | Typical Values | Usage |
|------|---------------|-------|
| **xs/sm** | `0 1px 2px rgba(0,0,0,0.05)` | Subtle elevation (cards, inputs) |
| **md** | `0 4px 6px rgba(0,0,0,0.1)` | Moderate elevation (dropdowns) |
| **lg** | `0 10px 15px rgba(0,0,0,0.1)` | High elevation (modals, popovers) |
| **xl** | `0 20px 25px rgba(0,0,0,0.15)` | Dramatic elevation (floating panels) |
| **inner** | `inset 0 2px 4px rgba(0,0,0,0.06)` | Pressed/inset states |

### Border Radii (Priority: Medium)

| Name | Typical Range | Usage |
|------|--------------|-------|
| **none** | `0` | Sharp corners |
| **sm** | `2-4px` | Subtle rounding (inputs, tags) |
| **md/default** | `6-8px` | Standard rounding (cards, buttons) |
| **lg** | `12-16px` | Prominent rounding (modals, panels) |
| **xl** | `20-24px` | Heavy rounding (pills, avatars) |
| **full** | `9999px` | Circles/pills |

### Animations & Transitions (Priority: Medium)

| Property | What to Extract | Notes |
|----------|----------------|-------|
| `transition-property` | Which props animate | Usually `all`, `opacity`, `transform`, `background-color` |
| `transition-duration` | Speed | Fast: 150ms, Normal: 200-300ms, Slow: 500ms+ |
| `transition-timing-function` | Easing curve | `ease`, `ease-in-out`, `cubic-bezier(...)` |
| `animation-name` | Keyframe animations | Entrance animations, loading spinners |
| `animation-duration` | Animation speed | |
| `transform` | Active transforms | Scale, translate, rotate on hover |

**Common Patterns:**
- Hover: `transition: all 200ms ease` with `transform: translateY(-2px)` + shadow increase
- Focus: `transition: box-shadow 150ms ease` with focus ring
- Entrance: `opacity 0→1` + `translateY(20px→0)` over 300-500ms

### Layout (Priority: Medium)

| Pattern | What to Extract | Properties |
|---------|----------------|------------|
| **Container** | Max-width, padding | `max-width`, `padding-inline`, `margin: 0 auto` |
| **Grid** | Column count, gap | `grid-template-columns`, `gap` |
| **Flex Nav** | Direction, alignment | `display: flex`, `justify-content`, `align-items` |
| **Sticky** | Position behavior | `position: sticky`, `top` |
| **Backdrop** | Blur effects | `backdrop-filter: blur(...)` |

### Component Patterns (Priority: Low-Medium)

Extract these for the comprehensive component analysis:

**Buttons:**
```
- padding (vertical, horizontal)
- border-radius
- font-size, font-weight, text-transform, letter-spacing
- background, color, border
- hover: background, color, shadow, transform
- active: background, transform(scale)
- disabled: opacity, cursor
- Variants: primary (filled), secondary (outline), ghost (transparent)
```

**Cards:**
```
- padding
- border-radius
- background-color
- border (often 1px solid with low-opacity color)
- box-shadow
- hover: shadow increase, translateY, border-color change
- overflow: hidden (for image cards)
```

**Inputs:**
```
- height
- padding (vertical, horizontal)
- border, border-radius
- font-size, color, placeholder color
- focus: border-color, ring (box-shadow), outline
- error: border-color, text color
```

**Navigation:**
```
- height
- background (solid, translucent, blur)
- position (sticky, fixed)
- padding
- link styling (active state, hover state)
- mobile: hamburger breakpoint, slide-in direction
```

## Dark Mode Detection

Check for dark mode support:

```javascript
// Check if prefers-color-scheme media query is used
const hasDarkMode = [...document.styleSheets].some(sheet => {
  try {
    return [...sheet.cssRules].some(rule =>
      rule.type === CSSRule.MEDIA_RULE &&
      rule.conditionText.includes('prefers-color-scheme: dark')
    );
  } catch { return false; }
});

// Check for class-based dark mode (e.g., .dark on html/body)
const classBasedDark = document.documentElement.classList.contains('dark') ||
  document.body.classList.contains('dark');

// Check for data attribute dark mode
const dataBasedDark = document.documentElement.dataset.theme === 'dark' ||
  document.documentElement.dataset.mode === 'dark';
```

If dark mode exists, extract both palettes by toggling the class/attribute and re-running color extraction.

## Multi-Page Crawling Strategy

### Why Multiple Pages?

A single page typically reveals 40-60% of a site's design system. Here's what different page types contribute:

| Page Type | Tokens You'll Find | Tokens You'll Miss |
|-----------|-------------------|-------------------|
| Homepage only | Brand colors, hero typography, CTA buttons, nav | Form inputs, table styles, error states, sidebar |
| + Pricing page | Card variants, comparison tables, toggle switches | Form validation, long-form text, code blocks |
| + Blog/docs page | Body typography, article layout, metadata, code blocks | Form patterns, dashboard components |
| + Form/auth page | Input styles, validation colors, form layout | Dashboard, data display |
| + Dashboard page | Sidebar nav, badges, charts, data tables, status colors | Marketing page CTAs |

### Merging Strategy

When extracting from multiple pages, merge using these rules:

- **Colors**: Union of all Sets. The same color found on 3+ pages is likely a system token. Colors found on only 1 page might be page-specific.
- **Typography**: Keep the most comprehensive set. h1 from the homepage is probably the "hero" size, h1 from a blog page is the "article title" size -- both are valid tokens.
- **Spacing**: Union. More pages = more data points for identifying the base grid unit.
- **Shadows/Radii**: Union. Different components use different elevations.
- **Component patterns**: Collect from the pages where they appear. Note the source page.

### Page Selection Heuristics

When auto-selecting pages from discovered links:

1. **Prioritize diversity**: Pick pages with different URL structures (not `/blog/post-1` and `/blog/post-2` -- those are the same template)
2. **Prefer top-level paths**: `/pricing` over `/pricing/enterprise/contact`
3. **Look for UI-heavy pages**: `/features`, `/pricing`, `/dashboard` over `/privacy-policy`, `/terms`
4. **Cap at 5-6 pages**: Diminishing returns beyond that
5. **Skip**: PDF links, file downloads, external links, anchor-only links

## Common Extraction Challenges

| Challenge | Solution |
|-----------|----------|
| Cross-origin stylesheets blocked | Note the external CSS URLs; fetch them separately if needed |
| Styles loaded by JS (CSS-in-JS) | Wait for page to fully render; extract computed styles (not stylesheet rules) |
| Hover/focus states | Use `browser_hover` to trigger, then re-extract |
| Responsive styles | Resize viewport to key breakpoints and re-extract |
| CSS custom properties not on :root | Search all rules for `--` prefixed properties |
| Duplicate/similar colors | Convert all to hex, group within ΔE < 5 as same color |
| Bot detection / rate limiting | Add 1-2 second pause between pages; use realistic viewport size |
| SPA with client-side routing | Click nav links instead of direct URL navigation; wait for route transitions |
| Lazy-loaded sections | Scroll to bottom of page before extracting; wait for intersection observers to fire |

## Output Quality Checklist

Before delivering results, verify:

- [ ] **Multi-page coverage**: Extracted from 3+ pages (not just the starting URL)
- [ ] **Pages documented**: DESIGN_TOKENS.md lists which pages were crawled and what was found on each
- [ ] Color palette has clear primary/secondary/neutral grouping
- [ ] Typography scale is consistent (not random px values)
- [ ] Spacing values map to a logical scale
- [ ] Tailwind config is valid TypeScript
- [ ] CSS custom properties follow naming convention
- [ ] Design tokens doc includes visual examples or descriptions
- [ ] Source URL and extraction date are noted
- [ ] Any gaps or limitations are documented (including pages that couldn't be reached)
- [ ] Screenshots are saved for visual reference (one per page crawled)

## Example: Apple.com Design System (Simplified)

For reference, here's what an Apple.com extraction typically yields:

**Colors:**
- Text: `#1d1d1f` (primary), `#6e6e73` (secondary), `#86868b` (tertiary)
- Background: `#ffffff` (surface), `#f5f5f7` (section alt), `#000000` (dark sections)
- Accent: `#0066cc` (link blue), `#0071e3` (button blue)

**Typography:**
- Font: SF Pro Display (headings), SF Pro Text (body) -- falls back to system fonts
- Scale: 96px (hero), 56px (section title), 28px (subtitle), 21px (lead), 17px (body), 14px (caption), 12px (fine print)
- Weight: 600 (headings), 400 (body), 700 (emphasis)

**Spacing:**
- Base unit: 8px
- Container max-width: 980px (content), 1440px (full bleed)
- Section padding: 80-120px vertical, 24px horizontal

**Shadows:**
- Minimal shadow usage (Apple favors flat design with subtle depth)
- Card shadows: `0 2px 8px rgba(0,0,0,0.08)`

**Radii:**
- Buttons: 980px (pill)
- Cards: 18-20px (generous)
- Images: 8-12px (subtle)

**Animations:**
- Scroll-triggered opacity + translateY
- Hover: 200ms ease transitions
- Page transitions: 400ms ease-in-out
