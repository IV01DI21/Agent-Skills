---
name: backend-development
description: Building and changing server-side code — API endpoints and server actions, request validation, business logic, database schema and queries, migrations, authentication and authorization checks, multi-tenant data isolation, webhooks and third-party integrations, background jobs, rate limiting, configuration and secrets, Docker deployment and CI/CD. Use for ANY backend task in Node.js, Next.js, Express, Python, Go or similar — "add an endpoint", "create a table", "fix this query", "integrate Stripe", "deploy this", "why is the API slow" — even when the user doesn't say "backend".
---

# Backend Development

Open-source skill. Licensed MIT (see repository LICENSE).

## Mental model

A request crosses a trust boundary. On the server side of that boundary
every handler does the same five things in the same order: **authenticate
→ authorize → validate → execute → respond**. Keep transport handlers thin
and business rules in one reusable place. Anything that can be retried
will be retried, so writes must be safe to repeat.

## Rules (apply every time)

1. **Authenticate and authorize every protected request on the server** —
   in the handler/action itself, not only in routing middleware (defence
   in depth). Check role AND ownership/tenant.
2. **Validate all untrusted input at the boundary** with a schema
   validator (body, params, query, headers, webhook payloads, env) before
   business logic runs.
3. **Thin handlers.** Parse input → call business logic → map known errors
   → return. Business rules live in a service layer; data access behind
   repository/query modules.
4. **One response contract.** Every endpoint returns the same envelope and
   correct HTTP status codes; never `200` for a failure. See
   `references/api-design.md`.
5. **Never leak internals.** No stack traces, SQL, ORM errors or file
   paths in responses — generic message to the client, detail in
   structured logs (without secrets).
6. **Parameterised queries only**; never build SQL with string
   interpolation or use "unsafe raw" query helpers on user input.
7. **Transactions for multi-step writes** that must succeed or fail
   together.
8. **Every list is paginated; select only needed columns; no queries in
   loops (N+1).**
9. **Tenant ID and user ID come from the session, never from the client.**
10. **Schema changes go through migrations** — never hand-edit production
    structures; never edit an applied migration; back up before migrating
    production.
11. **Config from environment, validated at startup (fail fast).** Never
    commit secrets; commit `.env.example`.
12. **Verify it actually runs.** After a change, confirm the server is up,
    call the endpoint, check the logs — and say how you verified.

## Workflow

1. Find an existing endpoint/action of the same kind and mirror it.
2. Define the contract: input schema, output shape, error cases, who may
   call it.
3. Schema change needed? Write the migration first; consider indexes and
   backward compatibility.
4. Implement: auth → authorization → validation → service logic →
   response.
5. Test: success, invalid input, unauthenticated, wrong role, other
   user's/tenant's record, not found, duplicate/retry.
6. Run type check, lint, tests; exercise the endpoint for real.

## Reference files — load on demand

- `references/api-design.md` — response envelope, status codes, error
  handling, REST conventions, rate limiting, health checks. **Load when
  creating or changing an endpoint or server action.**
- `references/database.md` — schema conventions, base fields, soft
  deletes, relationships, indexing, enums, audit log, seeding, migrations,
  query performance. **Load when touching schema, migrations or
  queries.**
- `references/auth-and-multitenancy.md` — login/registration/reset flows,
  RBAC model, authorization helper, tenant isolation, system vs tenant
  roles. **Load when implementing auth, roles, or any tenant-scoped
  data.**
- `references/integrations-and-deployment.md` — webhooks, idempotency,
  environment/secrets management, Docker rules, CI/CD pipeline, backups.
  **Load when integrating a third-party service, configuring environments,
  or deploying.**

## Pre-flight (run before saying "done")

- [ ] Handler authenticates, authorizes (role + ownership/tenant) and
      validates before doing work.
- [ ] Response uses the standard envelope and correct status codes; no
      internals leaked.
- [ ] Queries parameterised, paginated, free of N+1; indexes considered.
- [ ] Multi-step writes are transactional; retried requests are safe.
- [ ] Migration created (not hand-edited DB); reversible/backward
      compatible.
- [ ] New config added to `.env.example` and validated at startup; no
      secrets committed.
- [ ] Tests cover success, invalid input and authorization failures.
- [ ] I ran it and state how it was verified.
