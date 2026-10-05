---
name: system-architecture
description: Designing and evaluating software systems — choosing an architecture style, drawing service and module boundaries, data storage and modelling, API contracts, scalability, reliability, caching, messaging, and documenting decisions. Use whenever the task is "design a system", "how should we structure this", choosing between monolith and microservices, picking a database or queue, planning for scale or high availability, reviewing an architecture, writing an ADR or design doc, or starting a new project from scratch — even if the user only asks "what's the best way to build X".
---

# System Architecture

Open-source skill. Licensed MIT (see repository LICENSE).

## Mental model

Architecture is the set of decisions that are expensive to change. The job is
not to pick the most impressive design but the **simplest one that meets the
actual requirements**, with the trade-offs stated out loud. Every choice
trades something (consistency vs availability, simplicity vs flexibility,
cost vs performance) — name the trade.

## Rules (apply every time)

1. **Requirements before boxes.** Establish functional requirements and the
   quality attributes that matter — expected load (users, requests/sec, data
   size), latency, availability, consistency, security/compliance, team size,
   budget, deadline. If numbers are unknown, state assumptions explicitly.
2. **Start simple; earn complexity.** Default to a well-structured modular
   monolith with one relational database. Introduce microservices, queues,
   caches, sharding or multiple datastores only when a stated requirement
   demands it.
3. **Boundaries follow the domain**, not the technology. Group by business
   capability; each module/service owns its data. No shared-database
   integration between services.
4. **Design for failure.** Every network call can be slow, fail, or succeed
   twice. Use timeouts, bounded retries with backoff and jitter, idempotency
   keys, circuit breakers, and graceful degradation.
5. **Stateless compute, managed state.** Keep application servers stateless
   so they scale horizontally; put state in databases, caches and object
   storage.
6. **Security and observability are architecture**, not add-ons: authn/authz
   model, trust boundaries, encryption, secrets, logging, metrics, tracing
   are in the first draft.
7. **Record the decision.** Every significant choice gets an ADR: context,
   options considered, decision, consequences.

## Workflow

1. **Clarify** requirements and constraints; write down assumptions and
   rough capacity estimates.
2. **Sketch the high-level design** — clients, entry point (load balancer /
   gateway), services/modules, datastores, async paths, external systems.
3. **Model the data** — entities, relationships, access patterns, ownership,
   consistency needs. Pick storage from access patterns.
4. **Define interfaces** — API contracts, events, versioning.
5. **Walk the critical flows** end to end (read path, write path, failure
   path).
6. **Stress the design** — bottlenecks, single points of failure, what
   happens at 10× load, what happens when each dependency is down.
7. **State trade-offs and alternatives**, then document (ADR + diagram).

## Reference files — load on demand

- `references/patterns.md` — architecture styles (layered, hexagonal,
  modular monolith, microservices, event-driven, serverless, CQRS) with
  when-to-use / when-not. **Load when choosing or reviewing a style.**
- `references/data-and-scaling.md` — choosing databases, indexing,
  replication, partitioning, caching strategies, queues, CAP, consistency.
  **Load when choosing storage or planning for scale/availability.**
- `references/design-doc-template.md` — design doc and ADR templates plus a
  review checklist. **Load when writing a design doc/ADR or reviewing an
  architecture.**

## Pre-flight (run before delivering a design)

- [ ] Requirements, assumptions and scale numbers are written down.
- [ ] The design is the simplest that satisfies them; each extra component
      is justified by a specific requirement.
- [ ] Each service/module has a clear responsibility and owns its data.
- [ ] Failure of every dependency has a defined behaviour.
- [ ] Authentication, authorization, data protection and secrets addressed.
- [ ] Observability (logs, metrics, traces, alerts) addressed.
- [ ] Trade-offs and rejected alternatives are stated.
- [ ] Deployment, migration and rollback path is described.
