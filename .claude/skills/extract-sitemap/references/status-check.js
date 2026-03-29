// Status check script for browser_evaluate
// Checks if page loaded successfully and detects error pages

async () => {
  const isError = document.querySelector('body')?.textContent.includes('404') || 
                  document.querySelector('body')?.textContent.includes('Not Found') ||
                  document.querySelector('body')?.textContent.includes('Forbidden') ||
                  document.querySelector('body')?.textContent.includes('403');
  
  let statusCode = 200;
  try {
    if (isError) {
      if (document.querySelector('body')?.textContent.includes('404')) statusCode = 404;
      else if (document.querySelector('body')?.textContent.includes('403')) statusCode = 403;
      else if (document.querySelector('body')?.textContent.includes('500')) statusCode = 500;
    }
  } catch (e) {
    // Status code detection failed, assume 200 if page loaded
  }
  
  return {
    accessible: !isError && document.body !== null,
    statusCode: statusCode,
    pageTitle: document.title || 'Untitled',
    error: isError ? 'Page error detected' : null
  };
}
