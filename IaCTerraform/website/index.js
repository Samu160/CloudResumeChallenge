// --- Mobile menu toggle ---
(function(){
  const toggle = document.getElementById('menu-toggle');
  const sidenav = document.querySelector('.sidenav');
  const menu = document.getElementById('primary-nav');

  if(!toggle || !sidenav || !menu) return;

  function setExpanded(isOpen){
    toggle.setAttribute('aria-expanded', String(isOpen));
    toggle.setAttribute('aria-label', isOpen ? 'Close menu' : 'Open menu');
    sidenav.classList.toggle('open', isOpen);
  }

  toggle.addEventListener('click', () => {
    const isOpen = toggle.getAttribute('aria-expanded') === 'true';
    setExpanded(!isOpen);
  });

  // Close menu after tapping a link on mobile
  menu.addEventListener('click', (e) => {
    if(e.target.closest('a') && window.matchMedia('(max-width: 768px)').matches){
      setExpanded(false);
    }
  });

  // Escape key closes the menu
  document.addEventListener('keydown', (e) => {
    if(e.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true'){
      setExpanded(false);
      toggle.focus();
    }
  });

  // Reset when going back to desktop
  const mq = window.matchMedia('(min-width: 769px)');
  mq.addEventListener('change', (ev) => {
    if(ev.matches){
      setExpanded(false);
    }
  });
})();

// --- Simple SPA-style section switcher ---
(function(){
  const sections = Array.from(document.querySelectorAll('main > section'));
  const links = Array.from(document.querySelectorAll('.sidenav a'));

  if (!sections.length || !links.length) return;

  function setActiveLink(targetId){
    links.forEach(a => {
      const id = (a.getAttribute('href') || '').replace('#','');
      a.classList.toggle('active', id === targetId);
    });
  }

  function showSection(targetId, {push=true, focus=true} = {}){
    const target = document.getElementById(targetId);
    if (!target) return;

    // hide others, show target
    sections.forEach(sec => sec.classList.toggle('is-hidden', sec !== target));
    setActiveLink(targetId);

    // update URL
    if (push) history.pushState({section: targetId}, '', `#${targetId}`);

    // move focus to first heading for accessibility
    if (focus) {
      const firstHeading = target.querySelector('h1, h2, h3');
      (firstHeading || target).setAttribute('tabindex', '-1');
      (firstHeading || target).focus({preventScroll:true});
      // ensure no leftover scroll jump
      window.scrollTo({top: 0, left: 0, behavior: 'instant'});
    }
  }

  // intercept nav clicks
  links.forEach(a => {
    a.addEventListener('click', (e) => {
      const href = a.getAttribute('href') || '';
      if (href.startsWith('#')) {
        e.preventDefault();
        const id = href.slice(1);
        showSection(id, {push:true, focus:true});
      }
    });
  });

  // handle back/forward
  window.addEventListener('popstate', (e) => {
    const id = (location.hash || '#about').slice(1);
    showSection(id, {push:false, focus:false});
  });

  // initial load: respect hash, default to #about
  document.addEventListener('DOMContentLoaded', () => {
    const start = (location.hash || '#about').slice(1);
    // hide everything first
    sections.forEach(sec => sec.classList.add('is-hidden'));
    showSection(start, {push:false, focus:false});
    setActiveLink(start);
    // keep at top
    window.scrollTo({top: 0, left: 0, behavior: 'instant'});
  });
})();

// Visit counter
const counter = document.getElementById("visitor-counter");

const API_URL = "https://adzntr63gd.execute-api.us-east-1.amazonaws.com/counterID";
const LAST_TS_KEY = "lastViewTimestamp";
const LAST_VIEWS_KEY = "lastViewsValue";
const FIVE_MINUTES = 5 * 60 * 1000;

// 1) Always render something immediately
const cachedViews = Number(localStorage.getItem(LAST_VIEWS_KEY));
if (!Number.isNaN(cachedViews)) {
  counter.textContent = `Views = ${cachedViews}`;
} else {
  counter.textContent = "Loading…";
}

async function fetchAndRender() {
  const res = await fetch(API_URL, { method: "GET", cache: "no-store" });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  
  const data = await res.json();

  counter.textContent = `Views = ${data.views}`;
  localStorage.setItem(LAST_VIEWS_KEY, String(data.views));
  localStorage.setItem(LAST_TS_KEY, String(Date.now()));
}

// 2) Throttle: call API only if > 5 minutes since last success
const lastTs = Number(localStorage.getItem(LAST_TS_KEY) || 0);
const now = Date.now();

if (now - lastTs > FIVE_MINUTES) {
  fetchAndRender().catch(err => {
    console.error("Fetch failed:", err);
    // Keep whatever is already displayed (cached or 'Loading…')
    if (Number.isNaN(cachedViews)) counter.textContent = "Error";
  });
} else {
  // Throttled: do not call API, do not show error
  // The cached value is already rendered above
  console.log("Skip API call — within 5 minutes window");
}
