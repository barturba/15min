// Service Worker for Fifteen Min App
// Handles caching for offline functionality and push notifications

const CACHE_NAME = 'fifteen-min-v1.0.0';
const urlsToCache = [
  '/',
  '/assets/application.css',
  '/assets/application.js',
  '/icon.png',
  '/icon.svg'
];

// Install event - cache resources
self.addEventListener('install', event => {
  console.log('Service Worker: Installing');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Service Worker: Caching resources');
        return cache.addAll(urlsToCache);
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('Service Worker: Activating');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
      .catch(() => {
        // If both cache and network fail, serve offline page
        if (event.request.destination === 'document') {
          return caches.match('/');
        }
      })
  );
});

// Push notification event
self.addEventListener("push", async (event) => {
  console.log('Service Worker: Push notification received');

  if (event.data) {
    const { title, options } = await event.data.json();
    event.waitUntil(
      self.registration.showNotification(title, options)
    );
  }
});

// Notification click event
self.addEventListener("notificationclick", function(event) {
  console.log('Service Worker: Notification clicked');

  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      const url = event.notification.data?.path || '/';

      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i];
        let clientPath = (new URL(client.url)).pathname;

        if (clientPath === url && "focus" in client) {
          return client.focus();
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(url);
      }
    })
  );
});
