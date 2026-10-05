# Threat Modeling

Four questions: **What are we building? What can go wrong? What are we going
to do about it? Did we do a good job?**

## Steps

1. **Draw a data-flow diagram** — external actors, processes, data stores,
   data flows, and **trust boundaries** (internet ↔ app, app ↔ DB, tenant ↔
   tenant, user ↔ admin, your system ↔ third party).
2. **List assets** — credentials, personal data, money, availability,
   integrity of records, reputation.
3. **Enumerate threats with STRIDE** at each element crossing a boundary.
4. **Rate** each threat (likelihood × impact → Critical/High/Medium/Low).
5. **Decide**: mitigate, eliminate (remove the feature/data), transfer, or
   accept (documented, with an owner).
6. **Verify** mitigations with tests and review; revisit when the design
   changes.

## STRIDE

| Threat | Violates | Ask | Typical mitigations |
|---|---|---|---|
| **S**poofing | Authentication | Can someone pretend to be another user/service? | Strong authn, MFA, mTLS, signed tokens |
| **T**ampering | Integrity | Can data be modified in transit/at rest/in the request? | TLS, signatures, server-side validation, DB constraints |
| **R**epudiation | Non-repudiation | Can someone deny an action? | Audit logs (tamper-evident), timestamps |
| **I**nformation disclosure | Confidentiality | Can data leak (responses, errors, logs, side channels)? | Authorization, encryption, minimisation, generic errors |
| **D**enial of service | Availability | Can someone exhaust resources? | Rate limits, quotas, timeouts, pagination, size limits |
| **E**levation of privilege | Authorization | Can someone gain rights they shouldn't have? | Deny by default, least privilege, input validation, sandboxing |

## Abuse cases

For each user story write the attacker's version:

- "As a user I can view my invoice" → "As an attacker I change the invoice
  ID to view someone else's."
- "As a user I can upload an avatar" → "…I upload a script / 5 GB file /
  path-traversal filename."
- "As a user I can apply a coupon" → "…I apply it 1,000 times concurrently."
- "As a user I can reset my password" → "…I enumerate accounts / brute-force
  the token / hijack via Host header."

## Severity guide

| Severity | Example |
|---|---|
| Critical | Unauthenticated remote code execution, auth bypass, mass data exposure |
| High | Access to other users' data (IDOR), stored XSS on a privileged page, SQL injection behind login |
| Medium | Reflected XSS needing interaction, CSRF on a meaningful action, verbose errors exposing internals |
| Low | Missing hardening header, minor information disclosure |

## Reporting a finding

Title · Severity · Where (file/endpoint) · Description · Impact (what an
attacker gains) · Evidence/steps to confirm · Recommended fix · References
(CWE / OWASP category).
