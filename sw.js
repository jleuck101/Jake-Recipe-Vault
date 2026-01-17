// Recipe Book Service Worker (cloud-only friendly)
// - Caches the app shell so the site loads offline after first visit
// - Caches images as you view them (so gallery stays usable offline)
// - Does NOT cache recipes.json (cloud-only)

// Bump this when you deploy changes
const CACHE_NAME = "recipe-book-cache-v7";

// Core "app shell" assets to precache
const CORE_ASSETS = [
  "./",
  "./index.html",
  "./sw.js"
];

// Install: cache core assets
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(CORE_ASSETS))
  );
  self.skipWaiting();
});

// Activate: cleanup old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.map((k) => (k !== CACHE_NAME ? caches.delete(k) : null)))
    )
  );
  self.clients.claim();
});

// Fetch strategy:
// - Images: cache-first (once viewed, they stay available offline)
// - Navigation/documents/scripts/styles: network-first with cache fallback
// - Other GET: network-first with cache fallback
self.addEventListener("fetch", (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle same-origin requests
  if (url.origin !== self.location.origin) return;

  // Only cache GET requests (avoid caching POST/PUT/etc)
  if (req.method !== "GET") return;

  // Images: cache-first
  if (req.destination === "image") {
    event.respondWith(
      caches.match(req).then((hit) =>
        hit ||
        fetch(req)
          .then((res) => {
            const copy = res.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, copy));
            return res;
          })
          .catch(() => hit)
      )
    );
    return;
  }

  // Documents (including index.html navigation): network-first, fallback to cache, then fallback to index.html
  if (req.mode === "navigate" || req.destination === "document") {
    event.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(req, copy));
          return res;
        })
        .catch(() =>
          caches.match(req).then((hit) => hit || caches.match("./index.html"))
        )
    );
    return;
  }

  // Everything else: network-first, fallback to cache
  event.respondWith(
    fetch(req)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(req, copy));
        return res;
      })
      .catch(() => caches.match(req))
  );
});
