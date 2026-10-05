# API Design and Error Handling

Applies to REST endpoints, server actions, RPC and GraphQL alike.

## Standard response envelope

Every endpoint or server action returns the same predictable shape so the
client can always parse it.

```ts
interface ApiResponse<T = unknown> {
  success: boolean;    // true if the operation succeeded
  data?: T;            // payload (only when success is true)
  error?: string;      // human-readable message (only when false)
  errorCode?: string;  // machine-readable code, e.g. 'VALIDATION_FAILED'
  meta?: unknown;      // e.g. pagination: { total, page, limit }
}
```

```json
{ "success": true, "data": { "id": "123", "name": "John" }, "meta": { "total": 1 } }
```

```json
{ "success": false, "error": "You do not have permission to delete this order.", "errorCode": "FORBIDDEN" }
```

Follow the project's existing contract if it already has one.

## HTTP status codes

| Code | Use |
|---|---|
| 200 OK | Successful GET / PUT / PATCH / DELETE |
| 201 Created | Resource created (POST) |
| 204 No Content | Success with no body |
| 400 Bad Request | Validation error, malformed input |
| 401 Unauthorized | Not logged in / missing or invalid token |
| 403 Forbidden | Logged in but not permitted |
| 404 Not Found | Resource doesn't exist (or isn't visible to this user) |
| 409 Conflict | Duplicate / state conflict |
| 422 Unprocessable | Semantically invalid input (if the project distinguishes it from 400) |
| 429 Too Many Requests | Rate limit exceeded (include `Retry-After`) |
| 500 Internal Error | Unexpected failure — never expose details |

Never return `200` when the operation failed.

## Error handling

- **Validate first.** Parse with a schema before business logic; return
  `400` with per-field errors (`{ "email": "Must be a valid email" }`).
- **Expected business errors** (insufficient funds, already exists) →
  return `success: false` with a clear message and code.
- **Unexpected errors** → log with context, return a generic message;
  in frameworks with error boundaries, throw so the boundary handles it.
- **Never leak** database errors, stack traces or query text.
  Bad: `"PrismaClientValidationError: Unknown argument 'foo'"`.
  Good: `"Invalid input provided."`
- Use a central error-mapping layer (middleware / wrapper) rather than
  try/catch boilerplate in every handler.
- Attach a request/correlation ID to logs and error responses.

## REST conventions

- Nouns, plural, lowercase, hyphenated: `/purchase-orders/{id}/items`.
- Methods: `GET` read (safe), `POST` create, `PUT` replace, `PATCH`
  partial update, `DELETE` remove. `PUT`/`DELETE` idempotent.
- Filtering, sorting, pagination via query params:
  `?status=pending&sort=-createdAt&page=2&limit=20`.
- Cap `limit` server-side. Prefer cursor pagination for large or
  fast-changing sets.
- Version public APIs (`/v1/…`); additive changes only within a version.
- Accept an `Idempotency-Key` header on non-idempotent creates that
  clients may retry (payments, orders).
- IDs exposed in APIs should be non-sequential (cuid/uuid); never expose
  auto-increment keys.
- Document the API (OpenAPI) and keep it in the repo.

## Layering

```
Route / handler / action   → HTTP concerns: parse, auth, map errors, respond
Service                    → business rules, transactions, orchestration
Repository / query module  → data access only
```

Group routes by domain. Put authorization, validation, error mapping and
request correlation in shared middleware. In Next.js: server actions for
internal form mutations; route handlers for webhooks, public APIs,
streaming and integrations; database clients stay server-only.

## Rate limiting

Classify routes by risk and set documented limits (starting points — tune
per project):

| Route class | Starting point |
|---|---|
| Standard API | ~100 requests / 10 s per client |
| Login, registration, password reset | ~5 requests / minute per client and per account |
| Webhooks | Limit only after signature verification; never blindly block provider retries |

- Use a **shared store** (e.g. Redis) when more than one app instance
  runs — per-process memory limits don't work when scaled out.
- Layer it: application limiter + reverse proxy/WAF limits.
- Return `429` with a retry hint; log a privacy-safe identifier.
- Make sure limits don't block health checks, webhooks or trusted
  internal traffic.
- Rate limiting is not a substitute for network isolation.

## Health check

Expose a health endpoint that verifies required dependencies (e.g.
`SELECT 1` against the database) and returns healthy/unhealthy **without
disclosing internal details**.

## Background work

- Anything slow (emails, PDFs, exports, third-party calls) goes to a job
  queue; respond immediately.
- Jobs are idempotent, retried with backoff, and failures land in a
  dead-letter queue that is monitored.

## Logging

Structured (JSON) logs with level, timestamp, request ID, user/tenant ID,
route and outcome. Never log passwords, tokens, secrets or full personal
data. Log security-relevant events (login, failure, denial, role change).
