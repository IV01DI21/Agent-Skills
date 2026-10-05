# Architecture Styles and Patterns

## Styles

| Style | Use when | Avoid when |
|---|---|---|
| **Layered (presentation → application → domain → infrastructure)** | Most business apps; small/medium teams | Rarely wrong as a start |
| **Hexagonal / Ports & Adapters / Clean** | Domain logic must be testable and independent of frameworks, DBs, external APIs | Simple CRUD where the ceremony outweighs the benefit |
| **Modular monolith** | Default for new products: one deployable, strict module boundaries | Parts truly need independent scaling/deploys/teams |
| **Microservices** | Many teams needing independent deploys; distinct scaling or reliability needs per capability | Small team, unclear domain boundaries, no platform/DevOps maturity |
| **Event-driven** | Decoupled reactions, integrations, audit trails, async workflows | Simple request/response needs; team unfamiliar with eventual consistency |
| **Serverless (functions)** | Spiky or low traffic, event glue, low ops budget | Long-running, latency-sensitive (cold start), heavy stateful work |
| **CQRS** | Read and write models differ greatly; heavy read scaling | Ordinary CRUD |
| **Event sourcing** | Full audit history is a requirement; temporal queries | Most systems — high complexity |

## Distributed-system patterns

- **API Gateway / BFF** — single entry; auth, rate limiting, routing; a
  backend-for-frontend per client type.
- **Saga** — multi-service transaction as a sequence of local transactions
  with compensating actions (orchestrated or choreographed).
- **Outbox** — write the event to an outbox table in the same DB transaction
  as the state change; a relay publishes it. Solves dual-write.
- **Idempotent consumer** — dedupe by message/idempotency key; at-least-once
  delivery is the norm.
- **Circuit breaker** — stop calling a failing dependency; fail fast; probe
  for recovery.
- **Bulkhead** — isolate resource pools so one failing dependency can't
  exhaust everything.
- **Retry with exponential backoff + jitter** — only for idempotent or
  keyed operations; always bounded.
- **Strangler fig** — migrate a legacy system incrementally by routing
  slices of traffic to the new implementation.
- **Anti-corruption layer** — translate between your domain model and an
  external/legacy model.
- **Sidecar** — cross-cutting concerns (proxy, logging, mTLS) alongside the
  service.

## Domain-driven design essentials

- **Ubiquitous language** — same terms in code and conversation.
- **Bounded context** — a boundary within which a model is consistent;
  natural service/module boundary.
- **Aggregate** — a consistency boundary; one transaction modifies one
  aggregate.
- **Domain events** — facts that happened, named in past tense
  (`OrderPlaced`).

## Communication choices

| Need | Choose |
|---|---|
| Simple request/response, public API | REST over HTTP/JSON |
| Flexible client-driven queries, many clients | GraphQL |
| Low-latency internal service calls, streaming | gRPC |
| Decoupled async work, buffering spikes | Message queue |
| Many consumers, replay, ordering per key | Log/stream (pub-sub) |
| Server → browser live updates | SSE (one-way) or WebSocket (two-way) |

Synchronous chains multiply latency and failure probability — keep them
shallow; move non-critical work to async.
