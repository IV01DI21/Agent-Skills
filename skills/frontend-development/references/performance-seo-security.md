# Performance, SEO and Frontend Security

## Core Web Vitals (targets)

| Metric | Target | Measures |
|---|---|---|
| **LCP** — Largest Contentful Paint | < 2.5 s | How fast the main content appears |
| **INP** — Interaction to Next Paint | < 200 ms | How fast the page responds to input |
| **CLS** — Cumulative Layout Shift | < 0.1 | Visual stability |

## Assets

**Images**
- Never ship raw, unoptimised images. Use WebP/AVIF, sized for the slot.
- Lazy-load below the fold; prioritise the LCP image.
- Always set `width` and `height` (or aspect-ratio) to prevent layout
  shift. Use the framework's image component where available.

**Fonts**
- Self-host or use the framework's font loader; `font-display: swap`;
  subset and limit weights.

**JavaScript**
- Code-split by route; lazy-load heavy, non-critical components.
- Audit dependencies — prefer native APIs or light libraries over heavy
  ones; check the bundle with an analyser.
- Avoid shipping server-only code to the client.

## Rendering performance

- Skeletons instead of blank screens.
- Debounce input-driven requests (~300 ms); throttle scroll/resize work.
- Virtualise very long lists.
- Avoid needless re-renders: stable keys, state kept low, memoise only
  where measured.
- Prefetch critical routes on hover/viewport.
- Animate `transform` and `opacity`, not layout properties.

## Caching layers

- **Browser** — long `Cache-Control` with hashed filenames for static
  assets.
- **CDN/edge** — cache public pages and assets.
- **Server** — short-TTL cache for expensive responses.
- Never cache personalised responses in shared caches.

## Pre-launch checks

1. Lighthouse (incognito): target 90+ for Performance, Accessibility, Best
   Practices, SEO.
2. Bundle analyser: no unexpectedly large dependencies.
3. Test on a throttled connection and a mid-range phone.
4. Custom 404 and error pages exist; no console errors.

## SEO and discoverability (public pages)

- Unique `<title>` and meta description per page; Open Graph/Twitter tags
  with a default share image.
- One `<h1>`; logical heading hierarchy; semantic landmarks.
- Structured data (JSON-LD) for organisations, products, articles, FAQs.
- Crawlable links (`<a href>`), canonical URLs, sitemap, robots rules.
- Server-render or pre-render content that must be indexed.
- Content written as clear, authoritative, directly quotable answers —
  this serves classic search, answer boxes and AI assistants alike.

## Frontend security

- **XSS**: rely on framework auto-escaping. Never pass untrusted data to
  `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `document.write` —
  sanitise with a maintained sanitiser (e.g. DOMPurify) if rich HTML is
  required. Validate URL schemes for user-supplied links (block
  `javascript:`).
- **Content Security Policy**: allow scripts/styles/images only from
  trusted origins; avoid `unsafe-inline` (use nonces/hashes).
- **Tokens**: keep session tokens in `HttpOnly`, `Secure`, `SameSite`
  cookies — not `localStorage`.
- **Secrets**: anything in the bundle is public. API keys that must stay
  secret are used server-side only.
- **Authorization**: hiding a button is not access control; the server
  must enforce it.
- **Third-party scripts**: minimise; pin versions; use Subresource
  Integrity for CDN scripts.
- **External links** opened in a new tab: `rel="noopener noreferrer"`.
- **CORS** is configured on the server with an explicit origin list —
  never `*` with credentials.
