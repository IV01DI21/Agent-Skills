---
name: frontend-development
description: Building and changing user interfaces for the web — components, pages, forms, tables, dashboards, state management, data fetching, responsive layout, accessibility, performance (Core Web Vitals), SEO, and frontend security. Use for ANY task that creates or changes something a user sees or clicks, in React, Next.js, Vue, Vite or plain HTML/CSS/JS — a new page, a component, a form with validation, a loading or empty state, a slow page, a layout bug, a mobile view — even when the user only says "add a button" or "make this page".
---

# Frontend Development

Open-source skill. Licensed MIT (see repository LICENSE).

## Mental model

A screen is finished when it handles **every state**, not just the happy
one: loading, empty, error, partial, success, disabled, and too-much-data.
The existing UI is the design spec — reuse its tokens, components and
patterns before creating anything new. The browser is hostile territory:
nothing enforced only in the frontend is enforced.

## Rules (apply every time)

1. **Reuse before you build.** Look for an existing component, token, hook
   or utility first. Build global, reusable, prop-driven components — never
   hard-code styles into individual pages. A redesign should be a change in
   one place.
2. **Design tokens as CSS variables.** Colours, spacing, radius, shadows,
   typography and transitions live in one global stylesheet; components
   reference tokens, never raw values.
3. **Every async action shows its state.** A button that triggers a request
   is immediately disabled and shows loading (prevents double-submit).
   Skeletons for initial loads, spinners for small local actions, progress
   for anything over ~2 seconds.
4. **Never a blank screen.** Lists, tables and dashboards with no data show
   an empty state: icon, explanation, and a clear call to action.
5. **Errors are specific and placed where they occur.** Inline field
   validation (on blur/typing), not only on submit. "Invalid email
   address", not "An error occurred". Toasts for success and minor issues;
   modals only for critical problems.
6. **Destructive actions are distinct and confirmed.** Danger styling plus a
   confirmation step; prefer soft delete with an "Undo" toast.
7. **Put state in the lowest place that works**: URL params → local
   component state → server-state cache → context → global store. See
   `references/state-and-structure.md`.
8. **Accessible by default.** Semantic HTML, labels on inputs, keyboard
   operable, visible focus, focus trapped in modals, WCAG AA contrast, tap
   targets ≥ 44×44 px.
9. **Mobile first and responsive.** Grid/Flexbox, fluid type with
   `clamp()`, consistent breakpoints.
10. **Frontend checks are UX, not security.** Validate again on the server;
    never put secrets in client code; never render untrusted HTML
    unsanitised.
11. **Type everything.** Props interfaces on every component; no `any`.
12. **Verify in a real browser** at mobile and desktop widths before saying
    it's done.

## Workflow

1. Find the nearest existing screen/component and copy its structure.
2. List the states the UI must handle (loading, empty, error, success,
   permissions, long text, many rows, small screen).
3. Build from existing primitives; add a new shared component only if it
   will be reused.
4. Wire data with the project's fetching pattern; handle failure.
5. Check keyboard navigation, focus, contrast, and responsive behaviour.
6. Run type check, lint and tests; view it in the browser.

## Reference files — load on demand

- `references/state-and-structure.md` — state hierarchy, forms, project
  folder structure, naming conventions, component template, server vs
  client components. **Load when adding state, creating a component, or
  scaffolding a project.**
- `references/ux-and-accessibility.md` — full UX state rules, form
  patterns, WCAG checklist, responsive rules. **Load when building a form,
  table, modal or any new screen.**
- `references/performance-seo-security.md` — Core Web Vitals, asset and
  bundle optimisation, caching, SEO/structured data, frontend security
  (XSS, CSP, tokens). **Load when a page is slow, before launch, for
  public-facing pages, or when rendering user content.**

## Pre-flight (run before saying "done")

- [ ] Reused existing components/tokens; no hard-coded colours or spacing.
- [ ] Loading, empty, error and success states all exist.
- [ ] Buttons disable and show loading during requests.
- [ ] Forms validate inline with specific messages; server errors shown.
- [ ] Destructive actions confirmed or undoable.
- [ ] Keyboard, focus, labels and contrast checked.
- [ ] Works at mobile, tablet and desktop widths.
- [ ] No secrets in client code; no unsanitised HTML injection.
- [ ] Types, lint and tests pass; verified in a browser.
