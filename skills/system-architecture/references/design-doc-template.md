# Design Doc and ADR Templates

## Design doc

```markdown
# <System / Feature name>

## 1. Context and problem
What exists today, what problem we are solving, for whom.

## 2. Goals / Non-goals
- Goals: …
- Non-goals: …

## 3. Requirements
- Functional: …
- Quality attributes: load, latency, availability, consistency, security,
  compliance, cost.
- Assumptions and capacity estimates: …

## 4. Proposed design
- High-level diagram (clients, services, datastores, async paths, externals)
- Components and responsibilities
- Data model and ownership
- APIs / events (contracts, versioning)
- Key flows (read, write, failure)

## 5. Cross-cutting concerns
- Security: authn, authz, trust boundaries, data protection, secrets
- Observability: logs, metrics, traces, alerts
- Reliability: failure modes, timeouts/retries, backups, DR
- Performance and scaling plan

## 6. Alternatives considered
Option, pros, cons, why rejected.

## 7. Rollout
Migration steps, feature flags, backward compatibility, rollback.

## 8. Risks and open questions
```

## ADR (Architecture Decision Record)

```markdown
# ADR-NNN: <Decision title>

- Status: proposed | accepted | superseded by ADR-XXX
- Date: YYYY-MM-DD

## Context
The forces at play: requirements, constraints, what makes this hard.

## Options
1. Option A — pros / cons
2. Option B — pros / cons

## Decision
We will … because …

## Consequences
What becomes easier, what becomes harder, what we must now do.
```

Store ADRs in the repo (e.g. `docs/adr/`), numbered, never edited after
acceptance — supersede instead.

## Diagrams

Use the C4 levels: **Context** (system and its users/externals) →
**Containers** (apps, databases, queues) → **Components** (inside one
container). Text-based diagrams (Mermaid) keep diagrams reviewable in the
repo.

## Architecture review checklist

- [ ] Requirements and scale assumptions explicit?
- [ ] Simplest design that meets them? Each component justified?
- [ ] Clear ownership of each piece of data? No shared DB across services?
- [ ] Single points of failure identified and addressed?
- [ ] Behaviour defined when each dependency is slow/down?
- [ ] Idempotency for retried operations and message consumers?
- [ ] Trust boundaries drawn; authn/authz at each; secrets managed?
- [ ] Sensitive data classified, encrypted in transit and at rest?
- [ ] Observability and alerting planned?
- [ ] Zero-downtime deploy, migration and rollback path?
- [ ] Cost estimated and acceptable?
- [ ] Trade-offs and alternatives documented?
