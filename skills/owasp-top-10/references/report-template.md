# Audit Report Template

```markdown
# Security Review — <application / component>

**Date:** YYYY-MM-DD
**Scope:** what was reviewed (repos, paths, endpoints, commit)
**Method:** code review / configuration review / authorised testing
**Not covered:** what was out of scope or could not be verified

## Summary

| Severity | Count |
|---|---|
| Critical | n |
| High | n |
| Medium | n |
| Low | n |

Two or three sentences on overall posture and the most important actions.

## Category coverage

| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | Findings / Clean / N/A / Not verified | … |
| A02 Security Misconfiguration | … | … |
| A03 Software Supply Chain Failures | … | … |
| A04 Cryptographic Failures | … | … |
| A05 Injection | … | … |
| A06 Insecure Design | … | … |
| A07 Authentication Failures | … | … |
| A08 Software or Data Integrity Failures | … | … |
| A09 Security Logging & Alerting Failures | … | … |
| A10 Mishandling of Exceptional Conditions | … | … |

## Findings

### F-01: <short title>
- **Severity:** Critical | High | Medium | Low
- **Category:** e.g. A01 Broken Access Control (CWE-639)
- **Location:** `path/to/file.ext:line`, endpoint
- **Status:** Confirmed | Needs verification
- **Description:** what is wrong.
- **Impact:** what an attacker could achieve.
- **Evidence:** the code path or observation that shows it.
- **Recommendation:** concrete fix (with code where helpful).

## Recommended order of work
1. …
```

## Severity guidance

Rate by **impact × likelihood**, considering whether authentication is
required, how much data/which users are affected, and how easy it is to
find and abuse.

| Severity | Typical examples | Fix timeline |
|---|---|---|
| Critical | Unauthenticated RCE, authentication bypass, SQL injection on a public endpoint, exposed secrets granting production access | Immediately |
| High | IDOR exposing other users' data, stored XSS, privilege escalation, SSRF to internal services | Days |
| Medium | Reflected XSS, CSRF on meaningful actions, missing rate limiting on login, verbose errors | Next release |
| Low | Missing hardening headers, minor information disclosure, outdated dependency with no reachable path | Backlog |

## Writing rules

- One finding per root cause; list all affected locations within it.
- Describe abuse conceptually — enough to understand and verify, not a
  weaponised exploit.
- Always include a fix. Prefer the central/root fix over per-site patches.
- Separate confirmed findings from suspicions.
- Note positive observations too (controls that are done well).
