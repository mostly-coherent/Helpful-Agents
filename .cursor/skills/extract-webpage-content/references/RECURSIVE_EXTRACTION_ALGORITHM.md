# Recursive Extraction Algorithm

This document provides the exact algorithm that MUST be implemented to ensure complete content extraction.

## Data Structures

```javascript
// State tracking (persist to extraction-state.json)
{
  startingUrl: "https://...",
  startingTitle: "...",
  visitedUrls: [],           // Normalized URLs already processed
  extractedPages: [],        // All extracted pages: {title, url, depth, folder, status}
  pendingUrls: []            // URLs to extract: {url, depth, parentFolder}
}
```

## Algorithm

### Step 1: Initialize

```javascript
visitedUrls = []
extractedPages = []
pendingUrls = []
startingUrl = userProvidedUrl
baseDirectory = userProvidedDirectory || workspaceRoot

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

// Expand dynamic content
expandResult = browser_evaluate({function: expandDynamicContentScript})
// Expands tabs, accordions, carousels

// Extract text
textResult = browser_evaluate({function: extractTextScript})
textContent = textResult.text

// Extract and capture images
imageResult = browser_evaluate({function: imageFilteringScript})
contentImages = imageResult.contentImages

// Save images
for (image of contentImages) {
  filename = generateImageFilename(image, pageTitle)
  if (image.canDownload) {
    downloadImage(image.url, filename)
  } else {
    browser_take_screenshot({x: image.x, y: image.y, width: image.width, height: image.height})
    saveScreenshot(filename)
  }
}

// Extract links
linkResult = browser_evaluate({function: linkExtractionScript})
links = linkResult.links

// Create folder
pageTitle = extractPageTitle(startingUrl)
folderName = sanitizeFolderName(pageTitle)
createFolder(`${baseDirectory}/${folderName}`)

// Save Markdown file
markdownContent = formatMarkdown(textContent, contentImages, links)
saveFile(`${baseDirectory}/${folderName}/${pageTitle}_Full_Content.md`, markdownContent)

// Add to extracted pages
extractedPages.push({
  title: pageTitle,
  url: normalizeUrl(startingUrl),
  depth: 0,
  folder: folderName,
  status: 'complete'
})

// Mark as visited
visitedUrls.push(normalizeUrl(startingUrl))

// Add all internal HTML links to queue (depth 1)
for (link of links) {
  normalized = normalizeUrl(link.href)
  if (!link.isFileDownload && 
      !visitedUrls.includes(normalized) && 
      isInternalLink(link.href)) {
    pendingUrls.push({
      url: normalized,
      depth: 1,
      parentFolder: folderName
    })
  }
}

// Save state
saveStateToFile('extraction-state.json')
```

### Step 3: Process Queue Until Empty

```javascript
while (pendingUrls.length > 0) {
  // Pop next item
  item = pendingUrls.shift()  // {url, depth, parentFolder}
  normalized = normalizeUrl(item.url)
  
  // Skip if already visited
  if (visitedUrls.includes(normalized)) {
    continue
  }
  
  // Skip if max depth reached
  if (item.depth >= 2) {
    continue
  }
  
  // Mark as visited BEFORE processing (prevents re-queuing)
  visitedUrls.push(normalized)
  
  try {
    // Navigate
    browser_navigate({url: item.url})
    browser_wait_for({time: 3})
    
    // Expand dynamic content
    expandResult = browser_evaluate({function: expandDynamicContentScript})
    
    // Extract text
    textResult = browser_evaluate({function: extractTextScript})
    textContent = textResult.text
    
    // Extract and capture images
    imageResult = browser_evaluate({function: imageFilteringScript})
    contentImages = imageResult.contentImages
    
    // Extract page title
    pageTitle = extractPageTitle(item.url)
    folderName = sanitizeFolderName(pageTitle)
    
    // Create nested folder
    createFolder(`${baseDirectory}/${item.parentFolder}/${folderName}`)
    
    // Save images
    for (image of contentImages) {
      filename = generateImageFilename(image, pageTitle)
      if (image.canDownload) {
        downloadImage(image.url, filename)
      } else {
        browser_take_screenshot({x: image.x, y: image.y, width: image.width, height: image.height})
        saveScreenshot(filename)
      }
      // Save to nested folder
      saveImage(`${baseDirectory}/${item.parentFolder}/${folderName}/${filename}`)
    }
    
    // Extract links
    linkResult = browser_evaluate({function: linkExtractionScript})
    links = linkResult.links
    
    // Save Markdown file
    markdownContent = formatMarkdown(textContent, contentImages, links)
    saveFile(`${baseDirectory}/${item.parentFolder}/${folderName}/${pageTitle}_Full_Content.md`, markdownContent)
    
    // Add to extracted pages
    extractedPages.push({
      title: pageTitle,
      url: normalized,
      depth: item.depth,
      folder: `${item.parentFolder}/${folderName}`,
      status: 'complete'
    })
    
    // Add discovered links to queue (if depth < 2)
    if (item.depth < 2) {
      for (link of links) {
        linkNormalized = normalizeUrl(link.href)
        if (!link.isFileDownload && 
            !visitedUrls.includes(linkNormalized) && 
            isInternalLink(link.href)) {
          pendingUrls.push({
            url: linkNormalized,
            depth: item.depth + 1,
            parentFolder: `${item.parentFolder}/${folderName}`
          })
        }
      }
    }
  } catch (error) {
    // Navigation error
    extractedPages.push({
      title: 'Untitled',
      url: normalized,
      depth: item.depth,
      folder: item.parentFolder,
      status: 'error'
    })
    // Log error but continue
    console.log(`Error extracting ${item.url}: ${error.message}`)
  }
  
  // Save state every 5-10 pages
  if (extractedPages.length % 10 === 0) {
    saveStateToFile('extraction-state.json')
    logProgress(extractedPages.length, pendingUrls.length)
  }
}

// Final save
saveStateToFile('extraction-state.json')
```

### Step 4: Verify Completion

```javascript
// Verify queue is empty
if (pendingUrls.length > 0) {
  throw new Error('Queue not empty! Continue extracting.')
}

// Verify all discovered links processed
totalLinksDiscovered = sum(extractedPages.map(p => p.linksFound || 0))
processedUrls = visitedUrls.length

// Log completion
console.log(`Completed: ${extractedPages.length} pages extracted, ${totalLinksDiscovered} links discovered`)
console.log(`Depth breakdown: Depth 0: ${countByDepth(0)}, Depth 1: ${countByDepth(1)}, Depth 2: ${countByDepth(2)}`)
```

### Step 5: Clean Up

```javascript
// Delete state file after successful completion
deleteFile('extraction-state.json')
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
    startingTitle: extractedPages[0]?.title || '',
    visitedUrls: visitedUrls,
    extractedPages: extractedPages,
    pendingUrls: pendingUrls,
    lastUpdated: new Date().toISOString()
  }
  writeFile(filename, JSON.stringify(state, null, 2))
}

function loadStateFromFile(filename) {
  state = JSON.parse(readFile(filename))
  visitedUrls = state.visitedUrls
  extractedPages = state.extractedPages
  pendingUrls = state.pendingUrls
  startingUrl = state.startingUrl
}

function logProgress(extracted, remaining) {
  console.log(`Progress: ${extracted} pages extracted, ${remaining} URLs remaining in queue`)
  if (remaining > 0) {
    console.log(`⚠️ WARNING: ${remaining} URLs still pending. Work is NOT complete. Continue extracting.`)
  } else {
    console.log(`✅ Queue empty. Proceeding to completion verification.`)
  }
}

function countByDepth(depth) {
  return extractedPages.filter(p => p.depth === depth).length
}
```

## Critical Rules

1. **Never mark URL as visited before processing** - Add to `visitedUrls` immediately before navigation
2. **Process queue until empty** - Do NOT stop early, even if it takes many iterations
3. **Save state frequently** - Every 5-10 pages to prevent data loss
4. **Extract images for ALL pages** - Image extraction is MANDATORY for every page at every depth
5. **Verify completion** - Check queue is empty before marking complete
6. **Handle errors gracefully** - Continue extracting even if some pages fail
7. **Never stop on errors** - Log errors but continue with next URL in queue

## File Downloads

For downloadable files (PDFs, DOCs, etc.):

```javascript
if (link.isFileDownload) {
  // Download file directly
  filename = extractFilenameFromUrl(link.href) || link.text
  downloadFile(link.href, `${parentFolder}/${filename}`)
  
  // Reference in Markdown
  markdownLink = `[${link.text}](${filename})`
  
  // Do NOT add to queue (files don't have extractable links)
  // Do NOT create nested folder for files
}
```

## Sitemap Mode

When processing from sitemap file:

```javascript
// Parse sitemap
sitemapUrls = parseSitemap(sitemapFile)

// Group by depth
urlsByDepth = {
  0: sitemapUrls.filter(u => u.depth === 0),
  1: sitemapUrls.filter(u => u.depth === 1),
  2: sitemapUrls.filter(u => u.depth === 2)
}

// Process in depth order (0, then 1, then 2)
for (depth of [0, 1, 2]) {
  for (urlItem of urlsByDepth[depth]) {
    // Extract page (same process as above)
    // Do NOT recursively follow links (sitemap already contains all URLs)
  }
}
```
