# UX States and Accessibility

## The states every screen needs

| State | Requirement |
|---|---|
| **Loading (initial)** | Skeleton matching the final layout — prevents layout shift |
| **Loading (action)** | Trigger disabled + inline spinner or text change ("Save" → "Saving…") |
| **Long task (> 2 s)** | Progress indicator |
| **Empty** | Icon/illustration + explanation + call to action ("Create your first item") |
| **Error (expected)** | Specific message next to the cause, with a way to recover |
| **Error (unexpected)** | Friendly fallback via an error boundary; never a blank page or stack trace |
| **Success** | Toast or inline confirmation for mutations |
| **No permission** | Explain and offer a way back; don't render a broken page |
| **Overflow** | Long text truncates or wraps; large lists paginate or virtualise |

## Forms

- Label every field (visible `<label>` tied to the input).
- Inline validation on blur or while typing; don't wait for submit.
- Messages are specific and say how to fix it.
- Mark required fields; show format hints before the error, not after.
- Submit button disabled while submitting; keep entered data on failure.
- Show server-side field errors beside the right field.

## Destructive actions

- Visually distinct (danger colour).
- Permanent deletion requires a confirmation dialog naming what is
  deleted.
- Prefer soft delete + "Undo" toast over immediate hard delete.

## Tables and lists

- Paginate; show total count.
- Sort, filter, search and page state in the URL.
- Sticky header for long tables; sensible column priorities on small
  screens (hide or stack lower-priority columns).
- Row actions labelled; icon-only buttons need an accessible name.

## Accessibility checklist (WCAG 2.x AA)

**Structure**
- [ ] Semantic elements: `<header> <nav> <main> <article> <section>
      <footer> <button> <a>` — not clickable `<div>`s.
- [ ] One `<h1>` per page; heading levels not skipped.
- [ ] Page `lang` set; meaningful `<title>`.

**Keyboard**
- [ ] Everything operable by keyboard in a logical tab order.
- [ ] Visible focus indicator on every interactive element.
- [ ] Modals trap focus, close on `Esc`, return focus to the trigger.
- [ ] Skip-to-content link on pages with heavy navigation.

**Perception**
- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for large text and UI components).
- [ ] Information never conveyed by colour alone (add icon/text).
- [ ] Images have `alt` (empty `alt=""` for decorative).
- [ ] Text resizes to 200% without loss; layout works at 320 px width.
- [ ] Respect `prefers-reduced-motion`.

**Interaction**
- [ ] Tap targets ≥ 44×44 px (larger for field/one-handed use).
- [ ] Form inputs have labels; errors linked with `aria-describedby`;
      invalid fields marked `aria-invalid`.
- [ ] Dynamic updates announced (`aria-live` for toasts and async
      results).
- [ ] ARIA only when native HTML can't express it; no ARIA is better than
      wrong ARIA.

## Responsive design

- Mobile first: base styles for small screens, enhance upward.
- Layout with Grid and Flexbox; fluid sizing with `clamp()`, `min()`,
  `max()`.
- One consistent set of breakpoints (e.g. mobile < 768 px, tablet
  < 1024 px, desktop ≥ 1024 px).
- No horizontal page scroll; wide content (tables, code) scrolls inside
  its own container.
- Test on real widths: ~360, ~768, ~1280.

## Internationalisation basics

- No hard-coded user-facing strings scattered through components — keep
  them in one place even before translating.
- Format dates, numbers and currency with `Intl` APIs.
- Allow for text expansion (~30%) and right-to-left layouts if relevant.
