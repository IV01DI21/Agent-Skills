# OWASP Web Top 10 — Category Guide

Contents: A01 Access Control · A02 Misconfiguration · A03 Supply Chain ·
A04 Cryptography · A05 Injection · A06 Insecure Design · A07 Authentication
· A08 Integrity · A09 Logging · A10 Exceptional Conditions

Code samples are illustrative (JavaScript/SQL); the patterns apply to every
stack.

---

## A01 — Broken Access Control

Users act outside their intended permissions.

**Look for**
- Handlers that load a record by ID without checking owner/tenant (IDOR).
- Routes missing the auth/role middleware; admin routes guarded only in UI.
- Authorization decided from client-supplied fields (`role`, `userId`,
  `isAdmin` in body/JWT claims not verified).
- Mass assignment: request body spread directly into a model update.
- CORS reflecting any origin with credentials.
- Path traversal in file access; forced browsing to unlinked URLs.
- **SSRF**: server fetches a user-supplied URL.

```js
// Vulnerable
app.get('/invoices/:id', auth, async (req, res) => {
  res.json(await db.invoice.findById(req.params.id));
});

// Fixed — scoped to the authenticated user
app.get('/invoices/:id', auth, async (req, res) => {
  const inv = await db.invoice.findOne({ id: req.params.id, userId: req.user.id });
  if (!inv) return res.sendStatus(404);
  res.json(inv);
});
```

**Prevent**: deny by default; central authorization layer; scope every
query by owner/tenant; allow-list writable fields; SSRF — allow-list
destinations, block internal ranges, disable redirects; test each endpoint
as anonymous / other user / lower role.

---

## A02 — Security Misconfiguration

**Look for**: debug/dev mode in production; default credentials; verbose
error pages and stack traces; directory listing; unnecessary features,
ports, services, sample apps; missing security headers; permissive CORS;
cloud storage buckets public; admin consoles exposed; XML parsers with
external entities enabled (XXE); cookies without `Secure`/`HttpOnly`/
`SameSite`.

**Prevent**: hardened, repeatable configuration (infrastructure as code);
identical config across environments with different secrets; minimal
platform; security headers set centrally; automated config scanning;
disable XML external entities and DTDs.

---

## A03 — Software Supply Chain Failures

**Look for**: outdated or known-vulnerable dependencies; no lockfile;
unpinned versions or `latest` tags; unmaintained packages; packages with
suspicious names (typosquatting) or install scripts; CI pipelines with
broad secrets, unpinned third-party actions, or builds from untrusted
branches; artefacts not verified.

**Prevent**: inventory dependencies (SBOM); lockfile + pinned versions;
automated vulnerability scanning and update PRs; remove unused deps; vet
new ones; pin CI actions/images by digest; least-privilege CI tokens;
sign and verify artefacts; protected branches and required reviews.

---

## A04 — Cryptographic Failures

**Look for**: sensitive data over HTTP or without TLS internally; passwords
stored plain, encrypted reversibly, or hashed with MD5/SHA-1/SHA-256
unsalted; hard-coded keys; ECB mode; reused/static IV or nonce;
`Math.random()` for tokens; disabled certificate validation; secrets or
personal data in URLs, logs, caches or backups unencrypted.

```js
// Vulnerable
const hash = crypto.createHash('md5').update(password).digest('hex');
const token = Math.random().toString(36);

// Fixed
const hash = await argon2.hash(password);              // Argon2id
const token = crypto.randomBytes(32).toString('hex');   // CSPRNG
```

**Prevent**: classify data; don't store what you don't need; TLS 1.2+ and
HSTS; Argon2id/bcrypt/scrypt for passwords; AES-GCM or ChaCha20-Poly1305
for encryption; keys in a KMS/secret manager with rotation; CSPRNG for all
security tokens.

---

## A05 — Injection

Untrusted data interpreted as code/commands: SQL, NoSQL, OS command, LDAP,
template (SSTI), expression language, and **Cross-Site Scripting (XSS)**.

**Look for**: string concatenation or interpolation into queries; raw
query helpers; user input in `exec`/`system`/`eval`; user-controlled
template strings; operator injection in NoSQL (`{"$ne": null}` passed as a
value); HTML sinks with untrusted data (`innerHTML`,
`dangerouslySetInnerHTML`, `v-html`, `document.write`, `|safe`);
user-controlled `href`/`src` allowing `javascript:` URLs.

```js
// Vulnerable — SQL injection
db.query(`SELECT * FROM users WHERE email = '${email}'`);
// Fixed
db.query('SELECT * FROM users WHERE email = $1', [email]);

// Vulnerable — command injection
exec(`convert ${filename} out.png`);
// Fixed — no shell, argument array
execFile('convert', [filename, 'out.png']);

// Vulnerable — XSS
el.innerHTML = comment;
// Fixed
el.textContent = comment;
```

**Prevent**: parameterised queries / safe ORM APIs; allow-list for dynamic
identifiers (sort/column names); schema validation with strict types; no
shell — pass argument arrays; context-aware output encoding via framework
auto-escaping; sanitise rich HTML with a maintained sanitiser; Content
Security Policy as defence in depth.

---

## A06 — Insecure Design

Flaws in the design itself — no amount of clean code fixes a missing
control.

**Look for**: no rate limits or quotas; business rules enforced only in
the client; multi-step flows that can be skipped or replayed; race
conditions on balances/coupons/inventory; password recovery via "secret
questions"; missing tenant isolation; unlimited resource creation; trust
placed in the client or in an internal network.

**Prevent**: threat model new features; write abuse cases alongside user
stories; enforce limits and invariants server-side with transactions and
constraints; use proven secure design patterns and reference
architectures; segregate tenants and tiers.

---

## A07 — Authentication Failures

**Look for**: no brute-force protection; weak or default passwords
allowed; user enumeration through differing messages/timing; session ID
in URL, not rotated on login, or not invalidated on logout; long-lived
tokens with no revocation; JWT accepting `alg: none` or not validating
`exp`/`aud`/`iss`; missing MFA for privileged accounts; insecure password
reset (guessable or non-expiring tokens).

**Prevent**: vetted auth library/identity provider; MFA; rate limiting and
progressive lockout; breached-password checks; secure session management
(rotate, expire, invalidate; `HttpOnly`/`Secure`/`SameSite` cookies);
uniform responses; single-use short-lived reset tokens.

---

## A08 — Software or Data Integrity Failures

**Look for**: deserialising untrusted data with native serialisers
(pickle, Java serialization, unsafe YAML load, PHP `unserialize`);
auto-update or plugin mechanisms without signature verification; scripts
loaded from third-party CDNs without Subresource Integrity; trusting
unsigned client-side state (cookies, hidden fields, tokens); unverified
webhooks.

**Prevent**: use data-only formats (JSON) with schema validation; sign and
verify anything that crosses a trust boundary (HMAC for webhooks and
client-held state); SRI for external scripts; verified, signed build and
release pipeline.

---

## A09 — Security Logging & Alerting Failures

**Look for**: logins, failed logins, access denials, and high-value
actions not logged; logs only local or easily deleted; no alerting;
secrets, tokens, passwords or personal data written to logs; user input
written unsanitised (log injection); no correlation IDs.

**Prevent**: log security-relevant events with user, action, target,
outcome, time, source; structured, centralised, tamper-resistant logs with
retention; alerts on suspicious patterns; an incident response plan;
never log secrets or sensitive data.

---

## A10 — Mishandling of Exceptional Conditions

Errors and edge conditions handled incorrectly so the system fails open,
leaks, or corrupts state.

**Look for**: `catch` blocks that swallow errors and continue as if
successful — especially around authentication/authorization checks; stack
traces, SQL or file paths returned to users; unhandled promise rejections
or exceptions crashing the process (DoS); missing timeouts; resources not
released on error; partial writes without transactions; unvalidated
assumptions about nulls, missing parameters, integer overflow, or
unexpected types.

```js
// Vulnerable — fails open
let allowed = true;
try { allowed = await policy.check(user, resource); } catch (e) {}
if (allowed) grantAccess();

// Fixed — fails closed
let allowed = false;
try { allowed = await policy.check(user, resource); }
catch (e) { logger.error({ err: e }, 'policy check failed'); }
if (allowed) grantAccess();
```

**Prevent**: fail closed; global error handler returning generic messages;
transactions with rollback; timeouts and resource limits on everything;
validate presence and type of every input; test error paths deliberately.
