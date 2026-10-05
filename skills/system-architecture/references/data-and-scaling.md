# Data, Scaling and Reliability

## Choosing a datastore (from access patterns)

| Need | Choose |
|---|---|
| Transactions, relations, ad-hoc queries — the default | Relational (PostgreSQL, MySQL) |
| Flexible/nested documents, per-document access | Document store |
| Simple key lookups at huge scale, sessions, cache | Key-value store |
| Full-text search, faceting | Search engine (as a secondary index, not source of truth) |
| Time-ordered metrics/events | Time-series store |
| Highly connected data, traversals | Graph database |
| Files, images, backups | Object storage (+ CDN) |
| Analytics over large history | Columnar warehouse |

One relational database handles far more than people expect. Add another
store only for an access pattern the first can't serve.

## Relational modelling

- Normalise first (3NF); denormalise deliberately for measured read needs.
- Every table has a primary key; enforce integrity with foreign keys,
  `NOT NULL`, `UNIQUE`, `CHECK`.
- Index for your queries: columns in `WHERE`, `JOIN`, `ORDER BY`; composite
  index order = equality columns, then range/sort. Too many indexes slow
  writes.
- Use transactions for multi-statement invariants; know your isolation
  level.
- Migrations are versioned, reviewed, and backward compatible (expand →
  migrate → contract) so deploys need no downtime.
- Store timestamps in UTC; money as integer minor units or decimal, never
  float.

## Scaling ladder (take the cheapest step that works)

1. Measure; find the actual bottleneck.
2. Optimise queries and add indexes.
3. Scale up (bigger machine).
4. Cache hot reads.
5. Scale app tier horizontally behind a load balancer (stateless).
6. Read replicas for read-heavy load (mind replication lag).
7. Move slow work to background jobs/queues.
8. Partition/shard data (by tenant, key hash or range) — last resort; it
   complicates everything.

## Caching

- **Cache-aside** (most common): read cache → miss → read DB → populate.
- **Write-through / write-behind**: update cache on write.
- Always set a TTL; define invalidation on write.
- Guard against **stampede** (locking / request coalescing / jittered TTL)
  and **penetration** (cache negative results).
- Layers: browser → CDN → reverse proxy → application cache → DB.
- Never cache per-user data under a shared key.

## Consistency and CAP

- Under a network partition you choose consistency (reject/timeout) or
  availability (serve possibly stale data). Decide per operation: payments
  and inventory want consistency; feeds and counters tolerate staleness.
- Eventual consistency needs UI and logic that tolerate delay
  (read-your-writes, idempotency, reconciliation).

## Messaging

- Assume **at-least-once** delivery → consumers must be idempotent.
- Use a dead-letter queue and alert on it.
- Ordering is usually only guaranteed per partition/key — design for it.
- Apply backpressure; bound queue sizes.

## Reliability

- Define SLOs (e.g. 99.9% availability, p95 < 300 ms) and an error budget.
- Remove single points of failure: multiple instances across zones, DB
  failover, health checks.
- Timeouts on every external call; retries bounded with backoff + jitter.
- Rate limit and load-shed to protect the system under overload.
- Backups are automated AND restore is tested; define RPO/RTO.
- Deploy safely: rolling/blue-green/canary, feature flags, quick rollback.

## Observability

- **Logs** — structured (JSON), with request/correlation IDs, no secrets or
  personal data.
- **Metrics** — RED (Rate, Errors, Duration) for services; USE
  (Utilisation, Saturation, Errors) for resources.
- **Traces** — distributed tracing across service hops.
- **Alerts** — on user-facing symptoms (SLO burn), actionable, with a
  runbook.

## Back-of-envelope numbers

- 1 day ≈ 86,400 s (~10^5). 1 M requests/day ≈ 12 req/s average; plan for
  peak ≈ 5–10× average.
- Storage = items/day × size × retention × replication factor.
- A single modern DB node comfortably serves thousands of simple queries/sec.
