# Extract Page Shallow - Technical Reference

## Complete Extraction Algorithm

### Pseudocode

```javascript
// Initialize tracking
visitedUrls = new Set()
extractedPages = []
depth0Links = []  // Links found on starting page

// Step 1: Extract starting page (Depth 0)
startingPage = extractPage(startingUrl, depth: 0)
visitedUrls.add(normalizeUrl(startingUrl))
extractedPages.push(startingPage)

// Step 2: Find all internal links on starting page
depth0Links = extractLinks(startingUrl)
  .filter(link => isInternalLink(link) && !isFileDownload(link))
  .map(link => normalizeUrl(link))
  .filter(link => !visitedUrls.has(link))

console.log(`Found ${depth0Links.length} direct links to extract`)

// Step 3: Extract each depth 1 page
for (const linkUrl of depth0Links) {
  // Mark as visited
  visitedUrls.add(linkUrl)
  
  try {
    // Extract page (depth 1)
    linkedPage = extractPage(linkUrl, depth: 1, parentFolder: startingPage.folder)
    extractedPages.push(linkedPage)
    
    // DO NOT extract links from this page (no depth 2)
    console.log(`Extracted depth 1: ${linkedPage.title}`)
    
  } catch (error) {
    console.log(`Error extracting ${linkUrl}: ${error.message}`)
    extractedPages.push({
      title: 'Untitled',
      url: linkUrl,
      depth: 1,
      status: 'error'
    })
  }
  
  // Progress report every 5 pages
  if (extractedPages.length % 5 === 0) {
    console.log(`Progress: ${extractedPages.length} pages extracted`)
  }
}

// Step 4: Report completion
console.log(`Extraction complete: 1 page at depth 0, ${depth0Links.length} pages at depth 1`)
console.log(`Total: ${extractedPages.length} pages`)
```

## Dynamic Content Expansion

**Playwright code to expand accordions, tabs, carousels:**

```javascript
async function expandAllContent(page) {
  // Wait for page to settle
  await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {})
  
  // Find and click all buttons/triggers that might expand content
  const buttons = await page.locator('button').all()
  
  for (const button of buttons) {
    try {
      const text = await button.textContent()
      
      // Look for expansion triggers
      if (text && (
        text.includes('Show') ||
        text.includes('more') ||
        text.includes('Expand') ||
        text.includes('View') ||
        button.getAttribute('aria-expanded') === 'false'
      )) {
        const isVisible = await button.isVisible()
        if (isVisible) {
          await button.click({ timeout: 2000 }).catch(() => {})
          await page.waitForTimeout(500)
        }
      }
    } catch (e) {
      // Continue on error
    }
  }
  
  // Wait for any animations to complete
  await page.waitForTimeout(2000)
  
  return { success: true }
}
```

## Link Extraction and Filtering

**Extract and filter internal links:**

```javascript
async function extractInternalLinks(page, baseUrl) {
  const links = await page.evaluate((baseOrigin) => {
    const linkElements = document.querySelectorAll('a[href]')
    const nav = document.querySelector('nav')
    const footer = document.querySelector('footer, [role="contentinfo"]')
    
    const results = []
    
    linkElements.forEach(a => {
      // Skip nav and footer links
      if (nav && nav.contains(a)) return
      if (footer && footer.contains(a)) return
      
      const href = a.getAttribute('href')
      if (!href) return
      
      // Skip anchors, mailto, tel
      if (href.startsWith('#') || 
          href.includes('mailto:') || 
          href.includes('tel:')) return
      
      try {
        const url = new URL(href, window.location.href)
        
        // Only internal links (same origin)
        if (url.origin === baseOrigin) {
          results.push({
            href: url.href,
            text: a.innerText?.trim() || ''
          })
        }
      } catch (e) {
        // Invalid URL, skip
      }
    })
    
    return results
  }, new URL(baseUrl).origin)
  
  // Deduplicate
  const uniqueLinks = []
  const seenUrls = new Set()
  
  links.forEach(link => {
    const normalized = normalizeUrl(link.href)
    if (!seenUrls.has(normalized)) {
      seenUrls.add(normalized)
      uniqueLinks.push({ href: normalized, text: link.text })
    }
  })
  
  return uniqueLinks
}

function normalizeUrl(url) {
  try {
    const parsed = new URL(url)
    // Remove trailing slash
    parsed.pathname = parsed.pathname.replace(/\/$/, '')
    // Remove fragments
    parsed.hash = ''
    return parsed.href
  } catch (e) {
    return url
  }
}

function isInternalLink(url, baseUrl) {
  try {
    const parsed = new URL(url)
    const base = new URL(baseUrl)
    return parsed.origin === base.origin
  } catch (e) {
    return false
  }
}

function isFileDownload(url) {
  const fileExtensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.zip', '.tar', '.gz']
  return fileExtensions.some(ext => url.toLowerCase().endsWith(ext))
}
```

## Content Extraction

**Extract text content from page:**

```javascript
async function extractContent(page) {
  const content = await page.evaluate(() => {
    const nav = document.querySelector('nav')
    const footer = document.querySelector('footer, [role="contentinfo"]')
    const elements = []
    
    document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li').forEach(el => {
      // Skip nav and footer
      if (nav && nav.contains(el)) return
      if (footer && footer.contains(el)) return
      
      const text = el.innerText?.trim()
      if (text && text.length > 0) {
        elements.push({
          type: el.tagName.toLowerCase(),
          text: text
        })
      }
    })
    
    return {
      elements: elements,
      title: document.title,
      url: window.location.href
    }
  })
  
  return content
}
```

## Error Recovery

**Retry navigation with exponential backoff:**

```javascript
async function navigateWithRetry(page, url, maxRetries = 3) {
  let lastError = null
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      await page.goto(url, { 
        waitUntil: 'domcontentloaded',
        timeout: 30000 
      })
      return { success: true }
    } catch (error) {
      lastError = error
      console.log(`Navigation attempt ${i + 1} failed: ${error.message}`)
      
      if (i < maxRetries - 1) {
        // Wait before retry (exponential backoff)
        const waitTime = Math.pow(2, i) * 1000
        await new Promise(resolve => setTimeout(resolve, waitTime))
      }
    }
  }
  
  return { 
    success: false, 
    error: lastError.message 
  }
}
```

## Progress Reporting

**Log progress at regular intervals:**

```javascript
function reportProgress(extractedPages, totalLinks) {
  const depth0 = extractedPages.filter(p => p.depth === 0).length
  const depth1 = extractedPages.filter(p => p.depth === 1).length
  const errors = extractedPages.filter(p => p.status === 'error').length
  
  console.log(`\nProgress Report:`)
  console.log(`- Depth 0 (starting page): ${depth0} page`)
  console.log(`- Depth 1 (direct links): ${depth1} of ${totalLinks} pages`)
  console.log(`- Errors: ${errors}`)
  console.log(`- Total extracted: ${extractedPages.length} pages`)
  
  if (depth1 < totalLinks) {
    const remaining = totalLinks - depth1
    console.log(`- Remaining: ${remaining} pages`)
  } else {
    console.log(`✅ All pages extracted`)
  }
}
```

## Folder and File Naming

**Create clean folder and file names:**

```javascript
function sanitizeFilename(title) {
  return title
    .replace(/[^a-zA-Z0-9\s-]/g, '')  // Remove special chars
    .replace(/\s+/g, '_')              // Spaces to underscores
    .replace(/_+/g, '_')               // Multiple underscores to one
    .substring(0, 100)                 // Max length
}

function createFolderPath(parentFolder, pageTitle) {
  const folderName = sanitizeFilename(pageTitle)
  return `${parentFolder}/${folderName}`
}

function createMarkdownFilename(pageTitle) {
  const filename = sanitizeFilename(pageTitle)
  return `${filename}_Full_Content.md`
}
```

## Markdown Formatting

**Format extracted content as markdown:**

```javascript
function formatAsMarkdown(content, images = []) {
  let markdown = `# ${content.title}\n\n`
  
  // Add images at top if any
  images.forEach((img, i) => {
    markdown += `![Image ${i + 1}](${img.filename})\n\n`
  })
  
  // Add content
  content.elements.forEach(el => {
    switch(el.type) {
      case 'h1':
        markdown += `# ${el.text}\n\n`
        break
      case 'h2':
        markdown += `## ${el.text}\n\n`
        break
      case 'h3':
        markdown += `### ${el.text}\n\n`
        break
      case 'h4':
        markdown += `#### ${el.text}\n\n`
        break
      case 'p':
        markdown += `${el.text}\n\n`
        break
      case 'li':
        markdown += `- ${el.text}\n`
        break
    }
  })
  
  markdown += `\n---\n\n`
  markdown += `Page URL: ${content.url}\n`
  
  return markdown
}
```

## Completion Verification

**Verify extraction is complete:**

```javascript
function verifyCompletion(extractedPages, expectedDepth0Count, expectedDepth1Count) {
  const checks = {
    depth0Complete: false,
    depth1Complete: false,
    outputsExist: false
  }
  
  // Check depth 0
  const depth0Pages = extractedPages.filter(p => p.depth === 0 && p.status === 'complete')
  checks.depth0Complete = depth0Pages.length >= expectedDepth0Count
  
  // Check depth 1
  const depth1Pages = extractedPages.filter(p => p.depth === 1)
  checks.depth1Complete = depth1Pages.length >= expectedDepth1Count
  
  // Check all pages have output files
  checks.outputsExist = extractedPages.every(page => {
    if (page.status === 'error') return true  // Errors don't need output
    return fileExists(page.outputPath)
  })
  
  const allPassed = Object.values(checks).every(v => v === true)
  
  if (allPassed) {
    console.log('✅ Extraction verification PASSED')
  } else {
    console.log('❌ Extraction verification FAILED')
    console.log('Failed checks:', 
      Object.entries(checks)
        .filter(([k, v]) => !v)
        .map(([k, v]) => k)
    )
  }
  
  return allPassed
}
```
