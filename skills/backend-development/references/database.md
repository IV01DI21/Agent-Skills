# Database Design and Query Conventions

Examples use PostgreSQL with Prisma; the rules apply to any relational
database and ORM. Follow the project's existing conventions where they
differ.

## Naming

| Thing | Convention | Example |
|---|---|---|
| Models | PascalCase, singular | `User`, `Order` |
| Fields | camelCase (map to snake_case columns if the DB requires) | `firstName`, `createdAt` |
| Relations | Named by the related model | `role Role`, `orders Order[]` |
| Enums | PascalCase name, UPPER_SNAKE_CASE values | `OrderStatus { PENDING, IN_PROGRESS }` |

## IDs

| Strategy | Use |
|---|---|
| `cuid()` | Default — URL-safe, collision-resistant |
| `uuid()` | When external systems need UUIDs |
| auto-increment | Internal sequence numbers only (invoice no.) — never exposed as API IDs |

## Base fields (every model unless documented otherwise)

```prisma
model Example {
  id        String    @id @default(cuid())
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime? // soft delete — null means active
}
```

## Soft deletes

Why: recovery of accidental deletes, audit history, no orphaned
references, enables "Undo" in the UI.

```ts
await prisma.order.update({ where: { id }, data: { deletedAt: new Date() } });
const orders = await prisma.order.findMany({ where: { deletedAt: null } });
```

Apply the `deletedAt: null` filter globally (ORM middleware/extension or a
shared query helper) so a forgotten filter can't leak deleted records.
Remember unique constraints: a soft-deleted row still occupies its unique
value.

## Relationships

- **One-to-many** — foreign key on the "many" side.
- **Many-to-many** — always an **explicit join table**, never implicit;
  it lets you add metadata later (role, joinedAt) and a
  `@@unique([aId, bId])` prevents duplicates.
- **Hierarchies** — self-reference with nullable `parentId`.

```prisma
model UserCompany {
  id        String   @id @default(cuid())
  userId    String
  companyId String
  role      String   @default("MEMBER")
  joinedAt  DateTime @default(now())
  user      User     @relation(fields: [userId], references: [id])
  company   Company  @relation(fields: [companyId], references: [id])
  @@unique([userId, companyId])
}
```

## Integrity

Enforce rules in the database, not only in code: `NOT NULL`, `UNIQUE`,
foreign keys, check constraints. Store timestamps in UTC. Store money as
integer minor units or decimal — never floating point.

## Indexing

| Scenario | Index |
|---|---|
| Columns frequently in `WHERE` | Single-column |
| Columns in `ORDER BY` | Single-column |
| Foreign keys | Index them (verify — not every database/ORM creates these automatically) |
| Login email, slug | Unique |
| Combined lookups ("pending orders for company X") | Composite `(companyId, status)` |
| Full-text search | GIN / dedicated search index |

Rules:
1. Don't over-index — every index slows writes. Index what you query.
2. If using soft deletes, make sure common queries filtering on
   `deletedAt` are covered (often as part of a composite or partial
   index).
3. Composite order: equality columns first, then range/sort columns.
4. Always index the tenant key.
5. Find missing indexes with `EXPLAIN ANALYZE` on slow queries.

## Enums

1. Add new values at the end.
2. Never remove a value that existing data uses — deprecate it.
3. Map to display labels in the frontend; never show raw values.

## Audit trail

For business-critical data, record who changed what and when.

```prisma
model AuditLog {
  id        String   @id @default(cuid())
  action    String   // CREATE, UPDATE, DELETE, LOGIN, LOGOUT
  module    String   // orders, users, products
  recordId  String
  userId    String
  changes   Json?    // { field: { old, new } }
  ipAddress String?
  createdAt DateTime @default(now())
  @@index([module, recordId])
  @@index([userId, createdAt])
}
```

Log: logins/logouts, failed logins, create/update/delete, role and
permission changes. Don't log reads (too noisy). Never store secrets or
password values in `changes`.

## Seeding

- Seeds are **idempotent** (`upsert`) — safe to run repeatedly.
- Seed reference data the app needs (roles, permissions, categories).
- Sample/test data only outside production (guard on environment).
- Any seeded admin credential comes from environment/secret input and
  must be changed on first login — never a real password in the seed
  file.

## Migrations

1. Never edit a migration after it has been applied — add a new one.
2. Never run reset/drop commands against production.
3. Development creates migrations (`migrate dev`); production only
   applies them (`migrate deploy`).
4. Test locally, especially column alterations on existing data.
5. Back up the production database before migrating.
6. Descriptive names: `add-user-roles`, `create-audit-log-table`.
7. For zero downtime: expand (add nullable/new) → backfill → switch code
   → contract (remove old).

## Query performance

```ts
// N+1 — one query per order
for (const o of orders) await prisma.client.findUnique({ where: { id: o.clientId } });
// Fixed — one query
const orders = await prisma.order.findMany({ include: { client: true } });

// Fetch only what the UI needs
const users = await prisma.user.findMany({ select: { id: true, name: true, email: true } });

// Always paginate
const [rows, total] = await Promise.all([
  prisma.order.findMany({ where, orderBy: { createdAt: 'desc' }, take: 20, skip: (page - 1) * 20 }),
  prisma.order.count({ where }),
]);
```

Every query that feeds a table or list **must** be paginated. Use
transactions for multi-step writes. Use a single shared database client
instance (singleton) per process to avoid exhausting connections.
