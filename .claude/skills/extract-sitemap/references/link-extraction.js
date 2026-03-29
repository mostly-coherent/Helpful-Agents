// Link extraction script for browser_evaluate
// Extracts all internal links from the current page
// CANONICAL VERSION — shared between extract-webpage-content and extract-sitemap

async () => {
  const links = Array.from(document.querySelectorAll('a[href]'));
  const linkData = [];
  const currentHostname = window.location.hostname;
  const currentUrl = window.location.href;
  
  for (const link of links) {
    const href = link.href;
    const text = link.textContent.trim();
    
    if (!href) continue;
    
    // Normalize the URL
    let normalizedUrl = href;
    if (href.startsWith('/')) {
      normalizedUrl = `${window.location.protocol}//${currentHostname}${href}`;
    } else if (href.startsWith('./') || href.startsWith('../')) {
      try {
        normalizedUrl = new URL(href, currentUrl).href;
      } catch (e) {
        continue;
      }
    }
    
    // Check if it's an internal link (same domain)
    try {
      const urlObj = new URL(normalizedUrl);
      const isInternal = urlObj.hostname === currentHostname || 
                        urlObj.hostname.endsWith('.' + currentHostname) ||
                        (href.startsWith('/') && !href.startsWith('//'));
      
      const isFileDownload = /\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|txt|csv)$/i.test(href);
      
      const isValidContentLink = isInternal && 
                                 !href.startsWith('#') &&
                                 !href.startsWith('javascript:') &&
                                 !href.startsWith('mailto:') &&
                                 !href.startsWith('tel:') &&
                                 (href.endsWith('.html') || 
                                  href.includes('/content/') || 
                                  href.includes('/help/') ||
                                  isFileDownload ||
                                  (!href.includes('#') && !href.startsWith('javascript:') && !href.startsWith('mailto:')));
      
      if (isValidContentLink) {
        linkData.push({
          href: normalizedUrl.split('#')[0],
          text: text || href,
          isInternal: true,
          isFileDownload: isFileDownload,
          fileType: isFileDownload ? href.match(/\.([^.]+)$/i)?.[1] : null,
          originalHref: href
        });
      }
    } catch (e) {
      continue;
    }
  }
  
  // Remove duplicates
  const uniqueLinks = [];
  const seenUrls = new Set();
  for (const link of linkData) {
    const urlWithoutHash = link.href.split('#')[0].replace(/\/$/, '');
    if (!seenUrls.has(urlWithoutHash)) {
      seenUrls.add(urlWithoutHash);
      uniqueLinks.push({...link, href: urlWithoutHash});
    }
  }
  
  return {
    links: uniqueLinks,
    pageTitle: document.title || document.querySelector('h1')?.textContent.trim() || 'Untitled Page',
    currentUrl: currentUrl
  };
}
