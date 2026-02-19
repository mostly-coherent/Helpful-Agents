// Parse URLs from sitemap file machine-readable section
// Used in Step 1a: Parse Sitemap File

function parseSitemapUrls(sitemapContent) {
  const urls = [];
  const lines = sitemapContent.split('\n');
  let inMachineReadableSection = false;
  let currentDepth = null;
  
  for (const line of lines) {
    // Detect machine-readable section start
    if (line.includes('Machine-Readable URL List') || line.includes('Machine-Readable')) {
      inMachineReadableSection = true;
      continue;
    }
    
    // Stop if we hit another major section (##)
    if (inMachineReadableSection && line.match(/^##\s+/) && !line.includes('Machine-Readable')) {
      break;
    }
    
    if (!inMachineReadableSection) continue;
    
    // Detect depth level
    const depthMatch = line.match(/^###\s+Depth\s+(\d+)/);
    if (depthMatch) {
      currentDepth = parseInt(depthMatch[1]);
      continue;
    }
    
    // Detect file section
    if (line.includes('Files (not extracted recursively)') || line.includes('### Files')) {
      currentDepth = 'files';
      continue;
    }
    
    // Extract URL from markdown list item
    const urlMatch = line.match(/^-\s+[✅❌🔒⚠️📄]\s+(https?:\/\/[^\s\)]+)/);
    if (urlMatch) {
      const url = urlMatch[1];
      const statusEmoji = line.match(/^-\s+([✅❌🔒⚠️📄])/)?.[1];
      
      // Only extract accessible URLs (✅) and files (📄)
      if (statusEmoji === '✅' || statusEmoji === '📄') {
        urls.push({
          url: url,
          depth: currentDepth,
          type: statusEmoji === '📄' ? 'file' : 'page',
          status: statusEmoji === '✅' ? 'accessible' : 'file'
        });
      }
    }
  }
  
  return urls;
}
