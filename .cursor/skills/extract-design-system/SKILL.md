---
name: extract-design-system
description: Extracts the visual design system (colors, typography, spacing, shadows, animations, layout patterns, component styles) from a website by crawling multiple pages (not just one URL). Generates reusable design tokens as Tailwind config, CSS custom properties, and markdown reference. Use when user provides a website URL and wants to extract styling, copy the design, replicate the look-and-feel, analyze CSS patterns, or extract design tokens.
---

# Extract Design System

Extracts the visual design system (colors, typography, spacing, shadows, animations, layout patterns, component styles) from any website and generates reusable design tokens in multiple formats (Tailwind config, CSS custom properties, design tokens doc).

## When to Use

- User provides a URL and wants to extract styling/design patterns
- User mentions "extract design", "steal the CSS", "copy the styling", "design system extraction"
- User wants to replicate the look-and-feel of a reference site in their own project
- User asks to analyze a website's visual design or UI patterns

## Prerequisites

- Browser tools (Playwright MCP or Cursor IDE Browser) must be available
- The target site must be publicly accessible (no auth-gated pages)

## Instructions

### Phase 1: Discover & Crawl Multiple Pages

The goal is to capture the **full design system**, not just one page. Different pages reveal different components (forms, cards, tables, modals, error states, etc.). Extract from **3-6 pages** for a representative sample.

**1a. Navigate to the starting URL and take a full-page screenshot.**

**1b. Discover linked pages to crawl.** Run this on the starting page:

```javascript
async (page) => {
  return await page.evaluate(() => {
    const origin = window.location.origin;
    const currentPath = window.location.pathname;
    const links = new Set();
    document.querySelectorAll('a[href]').forEach(a => {
      try {
        const url = new URL(a.href, origin);
        // Only same-origin, no anchors, no duplicates, no external
        if (url.origin === origin && url.pathname !== currentPath && !url.hash) {
          links.add(url.pathname);
        }
      } catch {}
    });
    return [...links].slice(0, 30); // Cap at 30 candidates
  });
};
```

**1c. Select which pages to visit.** From the discovered links, pick **3-5 additional pages** that are likely to show different UI components. Prioritize diversity:

| Page type | Why it matters | URL patterns to look for |
|-----------|---------------|-------------------------|
| **Product/feature page** | Hero sections, CTA buttons, feature grids | `/features`, `/product`, `/pricing` |
| **Content/blog page** | Long-form typography, article cards, metadata | `/blog`, `/docs`, `/about`, `/changelog` |
| **Form/auth page** | Input fields, form layout, validation styles | `/login`, `/signup`, `/contact`, `/settings` |
| **List/directory page** | Tables, data grids, filters, pagination | `/customers`, `/integrations`, `/marketplace` |
| **Dashboard/app page** | Sidebar nav, cards, charts, status badges | `/dashboard`, `/app`, `/overview` |

If the user provides specific pages or a workflow sequence (e.g., "landing page -> pricing -> signup"), follow that instead.

If fewer than 3 internal links exist (e.g., single-page app), note this and extract from the single page, scrolling to reveal all sections.

**1d. Visit each selected page:**
1. Navigate to the page
2. Wait for full render (`browser_wait_for` with 2-3 second pause, then snapshot to confirm)
3. Take a full-page screenshot
4. Scroll through the page to trigger lazy-loaded content
5. Run the extraction scripts (Phase 2) on **each page**
6. Track which page each token came from (for the output docs)

**Key rule:** Merge results across pages. Use Sets to deduplicate. The final output should be **one unified design system**, not separate per-page outputs. But the `DESIGN_TOKENS.md` should note which page a component pattern was observed on (e.g., "Card pattern -- seen on /pricing, /blog").

### Phase 2: Extract Core Design Tokens (Per Page)

**Repeat this phase for each page visited in Phase 1.** Merge all results into shared Sets/arrays.

Run JavaScript in the browser to extract computed styles from the DOM. Extract each category below.

**2a. Color Palette**

Extract colors from these sources (use `browser_evaluate` or `browser_run_code`):

```javascript
async (page) => {
  return await page.evaluate(() => {
    const colors = new Set();
    const elements = document.querySelectorAll('*');
    const props = ['color', 'background-color', 'border-color', 'box-shadow', 'outline-color'];
    elements.forEach(el => {
      const styles = getComputedStyle(el);
      props.forEach(prop => {
        const val = styles.getPropertyValue(prop);
        if (val && val !== 'rgba(0, 0, 0, 0)' && val !== 'transparent' && val !== 'none') {
          colors.add(val);
        }
      });
    });
    // Also grab CSS custom properties from :root
    const rootStyles = getComputedStyle(document.documentElement);
    const sheet = [...document.styleSheets].flatMap(s => {
      try { return [...s.cssRules]; } catch { return []; }
    });
    const customProps = {};
    sheet.forEach(rule => {
      if (rule.selectorText === ':root' || rule.selectorText === ':host') {
        for (const prop of rule.style) {
          if (prop.startsWith('--')) {
            customProps[prop] = rule.style.getPropertyValue(prop).trim();
          }
        }
      }
    });
    return { computedColors: [...colors], customProperties: customProps };
  });
};
```

Group extracted colors into: primary, secondary, accent, neutral, surface, text, border, success/warning/error.

**2b. Typography**

```javascript
async (page) => {
  return await page.evaluate(() => {
    const typo = [];
    const tags = ['h1','h2','h3','h4','h5','h6','p','a','button','span','li','label','input'];
    tags.forEach(tag => {
      const el = document.querySelector(tag);
      if (el) {
        const s = getComputedStyle(el);
        typo.push({
          tag,
          fontFamily: s.fontFamily,
          fontSize: s.fontSize,
          fontWeight: s.fontWeight,
          lineHeight: s.lineHeight,
          letterSpacing: s.letterSpacing,
          textTransform: s.textTransform,
          color: s.color
        });
      }
    });
    return typo;
  });
};
```

**2c. Spacing & Layout**

```javascript
async (page) => {
  return await page.evaluate(() => {
    const spacings = new Set();
    const layouts = [];
    const containers = document.querySelectorAll('main, section, .container, [class*="wrapper"], [class*="container"], article, header, footer, nav');
    containers.forEach(el => {
      const s = getComputedStyle(el);
      ['padding','paddingTop','paddingRight','paddingBottom','paddingLeft',
       'margin','marginTop','marginRight','marginBottom','marginLeft',
       'gap','rowGap','columnGap'].forEach(prop => {
        const val = s[prop];
        if (val && val !== '0px' && val !== 'normal') spacings.add(val);
      });
      layouts.push({
        tag: el.tagName.toLowerCase(),
        className: el.className?.toString().slice(0, 80),
        display: s.display,
        maxWidth: s.maxWidth,
        padding: s.padding,
        gap: s.gap
      });
    });
    return { spacingValues: [...spacings].sort(), layouts: layouts.slice(0, 20) };
  });
};
```

**2d. Shadows, Borders & Radii**

```javascript
async (page) => {
  return await page.evaluate(() => {
    const shadows = new Set();
    const radii = new Set();
    const borders = new Set();
    document.querySelectorAll('*').forEach(el => {
      const s = getComputedStyle(el);
      if (s.boxShadow && s.boxShadow !== 'none') shadows.add(s.boxShadow);
      if (s.borderRadius && s.borderRadius !== '0px') radii.add(s.borderRadius);
      if (s.borderWidth && s.borderWidth !== '0px') {
        borders.add(`${s.borderWidth} ${s.borderStyle} ${s.borderColor}`);
      }
    });
    return {
      shadows: [...shadows],
      borderRadii: [...radii],
      borders: [...borders].slice(0, 20)
    };
  });
};
```

**2e. Animations & Transitions**

```javascript
async (page) => {
  return await page.evaluate(() => {
    const transitions = new Set();
    const animations = new Set();
    document.querySelectorAll('*').forEach(el => {
      const s = getComputedStyle(el);
      if (s.transition && s.transition !== 'all 0s ease 0s' && s.transition !== 'none 0s ease 0s') {
        transitions.add(s.transition);
      }
      if (s.animationName && s.animationName !== 'none') {
        animations.add(`${s.animationName} ${s.animationDuration} ${s.animationTimingFunction}`);
      }
    });
    return { transitions: [...transitions].slice(0, 20), animations: [...animations] };
  });
};
```

**2f. Component Patterns (Comprehensive)**

Inspect key interactive/visual components:
- **Buttons**: padding, border-radius, font-weight, hover states, variants (primary/secondary/ghost)
- **Cards**: padding, shadow, border-radius, background, hover elevation
- **Navigation**: layout (flex/grid), height, backdrop-filter (blur), sticky behavior
- **Forms**: input height, padding, border, focus ring, placeholder color
- **Links**: color, hover color, underline behavior, transition

For hover states, use `browser_hover` on elements and re-extract styles.

**2g. Responsive Breakpoints**

```javascript
async (page) => {
  return await page.evaluate(() => {
    const breakpoints = new Set();
    [...document.styleSheets].forEach(sheet => {
      try {
        [...sheet.cssRules].forEach(rule => {
          if (rule.type === CSSRule.MEDIA_RULE) {
            breakpoints.add(rule.conditionText);
          }
        });
      } catch {}
    });
    return [...breakpoints].filter(b => b.includes('width'));
  });
};
```

### Phase 3: Analyze & Organize

After raw extraction, analyze the data:

1. **Deduplicate colors** -- convert all to hex, group similar shades into a scale (50-950)
2. **Build typography scale** -- identify heading sizes, body sizes, small text
3. **Build spacing scale** -- find the base unit (usually 4px or 8px) and map values to a scale
4. **Identify patterns** -- which shadow is "sm" vs "md" vs "lg"? Which radius is "card" vs "button" vs "pill"?

### Phase 4: Generate Outputs

Generate **all three** output formats:

**Output 1: Tailwind CSS Config (`tailwind.config.extract.ts`)**

```typescript
// Extracted from: [URL]
// Date: [extraction date]
import type { Config } from 'tailwindcss'

export default {
  theme: {
    extend: {
      colors: {
        primary: { /* scale */ },
        secondary: { /* scale */ },
        // ...
      },
      fontFamily: {
        heading: ['...'],
        body: ['...'],
      },
      fontSize: { /* scale */ },
      spacing: { /* scale */ },
      borderRadius: { /* named sizes */ },
      boxShadow: { /* named sizes */ },
    }
  }
} satisfies Config
```

**Output 2: CSS Custom Properties (`design-tokens.css`)**

```css
/* Extracted from: [URL] */
/* Date: [extraction date] */

:root {
  /* Colors */
  --color-primary: #...;
  --color-primary-hover: #...;
  /* ... */

  /* Typography */
  --font-heading: '...';
  --font-body: '...';
  --text-xs: ...;
  /* ... */

  /* Spacing */
  --space-1: ...;
  /* ... */

  /* Shadows */
  --shadow-sm: ...;
  /* ... */

  /* Radii */
  --radius-sm: ...;
  /* ... */

  /* Transitions */
  --transition-default: ...;
  /* ... */
}
```

**Output 3: Design Tokens Markdown (`DESIGN_TOKENS.md`)**

A human-readable reference doc with:
- Color swatches (hex + usage notes)
- Typography table (element, font, size, weight, line-height)
- Spacing scale table
- Shadow examples
- Border radius examples
- Animation/transition patterns
- Component pattern notes (button styles, card styles, nav behavior)
- Responsive breakpoints
- Screenshot references

### Phase 5: Deliver Results

1. Save all three output files to the current project directory (or a `design/` subfolder)
2. Present a summary of the extracted design system, including:
   - Which pages were crawled (URLs + what component types were found on each)
   - Total unique tokens extracted per category
3. Note any patterns that were ambiguous or couldn't be extracted (e.g., hover states behind JS interactions, dynamically loaded styles, auth-gated pages that couldn't be reached)
4. Suggest how to apply the tokens to the user's current project

## Important Notes

- **Multi-page by default**: Always crawl 3-6 pages to get a representative design system. A single page rarely has all component types (forms, cards, tables, nav states, error pages).
- **User can override page selection**: If the user specifies exact pages or a workflow sequence, follow that instead of auto-discovering links.
- **Auth-gated pages**: Skip pages that require login. Note them as gaps in the output. Only extract from publicly accessible pages.
- **Respect copyright**: The extracted design tokens are for personal reference and inspiration. Don't copy proprietary assets (logos, images, custom icons).
- **Cross-origin stylesheets**: Some external CSS files block JavaScript access. The extraction scripts handle this gracefully with try/catch, but some styles may be missed. Note these gaps in the output.
- **Dynamic/JS-rendered styles**: SPAs may load styles dynamically. Allow the page to fully render before extracting. Use `browser_wait_for` if needed.
- **Dark mode**: If the site supports dark mode, extract both light and dark palettes.
- **Rate limiting**: Add a 1-2 second pause between page navigations to avoid triggering bot detection.

## Example Usage

**Example 1 -- Auto-discover pages:**

**User**: "Extract the design system from https://linear.app"

**Agent**:
1. Navigates to linear.app, takes screenshot
2. Discovers internal links: `/features`, `/pricing`, `/changelog`, `/integrations`, `/method`, `/customers`
3. Picks diverse pages: `/features` (feature grid + CTA), `/pricing` (cards + tables), `/changelog` (long-form + metadata), `/customers` (testimonials + logos)
4. Visits each page, runs extraction scripts on each, merges results
5. Generates `tailwind.config.extract.ts`, `design-tokens.css`, `DESIGN_TOKENS.md`
6. Summarizes: "Crawled 5 pages. Linear uses a dark-first palette with blue-violet accent (#5E6AD2), Inter font family, 4px spacing grid, subtle 1px borders with low-opacity shadows. Form styles found on /pricing, card patterns on /customers and /changelog..."

**Example 2 -- User specifies pages:**

**User**: "Extract the design from Stripe. Check their homepage, pricing page, and docs."

**Agent**:
1. Visits `stripe.com`, `stripe.com/pricing`, `stripe.com/docs`
2. Extracts from all three, merges into one unified design system
3. Notes: "Docs page revealed code block styling, monospace font tokens, and sidebar navigation patterns not present on the homepage."

## Additional Resources

For detailed CSS property extraction lists and pattern analysis guidance, see [references/REFERENCE.md](references/REFERENCE.md).
