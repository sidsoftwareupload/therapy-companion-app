(function() {
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    const isInstagram = userAgent.includes('Instagram');
    const isFacebook = userAgent.includes('FBAN') || userAgent.includes('FBAV');
    const isPinterest = userAgent.includes('Pinterest');
    const isTwitter = userAgent.includes('Twitter');

    // Global flag to be used by other scripts.
    window.isInAppBrowser = isInstagram || isFacebook || isPinterest || isTwitter;

    if (window.isInAppBrowser) {
        const banner = document.createElement('div');
        banner.innerHTML = '<div style="position: fixed; top: 0; left: 0; width: 100%; box-sizing: border-box; background-color: #ffdd57; color: #333; text-align: center; padding: 15px; font-family: sans-serif; z-index: 10000; font-size: 16px; line-height: 1.4;">For the best experience and to install the app, please open in your device\'s main browser.</div>';
        document.body.prepend(banner);
    }
})();

let deferredPrompt;
window.addEventListener('beforeinstallprompt', (e) => {
  // Do not show the install prompt if we are in an in-app browser.
  if (window.isInAppBrowser) {
    return;
  }

  e.preventDefault();
  deferredPrompt = e;
  const installBanner = document.createElement('div');
  installBanner.innerHTML = `
    <div id="installPrompt" style="
      position:fixed;bottom:20px;left:50%;transform:translateX(-50%);
      background:#e9f5ef;padding:16px;border-radius:12px;
      box-shadow:0 4px 12px rgba(0,0,0,0.1);z-index:9999;
      font-family:sans-serif;text-align:center;">
      <p>Add Therapy Companion to your home screen for quick access.</p>
      <button id="installBtn" style="
        background-color: #2E7D32;
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);">Add App</button>
    </div>
  `;
  document.body.appendChild(installBanner);
  document.getElementById('installBtn').addEventListener('click', async () => {
    installBanner.remove();
    deferredPrompt.prompt();
    await deferredPrompt.userChoice;
    deferredPrompt = null;
  });
});
