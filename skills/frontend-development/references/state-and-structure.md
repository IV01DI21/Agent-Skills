# State, Structure and Conventions

## State hierarchy — use the lowest level that works

Do not reach for a global store by default. State lives as close to where
it is used as possible.

| Level | Where | Use for | Why |
|---|---|---|---|
| 1 | **URL search params** | Filters, search, pagination, active tab, sort | Shareable, survives refresh, Back/Forward work |
| 2 | **Local component state** | Toggles, open/closed, uncommitted input | Isolated; destroyed with the component |
| 3 | **Server-state cache** (React Query / SWR / framework cache) | Anything fetched from the API | Needs caching, refetching, staleness — never copy API responses into a global store |
| 4 | **Context** | Theme, current user, rarely changing config | Re-renders all consumers — bad for frequent updates |
| 5 | **Global store** (e.g. Zustand) | Complex UI state shared by unrelated components (cart drawer, global player) | Lightweight; prefer over Redux unless maintaining a legacy app |

## Forms

- Use a form library (e.g. React Hook Form) rather than hand-written
  `onChange` + `useState` for complex forms — avoids a re-render per
  keystroke.
- Validate with a schema (e.g. Zod); **share the same schema with the
  server** so client and server rules can't drift.
- Use correct HTML input types (`email`, `tel`, `number`, `date`) to get
  the right mobile keyboard and native behaviour.
- Preserve user input on error; focus the first invalid field.

## Data fetching

- Prefer rendering data on the server where the framework supports it;
  fetch on the client for highly interactive or user-specific live data.
- Debounce search-as-you-type (~300 ms).
- Paginate every list; never render unbounded arrays.
- Optimistic updates for snappy mutations — update the UI immediately,
  roll back if the server reports failure.
- Notifications: success toast for mutations (not for reads); the API's
  message for expected errors (400/403/404); a generic "Something went
  wrong. Please try again." for 500s and network failures.

## Server vs client components (Next.js App Router and similar)

- Default to Server Components. Add `"use client"` only where
  interactivity, browser APIs or hooks are needed, and push it as far down
  the tree as possible.
- Never import database clients or server secrets into client components.
- Only variables with the public prefix (`NEXT_PUBLIC_`, `VITE_`) reach
  the browser — treat anything with that prefix as public.

## Reference folder structure (Next.js App Router project)

```
src/
├── app/                    pages, layouts, route groups
│   ├── layout.tsx          root layout
│   ├── not-found.tsx       custom 404 (always branded)
│   ├── error.tsx           global error boundary
│   ├── loading.tsx         global loading fallback (skeleton)
│   ├── globals.css         design tokens, reset, typography
│   ├── (auth)/             login, register
│   ├── (dashboard)/        protected area with its own layout
│   └── api/                route handlers (webhooks, public API, health)
├── components/
│   ├── ui/                 design-system primitives (Button, Card, Input, Modal, Table, Toast, Skeleton)
│   ├── layout/             Sidebar, Navbar, Footer
│   └── shared/             EmptyState, ConfirmDialog, PageHeader
├── lib/                    db client, auth config, utils, constants, env
├── actions/                server actions grouped by domain (`order.actions.ts`)
├── hooks/                  custom hooks (`useDebounce.ts`)
├── schemas/                validation schemas (`order.schema.ts`)
├── stores/                 global client stores (`useUIStore.ts`)
└── types/                  shared types
```

Follow the project's existing structure when one exists; use this only for
new projects.

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Components (folder + file) | PascalCase | `Button/Button.tsx` |
| Scoped styles | Match the component | `Button.module.css` |
| Hooks | camelCase with `use` | `useDebounce.ts` |
| Stores | `use…Store` | `useAuthStore.ts` |
| Server actions / schemas / types | domain + suffix | `auth.actions.ts`, `auth.schema.ts`, `api.types.ts` |
| Functions | camelCase verbs | `formatCurrency` |
| Constants | UPPER_SNAKE_CASE | `MAX_FILE_SIZE` |
| Types / interfaces | PascalCase | `OrderStatus` |
| Booleans | `is` / `has` / `should` | `isLoading` |
| Event handlers | `handle…` | `handleSubmit` |
| CSS variables | kebab-case | `--text-muted` |

## Component template

```tsx
import styles from './Button.module.css';

interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
}

export default function Button({
  children,
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  onClick,
}: ButtonProps) {
  return (
    <button
      className={`${styles.button} ${styles[variant]} ${styles[size]}`}
      disabled={disabled || isLoading}
      aria-busy={isLoading}
      onClick={onClick}
    >
      {isLoading ? <span className={styles.spinner} /> : children}
    </button>
  );
}
```

Component rules: typed props interface, defaults via destructuring,
composition (`children`) over prop drilling, one component per folder with
its scoped styles.

## Design tokens (minimum set in the global stylesheet)

Colours (background, text, muted, accent, danger, success, warning) ·
spacing scale · typography (font families, sizes) · radius scale ·
shadows · transitions. Define light/dark by redefining the same variables.
Never show raw enum values to users — map them to display labels in one
constants file.
