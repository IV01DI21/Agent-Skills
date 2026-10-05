# Security Review Checklist

## Input and output

- [ ] All input (body, query, path, headers, cookies, files, webhooks,
      messages from queues) validated against a schema with allow-lists.
- [ ] SQL/NoSQL/LDAP/ORM queries parameterised; no string-built queries;
      dynamic identifiers (sort column, table) mapped from an allow-list.
- [ ] No untrusted data in shell commands, `eval`, template compilation,
      deserialisers, or dynamic imports.
- [ ] Output auto-escaped; raw-HTML sinks (`innerHTML`,
      `dangerouslySetInnerHTML`, `v-html`, `|safe`) only with sanitised
      content.
- [ ] Redirect targets validated against an allow-list (no open redirect).
- [ ] Server-side requests to user-supplied URLs restricted (allow-list
      hosts, block private/link-local ranges, no redirects) — SSRF.
- [ ] File paths built from user input are normalised and confined to a
      base directory — path traversal.

## File uploads

- [ ] Size limit; type validated by content (magic bytes) plus extension
      allow-list.
- [ ] Stored outside the web root or in object storage, under a generated
      name; served with correct `Content-Type`, `Content-Disposition`,
      `X-Content-Type-Options: nosniff`, ideally from a separate domain.
- [ ] Images re-encoded; archives checked for zip bombs / traversal; malware
      scan where risk warrants.

## Authentication, sessions, authorization

- [ ] See `authn-authz.md`. Every endpoint: authenticated? object-level
      check? role check? field allow-list?
- [ ] Rate limiting on login, reset, OTP, signup and expensive endpoints.
- [ ] CSRF protection on cookie-authenticated state changes.

## Secrets and configuration

- [ ] No secrets in source, history, images, client bundles or logs; `.env`
      git-ignored; secret scanning in CI.
- [ ] Debug mode, default accounts, sample apps, directory listing and
      verbose errors disabled in production.
- [ ] Admin interfaces, databases, caches and queues not exposed to the
      internet.
- [ ] Least-privilege DB user and cloud/IAM roles.

## Cryptography and data protection

- [ ] TLS 1.2+ everywhere, HSTS enabled; internal traffic encrypted where
      the network isn't trusted.
- [ ] Sensitive data at rest encrypted; keys in a KMS, rotated, separate
      from data.
- [ ] No home-made crypto, no ECB, no static IVs/nonces, no MD5/SHA-1 for
      security; CSPRNG for tokens.
- [ ] Data minimised: collect, return, log and retain only what's needed;
      personal data handled per applicable law.

## HTTP security headers

- [ ] `Content-Security-Policy` (no `unsafe-inline` for scripts; nonces or
      hashes)
- [ ] `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `frame-ancestors` in CSP (or `X-Frame-Options: DENY`) — clickjacking
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `Permissions-Policy` restricting unused features
- [ ] CORS: explicit origin allow-list; never reflect arbitrary origins with
      credentials; no `*` with credentials.

## Dependencies and supply chain

- [ ] Lockfile committed; versions pinned; automated vulnerability scanning
      and updates.
- [ ] New packages vetted (typosquatting, maintainers, install scripts).
- [ ] CI/CD: least-privilege tokens, pinned actions/images, protected
      branches, signed/verified artefacts, no secrets in build logs.
- [ ] Container images minimal, non-root, scanned.

## Errors, logging, monitoring

- [ ] Generic user-facing errors; details only in server logs.
- [ ] Exceptions handled so failures deny access and release resources
      (fail closed).
- [ ] Security events logged with who/what/when/where; logs protected from
      tampering and free of secrets, tokens and sensitive personal data.
- [ ] Log injection prevented (structured logging, newline stripping).
- [ ] Alerts on anomalies (login failures spike, access-denied spike).

## Business logic

- [ ] Limits enforced server-side (quantity, price, balance, quotas).
- [ ] Race conditions on critical operations prevented (transactions, row
      locks, unique constraints, idempotency keys).
- [ ] Workflow steps can't be skipped or replayed.
- [ ] Anti-automation on abusable flows (signup, checkout, voting).
