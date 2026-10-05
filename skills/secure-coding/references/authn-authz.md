# Authentication and Authorization

## Passwords

- Hash with **Argon2id** (preferred), or bcrypt (cost ≥ 12) / scrypt. Never
  MD5/SHA-x alone, never reversible encryption.
- Minimum length (≥ 8, ideally 12+), allow long passphrases and all
  characters; check against breached-password lists; no forced periodic
  rotation or composition rules.
- Constant-time comparison; identical response and timing for "unknown
  user" and "wrong password" to prevent enumeration.
- Rate limit and lock out progressively per account and per IP.
- Offer MFA (TOTP / WebAuthn passkeys preferred over SMS); require it for
  admins.

## Password reset / email verification

- Single-use, random (≥ 128-bit CSPRNG), short-lived token; store only its
  hash.
- Same response whether or not the account exists.
- Invalidate existing sessions after a password change.

## Sessions (server-side, cookie-based)

- Session ID: random ≥ 128 bits, regenerated on login and privilege change.
- Cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict`), narrow
  `Path`/`Domain`, `__Host-` prefix when possible.
- Idle and absolute timeouts; server-side invalidation on logout.
- CSRF protection for cookie-authenticated state-changing requests
  (SameSite + anti-CSRF token or origin check).

## JWT / bearer tokens

- Verify signature, `alg` (pin the expected algorithm; reject `none`),
  `exp`, `nbf`, `iss`, `aud` on every request.
- Short-lived access tokens (minutes) + rotating refresh tokens with reuse
  detection; keep a revocation path.
- No sensitive data in the payload — it is only encoded, not encrypted.
- Browser storage: prefer `HttpOnly` cookies over `localStorage` (readable
  by any XSS).
- Strong keys; asymmetric (RS256/ES256/EdDSA) when multiple services verify.

## OAuth 2.0 / OpenID Connect

- Use **Authorization Code + PKCE** for web, SPA and mobile. No implicit
  flow, no password grant.
- Validate `state` (CSRF) and `nonce` (replay); exact-match redirect URIs.
- Validate the ID token (signature, `iss`, `aud`, `exp`).
- Request minimal scopes. Use a maintained library — don't hand-roll.

## Authorization

- **Deny by default.** Enforce on the server for every request, at a
  central, reusable point (middleware/policy layer) — not scattered `if`s,
  never only by hiding UI.
- **Object-level**: scope every query by the owner/tenant
  (`WHERE id = ? AND tenant_id = ?`). Don't trust IDs from the client.
  This is the #1 real-world vulnerability (IDOR/BOLA).
- **Function-level**: admin and privileged operations check role/permission
  explicitly.
- **Property-level**: allow-list which fields a role can read and write —
  prevents mass assignment (`role`, `isAdmin`, `price`) and over-exposure.
- Models: RBAC (roles → permissions) for most apps; ABAC/policy-based when
  rules depend on attributes (ownership, department, time).
- Multi-tenancy: tenant ID comes from the authenticated session, never from
  request input; consider row-level security in the database as a second
  layer.
- Re-authenticate for sensitive actions (change email/password, payouts).
- Test it: for each endpoint, try as anonymous, as another user, as a lower
  role.

## API keys and service-to-service

- Keys are random, stored hashed, scoped, rotatable, and revocable; show
  once at creation.
- Prefer short-lived credentials / workload identity / mTLS between
  services over long-lived shared secrets.
