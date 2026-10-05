---
name: secure-coding
description: Security engineering for application code and systems — threat modelling, authentication, authorization, session and token handling, input validation, cryptography, secrets management, secure defaults, dependency and supply-chain hygiene, logging, and security review of code or designs. Use whenever a task touches login, passwords, tokens, permissions, roles, user input, file uploads, payments, personal data, API keys, encryption, or infrastructure exposure, and for any "is this secure?", "security review", "harden this" or "threat model" request — even when the user doesn't mention security but the code handles untrusted input or sensitive data. Pair with owasp-top-10 for a category-by-category audit.
---

# Secure Coding

Open-source skill. Licensed MIT (see repository LICENSE). Defensive use:
building, reviewing and hardening systems you own or are authorised to test.

## Mental model

All input is hostile until validated; every request is unauthenticated and
unauthorised until proven otherwise **on the server**; every secret will
leak if it can. Security is built from layered defaults (defence in depth),
not from one clever check. The client — browser, mobile app, another
service — is never a trust boundary you control.

## Rules (apply every time)

1. **Authorise every request, server-side, per object.** Check not just
   "is the user logged in" but "may THIS user perform THIS action on THIS
   record". Deny by default.
2. **Validate input at the boundary** with allow-lists and schemas (type,
   length, range, format). Reject, don't "clean".
3. **Never build queries or commands by string concatenation.** Use
   parameterised queries / prepared statements, ORM bindings, and argument
   arrays for process execution.
4. **Encode output for its context** (HTML, attribute, JS, URL, SQL, shell).
   Rely on the framework's auto-escaping; never bypass it with raw-HTML
   helpers on untrusted data.
5. **Don't invent crypto or auth.** Use vetted libraries and the platform's
   standard mechanisms. Hash passwords with Argon2id (or bcrypt/scrypt);
   use TLS everywhere; use authenticated encryption (AES-GCM,
   ChaCha20-Poly1305); generate tokens with a CSPRNG.
6. **Secrets live outside the code** — environment or a secret manager;
   never in source, logs, error messages, URLs or client bundles. Rotate on
   suspicion.
7. **Least privilege everywhere** — DB users, service accounts, API scopes,
   file permissions, network exposure.
8. **Fail closed, fail quietly.** On error, deny access; show users a
   generic message and log the detail server-side (without secrets or
   personal data).
9. **Keep dependencies current and pinned**; scan them; don't add a package
   you haven't checked (name, maintainer, popularity, install scripts).
10. **Log security events** (logins, failures, access denials, privilege
    changes) so attacks can be detected and investigated.

## Workflow for a security-sensitive change

1. **Identify assets and trust boundaries** — what is valuable, where does
   untrusted data enter, who can call this.
2. **Threat model briefly** (STRIDE prompt in the reference) — what could go
   wrong at each boundary.
3. **Implement with secure defaults** following the rules above.
4. **Add negative tests** — unauthenticated, wrong user, wrong role,
   malformed input, oversized input, replay.
5. **Review** against `references/review-checklist.md`.

## Reference files — load on demand

- `references/authn-authz.md` — passwords, MFA, sessions, cookies, JWT,
  OAuth/OIDC, RBAC/ABAC, multi-tenancy. **Load when implementing or
  reviewing login, sessions, tokens or permissions.**
- `references/threat-modeling.md` — STRIDE, data-flow diagrams, risk
  rating, abuse cases. **Load when designing a new feature/system or asked
  to threat model.**
- `references/review-checklist.md` — full security review checklist incl.
  file uploads, HTTP headers, CORS, secrets, crypto, infrastructure.
  **Load before any security review or before shipping security-relevant
  code.**

## Pre-flight (run before delivering security-relevant work)

- [ ] Every new endpoint/action has authentication AND per-object
      authorization enforced server-side.
- [ ] All external input validated; all queries parameterised; output
      encoded.
- [ ] No secrets in code, config committed to the repo, logs or client.
- [ ] Sensitive data encrypted in transit; at rest where required;
      minimised in responses and logs.
- [ ] Errors don't leak stack traces, queries or internals to users.
- [ ] Negative/abuse-case tests exist and pass.
- [ ] New dependencies reviewed and pinned.
- [ ] Findings reported with severity, impact and a concrete fix.
