# Queue-Based Recursive Mapping Algorithm

This document provides the exact algorithm that MUST be implemented to ensure complete sitemap extraction.

## Data Structures

```javascript
// State tracking (persist to sitemap-state.json)
{
  startingUrl: "https://...",
  startingTitle: "...",
  visitedUrls: Set(),  // Normalized URLs already processed
  pages: [],           // All processed pages: {title, url, depth, status, linksFound}
  queue: []            // URLs to process: {url, depth}
}
```

## Algorithm

### Step 1: Initialize

```javascript
visitedUrls = new Set()
pages = []
queue = []
startingUrl = userProvidedUrl

// Normalize function
function normalizeUrl(url) {
  return url.split('#')[0].replace(/\/$/, '')
}
```

### Step 2: Process Starting Page (Depth 0)

```javascript
// Navigate
browser_navigate({url: startingUrl})
browser_wait_for({time: 3})

// Extract links
linkResult = browser_evaluate({function: linkExtractionScript})
links = linkResult.links  // Array of {href, text, isFileDownload, ...}

// Check accessibility
statusResult = browser_evaluate({function: statusCheckScript})
isAccessible = statusResult.accessible
statusCode = statusResult.statusCode

// Add to pages
pages.push({
  title: linkResult.pageTitle,
  url: normalizeUrl(startingUrl),
  depth: 0,
  status: isAccessible ? `✅ Accessible (${statusCode})` : `❌ Dead Link (${statusCode})`,
  linksFound: links.length
})

// Mark as visited
visitedUrls.add(normalizeUrl(startingUrl))

// Add all internal HTML links to queue (depth 1)
for (link of links) {
  normalized = normalizeUrl(link.href)
  if (!link.isFileDownload && 
      !visitedUrls.has(normalized) && 
      isInternalLink(link.href)) {
    queue.push({url: normalized, depth: 1})
  }
}

// Save state
saveStateToFile('sitemap-state.json')
```

### Step 3: Process Queue Until Empty

```javascript
while (queue.length > 0) {
  // Pop next item
  item = queue.shift()  // {url, depth}
  normalized = normalizeUrl(item.url)
  
  // Skip if already visited
  if (visitedUrls.has(normalized)) {
    continue
  }
  
  // Skip if max depth reached
  if (item.depth >= 2) {
    continue
  }
  
  // Mark as visited BEFORE processing (prevents re-queuing)
  visitedUrls.add(normalized)
  
  try {
    // Navigate
    browser_navigate({url: item.url})
    browser_wait_for({time: 3})
    
    // Check accessibility
    statusResult = browser_evaluate({function: statusCheckScript})
    isAccessible = statusResult.accessible
    statusCode = statusResult.statusCode
    
    if (isAccessible && statusCode === 200) {
      // Extract links
      linkResult = browser_evaluate({function: linkExtractionScript})
      links = linkResult.links
      
      // Add to pages
      pages.push({
        title: linkResult.pageTitle,
        url: normalized,
        depth: item.depth,
        status: `✅ Accessible (${statusCode})`,
        linksFound: links.length
      })
      
      // Add discovered links to queue (if depth < 2)
      if (item.depth < 2) {
        for (link of links) {
          linkNormalized = normalizeUrl(link.href)
          if (!link.isFileDownload && 
              !visitedUrls.has(linkNormalized) && 
              isInternalLink(link.href)) {
            queue.push({url: linkNormalized, depth: item.depth + 1})
          }
        }
      }
    } else {
      // Dead link or error
      pages.push({
        title: statusResult.pageTitle || 'Untitled',
        url: normalized,
        depth: item.depth,
        status: statusCode === 404 ? '❌ Dead Link (404)' : 
                statusCode === 403 ? '🔒 Forbidden (403)' :
                statusCode === 500 ? '⚠️ Server Error (500)' :
                '⏱️ Timeout',
        linksFound: 0
      })
      // Do NOT add links to queue for dead/forbidden pages
    }
  } catch (error) {
    // Navigation error
    pages.push({
      title: 'Untitled',
      url: normalized,
      depth: item.depth,
      status: '⏱️ Timeout',
      linksFound: 0
    })
  }
  
  // Save state every 10-20 pages
  if (pages.length % 20 === 0) {
    saveStateToFile('sitemap-state.json')
    logProgress(pages.length, queue.length)
  }
}

// Final save
saveStateToFile('sitemap-state.json')
```

### Step 4: Verify Completion

```javascript
// Verify queue is empty
if (queue.length > 0) {
  throw new Error('Queue not empty! Continue processing.')
}

// Verify all discovered links processed
totalLinksDiscovered = pages.reduce((sum, p) => sum + p.linksFound, 0)
processedUrls = visitedUrls.size

// Log completion
console.log(`Completed: ${pages.length} pages, ${totalLinksDiscovered} links discovered`)
console.log(`Depth breakdown: Depth 0: ${countByDepth(0)}, Depth 1: ${countByDepth(1)}, Depth 2: ${countByDepth(2)}`)
```

### Step 5: Generate Sitemap

```javascript
// Sort pages by depth, then title
pagesSorted = pages.sort((a, b) => {
  if (a.depth !== b.depth) return a.depth - b.depth
  return a.title.localeCompare(b.title)
})

// Generate markdown
markdown = generateMarkdown(pagesSorted)

// Save to file
writeFile(`sitemap-${sanitizeUrl(startingUrl)}-${timestamp}.md`, markdown)

// Clean up state file
deleteFile('sitemap-state.json')
```

## Helper Functions

```javascript
function isInternalLink(href) {
  // Check if link is internal (same domain)
  // Implementation from link-extraction.js
}

function saveStateToFile(filename) {
  state = {
    startingUrl: startingUrl,
    startingTitle: pages[0]?.title || '',
    visitedUrls: Array.from(visitedUrls),
    pages: pages,
    queue: queue,
    lastUpdated: new Date().toISOString()
  }
  writeFile(filename, JSON.stringify(state, null, 2))
}

function loadStateFromFile(filename) {
  state = JSON.parse(readFile(filename))
  visitedUrls = new Set(state.visitedUrls)
  pages = state.pages
  queue = state.queue
  startingUrl = state.startingUrl
}

function logProgress(processed, remaining) {
  console.log(`Progress: ${processed} pages processed, ${remaining} URLs remaining in queue`)
}
```

## Critical Rules

1. **Never mark URL as visited before processing** - Add to `visitedUrls` immediately before navigation
2. **Process queue until empty** - Do NOT stop early, even if it takes many iterations
3. **Save state frequently** - Every 10-20 pages to prevent data loss
4. **Extract links from ALL accessible pages** - Even if depth is 1, extract links (they go to depth 2)
5. **Verify completion** - Check queue is empty before generating sitemap
6. **Handle errors gracefully** - Continue processing even if some pages fail
