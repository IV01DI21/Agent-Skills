# OWASP API Security Top 10 (2023)

| # | Risk | What to check | Fix |
|---|---|---|---|
| API1 | **Broken Object Level Authorization (BOLA)** | Any endpoint taking an object ID: can a user access another user's object by changing the ID? | Check ownership/tenant on every object access; scope queries by the authenticated principal; use unpredictable IDs as defence in depth only |
| API2 | **Broken Authentication** | Weak token validation, no rate limit on login/OTP, credentials in URLs, long-lived tokens, unauthenticated "internal" endpoints | Standard auth library; validate tokens fully; rate limit; short-lived tokens with rotation; MFA |
| API3 | **Broken Object Property Level Authorization** | Responses returning whole objects (excessive data exposure); request bodies bound straight to models (mass assignment) | Explicit response DTOs; allow-list readable and writable fields per role |
| API4 | **Unrestricted Resource Consumption** | No pagination limit, unbounded page size, huge uploads, expensive queries, unlimited GraphQL depth/complexity, costly third-party calls (SMS, email) | Rate limits and quotas; max page size; payload/upload limits; timeouts; query depth/complexity limits; spending caps |
| API5 | **Broken Function Level Authorization** | Admin or privileged operations reachable by normal users (changing method `GET`→`DELETE`, guessing `/admin/...`) | Deny by default; role/permission check on every function; separate admin routes with central guard |
| API6 | **Unrestricted Access to Sensitive Business Flows** | Flows abusable by automation: mass purchasing, signup spam, referral abuse, scraping | Identify sensitive flows; device/behaviour checks; per-user/business limits; human verification where warranted |
| API7 | **Server-Side Request Forgery** | API fetches a client-supplied URL (webhooks, import-by-URL, previews) | Allow-list schemes/hosts/ports; block private and metadata addresses; disable redirects; isolate the fetcher |
| API8 | **Security Misconfiguration** | Verbose errors, missing TLS, permissive CORS, unnecessary HTTP methods, missing headers, unpatched stack | Hardened repeatable config; restrict methods; strict CORS; generic errors |
| API9 | **Improper Inventory Management** | Old API versions, undocumented or debug endpoints, staging hosts with production data still reachable | Maintain an API inventory and OpenAPI spec; retire old versions; same protections on every environment and version |
| API10 | **Unsafe Consumption of APIs** | Trusting third-party API responses: unvalidated data, blind redirect following, no timeouts | Validate and sanitise third-party data like user input; TLS; timeouts and limits; allow-list redirects |

## API-specific checks

- **Every endpoint in the spec and every endpoint NOT in the spec** —
  enumerate the router, not the documentation.
- **GraphQL**: disable introspection in production if not needed; depth and
  complexity limits; authorize at the resolver/field level; batch-query
  abuse limits.
- **Bulk/batch endpoints**: authorization per item, not per request.
- **Content type**: reject unexpected `Content-Type`; strict JSON schema
  with unknown properties rejected.
- **Webhooks (inbound)**: verify signature and timestamp; make handlers
  idempotent.
- **Error format**: consistent, generic, no stack traces or query text.
- **Rate-limit keys**: per user/API key and per IP; return `429` with
  `Retry-After`.
