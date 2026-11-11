// FisiCarlão — service worker. Ao mudar qualquer arquivo de www/, aumente a VERSAO.
const VERSAO = "fisicarlao-v2";
const ARQUIVOS = [
  "./", "./index.html", "./data.js", "./katex.min.js", "./manifest.webmanifest",
  "./fonts/fonts.css", "./fonts/BricolageGrotesque-0.woff2", "./fonts/JetBrainsMono-1.woff2", "./fonts/PlusJakartaSans-2.woff2",
  "./img/logo-carlao.png", "./img/logo-carlao-branca.png",
  "./icons/icon-192.png", "./icons/icon-512.png", "./icons/maskable-512.png",
  "./icons/apple-touch-icon.png", "./icons/favicon-32.png"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSAO).then(c => c.addAll(ARQUIVOS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys().then(ks => Promise.all(ks.filter(k => k !== VERSAO).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin !== location.origin) return; // Kiwify, YouTube etc. passam direto

  // Páginas: tenta a rede para pegar atualização; sem internet, usa a cópia guardada.
  if (req.mode === "navigate") {
    e.respondWith(
      fetch(req).then(r => { const cp = r.clone(); caches.open(VERSAO).then(c => c.put("./index.html", cp)); return r; })
        .catch(() => caches.match("./index.html"))
    );
    return;
  }

  // Demais arquivos: cópia guardada primeiro.
  e.respondWith(caches.match(req, { ignoreSearch: true }).then(hit => hit || fetch(req).then(r => {
    if (r.ok) { const cp = r.clone(); caches.open(VERSAO).then(c => c.put(req, cp)); }
    return r;
  })));
});
