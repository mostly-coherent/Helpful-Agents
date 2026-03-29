// Expand all tabs, accordions, and carousels
// Used in Step 2: Expand All Dynamic Content

async () => {
  const extractedTabContent = {};
  
  // Find tabs using multiple selectors
  const tabSelectors = [
    '[role="tab"]',
    'button[role="tab"]',
    '.tab',
    '.tab-button',
    '[class*="tab"]',
    'button[class*="tab"]',
    '[data-tab]',
    'button[data-tab]'
  ];
  
  let tabs = [];
  for (const selector of tabSelectors) {
    const found = Array.from(document.querySelectorAll(selector));
    if (found.length > 0) {
      tabs = found;
      break;
    }
  }
  
  // Click each tab and extract its content
  if (tabs.length > 0) {
    for (let i = 0; i < tabs.length; i++) {
      const tab = tabs[i];
      const tabText = tab.textContent.trim() || tab.getAttribute('aria-label') || `Tab ${i + 1}`;
      
      tab.click();
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Find the corresponding tab panel
      const tabId = tab.getAttribute('id') || tab.getAttribute('aria-controls');
      let panel = document.getElementById(tabId) || document.querySelector(`[id="${tabId}"]`);
      
      if (panel) {
        const panelClone = panel.cloneNode(true);
        panelClone.querySelectorAll('nav, header, footer, .nav, .header, .footer, .navigation, [role="navigation"], [role="banner"], [role="complementary"], script, style').forEach(el => el.remove());
        
        let content = panelClone.textContent.trim() || panelClone.innerText.trim();
        content = content.replace(/User Guide\s*Cancel/gi, '');
        content = content.replace(/Search\s*/gi, '');
        content = content.replace(/Get help faster.*?Create an account/gi, '');
        content = content.replace(/On this page:.*/gi, '');
        content = content.replace(/\s{3,}/g, ' ').replace(/\n{3,}/g, '\n\n').trim();
        
        if (content && content.length > 100) {
          const isUnique = !Object.values(extractedTabContent).some(existing => 
            existing.substring(0, 200) === content.substring(0, 200)
          );
          if (isUnique) {
            extractedTabContent[tabText] = content;
          }
        }
      }
    }
  }
  
  // Expand all accordions
  const mainArea = document.querySelector('main') || document.querySelector('[role="main"]') || document.body;
  const accordionButtons = Array.from(mainArea.querySelectorAll('button[aria-expanded="false"]'));
  for (const btn of accordionButtons) {
    if (btn.closest('nav, header, footer')) continue;
    try {
      btn.click();
      await new Promise(resolve => setTimeout(resolve, 300));
    } catch (e) {
      // Skip if not clickable
    }
  }
  
  // Navigate carousel slides
  const carouselNext = document.querySelector('[aria-label*="next" i], [aria-label*="Next" i]');
  if (carouselNext) {
    let hasNext = true;
    let clickCount = 0;
    const maxClicks = 20;
    while (hasNext && clickCount < maxClicks) {
      carouselNext.click();
      await new Promise(resolve => setTimeout(resolve, 500));
      clickCount++;
      hasNext = !carouselNext.disabled && !carouselNext.hasAttribute('aria-disabled');
    }
  }
  
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return {
    status: 'All dynamic content expanded',
    tabContent: extractedTabContent,
    tabsFound: tabs.length,
    tabsExtracted: Object.keys(extractedTabContent).length
  };
}
