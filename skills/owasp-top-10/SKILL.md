---
name: owasp-top-10
description: Audits and hardens web applications and APIs against the OWASP Top 10 (web) and the OWASP API Security Top 10 — broken access control, security misconfiguration, supply-chain failures, cryptographic failures, injection (SQLi, XSS, command), insecure design, authentication failures, integrity failures, logging failures, mishandled errors, SSRF, BOLA/IDOR. Use whenever the user mentions OWASP, asks for a vulnerability audit, penetration-test-style code review, "check this for vulnerabilities", compliance with OWASP/ASVS, or wants a finding mapped to an OWASP category — and when reviewing any web endpoint, form, or API handler for security. Pair with secure-coding for the underlying practices.
---

# OWASP Top 10

Open-source skill. Licensed MIT (see repository LICENSE). For defensive use
on systems you own or are authorised to assess.

## Mental model

The OWASP Top 10 is an awareness list of the most common *categories* of
web-application risk — a floor, not a complete standard. Use it as a
structured sweep so nothing obvious is missed, then go deeper where the
application's risk is (OWASP ASVS is the detailed verification standard).

The lists are revised every few years. The categories below follow the
**2025** web edition with the 2021 mapping noted; the content of the
categories changes little between editions. When precision matters (a
compliance report), confirm the current edition at owasp.org.

## Web Top 10 at a glance

| # (2025) | Category | 2021 equivalent | One-line test |
|---|---|---|---|
| A01 | Broken Access Control (incl. SSRF) | A01 + A10 | Can user A read/modify user B's data or reach admin functions? |
| A02 | Security Misconfiguration | A05 | Debug on, defaults left, headers missing, services exposed? |
| A03 | Software Supply Chain Failures | A06 (expanded) | Vulnerable/unvetted dependencies, unpinned builds, weak CI/CD? |
| A04 | Cryptographic Failures | A02 | Sensitive data unencrypted, weak hashing, bad key handling? |
| A05 | Injection (SQL, NoSQL, OS, XSS, template) | A03 | Does untrusted data reach an interpreter unparameterised/unescaped? |
| A06 | Insecure Design | A04 | Missing threat model, no limits, abusable business logic? |
| A07 | Authentication Failures | A07 | Weak passwords, no rate limit/MFA, poor session handling? |
| A08 | Software or Data Integrity Failures | A08 | Unsigned updates, unsafe deserialisation, untrusted CDN scripts? |
| A09 | Security Logging & Alerting Failures | A09 | Would an attack be noticed and investigable? |
| A10 | Mishandling of Exceptional Conditions | new | Do errors fail open, leak details, or leave bad state? |

## Rules (apply every time)

1. **Sweep all ten categories**, not just the ones that come to mind. Mark
   each as: finding(s) / checked-clean / not applicable / could not verify.
2. **Trace data, don't pattern-match.** A finding needs a path from an
   attacker-controlled source to a dangerous sink, or a missing control on
   a reachable endpoint. Read the actual code path, including middleware.
3. **Start with access control** — it is the most prevalent category and
   the least detectable by tools. Enumerate every route and ask who can
   call it and whose data it touches.
4. **Report findings with evidence and a fix**: category, severity,
   location, how it can be abused (conceptually), concrete remediation.
5. **Don't cry wolf.** Verify before reporting; label unconfirmed items as
   "needs verification". False positives erode trust.
6. **Fix at the root** — a central control (parameterised data layer,
   authorization middleware, auto-escaping) over per-call patches.

## Audit workflow

1. **Map the attack surface** — routes/endpoints, auth requirements, roles,
   inputs, file uploads, outbound requests, third-party integrations,
   admin features.
2. **Review configuration** — framework security settings, headers, CORS,
   cookies, secrets handling, dependency manifest and lockfile.
3. **Walk each category** using `references/web-top-10.md` (and
   `references/api-top-10.md` for APIs).
4. **Confirm** each candidate by reading the full code path or with a safe,
   authorised test.
5. **Report** using the format in `references/report-template.md`,
   ordered by severity.
6. **Remediate and add regression tests** for each fixed finding.

## Reference files — load on demand

- `references/web-top-10.md` — per-category description, what to look for
  in code, vulnerable vs fixed patterns, prevention checklist. **Load
  before auditing or fixing a web application.**
- `references/api-top-10.md` — OWASP API Security Top 10 (2023) with
  checks. **Load when the target is a REST/GraphQL/gRPC API or mobile
  backend.**
- `references/report-template.md` — finding and summary report format with
  severity guidance. **Load before writing up results.**

## Pre-flight (run before delivering an audit or fix)

- [ ] All ten categories have an explicit status.
- [ ] Every route was considered for access control, not a sample.
- [ ] Each finding has location, evidence, severity, impact and fix.
- [ ] Unverified items are labelled as such.
- [ ] Fixes are at the root cause and have regression tests.
- [ ] Scope and limits of the review are stated (what was not examined).
