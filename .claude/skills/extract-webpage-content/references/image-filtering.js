// Identify and filter content images (skip decorative images)
// Used in Step 4: Identify and Capture Content Images

async () => {
  const images = Array.from(document.querySelectorAll('img'));
  const contentImages = [];
  
  for (const img of images) {
    const src = img.src || img.getAttribute('data-src') || '';
    const alt = img.alt || '';
    const rect = img.getBoundingClientRect();
    
    // Skip decorative images
    const isDecorative = 
      (rect.width < 50 && rect.height < 50) ||
      /logo|icon|nav|arrow|button|menu|social|decorative/i.test(alt) ||
      /logo|icon|nav|arrow|button|menu|social|decorative/i.test(img.className) ||
      /logo|icon|nav|arrow|button|menu|social|decorative/i.test(img.id) ||
      (img.closest('nav, header, footer, .nav, .header, .footer, .menu')) ||
      (src.includes('.svg') && rect.width < 100 && rect.height < 100);
    
    if (isDecorative) continue;
    
    const isAccessible = src && (
      src.startsWith('data:') || 
      src.startsWith('blob:') ||
      new URL(src, window.location.href).origin === window.location.origin
    );
    
    const isLikelyContent = 
      rect.width > 100 || 
      rect.height > 100 ||
      alt.length > 20 ||
      img.closest('main, article, .content, .main-content, .article');
    
    if (isLikelyContent || !isDecorative) {
      const allElements = Array.from(document.querySelectorAll('*'));
      const position = allElements.indexOf(img);
      
      const parent = img.closest('p, div, section, article, li');
      const contextText = parent ? parent.textContent.substring(0, 50).trim() : '';
      const contextSlug = contextText.replace(/[^a-z0-9]+/gi, '-').substring(0, 30).toLowerCase();
      
      contentImages.push({
        src: src,
        alt: alt,
        title: img.title || '',
        width: rect.width,
        height: rect.height,
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        canDownload: isAccessible,
        element: img,
        position: position,
        contextSlug: contextSlug || `image-${contentImages.length + 1}`
      });
    }
  }
  
  // Sort by document position
  contentImages.sort((a, b) => {
    if (a.y !== b.y) return a.y - b.y;
    return a.x - b.x;
  });
  
  return contentImages;
}
