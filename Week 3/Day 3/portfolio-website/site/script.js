function openProject(url){
  // interactive behaviour: opens project in new tab + logs event
  window.open(url, '_blank');
  console.log('Open project:', url);
}

function openImage(src) {
  // Create overlay
  const overlay = document.createElement('div');
  overlay.style.position = 'fixed';
  overlay.style.top = 0;
  overlay.style.left = 0;
  overlay.style.width = '100%';
  overlay.style.height = '100%';
  overlay.style.background = 'rgba(0,0,0,0.8)';
  overlay.style.display = 'flex';
  overlay.style.alignItems = 'center';
  overlay.style.justifyContent = 'center';
  overlay.style.zIndex = 9999;

  // Create image element
  const img = document.createElement('img');
  img.src = src;
  img.style.maxWidth = '90%';
  img.style.maxHeight = '90%';
  img.style.borderRadius = '10px';
  img.style.boxShadow = '0 0 20px rgba(255,255,255,0.3)';

  // Close on click
  overlay.addEventListener('click', () => overlay.remove());

  overlay.appendChild(img);
  document.body.appendChild(overlay);
}

// small progressive enhancement: show a toast when download clicked
document.addEventListener('DOMContentLoaded', () => {
  const dl = document.getElementById('download-cv');
  if(dl){
    dl.addEventListener('click', () => {
      // lightweight visual feedback
      const toast = document.createElement('div');
      toast.textContent = 'Your CV download will start shortly.';
      Object.assign(toast.style, {
        position: 'fixed',right: '20px',bottom: '20px',background:'#111',color:'#fff',padding:'8px 12px',borderRadius:'8px',opacity:'0.95',zIndex:9999
      });
      document.body.appendChild(toast);
      setTimeout(()=>toast.remove(),2000);
    });
  }
});