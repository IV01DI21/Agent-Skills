# Authentication, RBAC and Multi-Tenancy

Examples use Next.js (Auth.js) + Prisma; the patterns are stack-agnostic.
Use a maintained auth library or identity provider — never hand-roll.

## Request flow

```
Credentials / OAuth  →  auth library validates
                     →  session token in an HttpOnly, Secure, SameSite cookie
                     →  middleware checks every request (deny by default, allow-list public routes)
                     →  handler/action re-checks session, role and ownership
```

Decisions that travel well: password hashing with Argon2id or bcrypt
(cost ≥ 12); session token in an `HttpOnly` secure cookie (not
`localStorage`); routes protected by default with an explicit public
allow-list.

## Flows

**Login** — validate input → look up user → verify hash → create session.
On failure always respond **"Invalid email or password"** — never reveal
which part was wrong (prevents account enumeration). Rate limit.

**Registration** — validate (format, password strength) → check
uniqueness → hash password → create user with the default (least
privileged) role.

**Password reset** — generate a cryptographically random token → store
its hash with a 1-hour expiry → email a link → verify token → set new
password → invalidate the token (single use) and existing sessions.
Always answer "If an account exists, a reset link has been sent."

**OAuth** — client ID/secret from environment; decide deliberately how to
handle a user who registered with a password and later signs in with
OAuth on the same email (account linking only with a verified email).

## RBAC data model

```prisma
model User {
  id       String  @id @default(cuid())
  email    String  @unique
  password String
  roleId   String
  role     Role    @relation(fields: [roleId], references: [id])
  isActive Boolean @default(true)
}

model Role {
  id          String       @id @default(cuid())
  name        String       @unique
  permissions Permission[]
  users       User[]
}

model Permission {
  id     String @id @default(cuid())
  action String // CREATE, READ, UPDATE, DELETE
  module String // orders, users, products, reports
  roleId String
  role   Role   @relation(fields: [roleId], references: [id])
  @@unique([action, module, roleId])
}
```

Baseline roles (customise per project): `SUPER_ADMIN` (everything),
`ADMIN` (everything in their organisation), `MANAGER` (operations, no user
management), `STAFF` (assigned work), `CLIENT` (own data only).

## Authorize inside every handler

Middleware alone is not enough — handlers and server actions can be
invoked directly.

```ts
// lib/authorize.ts
export async function authorize(allowedRoles: string[]) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');
  if (!allowedRoles.includes(session.user.role)) throw new Error('Forbidden');
  return session.user;
}

// an action
export async function deleteOrder(orderId: string) {
  const user = await authorize(['SUPER_ADMIN', 'ADMIN']);
  const order = await prisma.order.findFirst({
    where: { id: orderId, companyId: user.activeCompanyId, deletedAt: null },
  });
  if (!order) throw new Error('Order not found');
  await prisma.order.update({ where: { id: order.id }, data: { deletedAt: new Date() } });
  return { success: true };
}
```

Three checks, always: **session → role/permission → ownership/tenant**.
Role changes should take effect promptly — if the role is cached in a
token, keep token lifetime short or re-check on sensitive actions.

## Multi-tenancy (single database, shared schema)

All tenants share tables; every tenant-owned row carries the tenant key.

**Golden rule:** every tenant-owned table has a `companyId` (tenant ID)
foreign key, and it is indexed.

```ts
// Vulnerable — trusts the client
export async function getOrders(companyIdFromClient: string) {
  return prisma.order.findMany({ where: { companyId: companyIdFromClient } });
}

// Correct — tenant comes from the session
export async function getOrders() {
  const session = await auth();
  if (!session?.activeCompanyId) throw new Error('No active company');
  return prisma.order.findMany({ where: { companyId: session.activeCompanyId } });
}
```

- A cross-tenant leak is the most severe flaw a SaaS can have. Enforce the
  filter centrally (query helper / ORM extension / database row-level
  security) rather than remembering it per query.
- **Users in several tenants**: a join table (`UserCompany`) holds the
  per-tenant role; the session holds the active tenant; switching tenant
  must verify membership server-side before updating the session.
- **System roles vs tenant roles**: a super admin is a property of the
  user and works across tenants via a separate admin area; tenant roles
  live on the membership — the same person can be `ADMIN` in one tenant
  and `STAFF` in another.
- Scope uniqueness per tenant (`@@unique([companyId, sku])`), and scope
  caches, file storage paths and background jobs by tenant too.
- Test it: with two tenants, every endpoint must refuse the other
  tenant's IDs.

## Checklist

- [ ] Session token in `HttpOnly`, `Secure`, `SameSite` cookie; expiry set.
- [ ] Sensitive actions (password/email change) require re-authentication.
- [ ] Passwords hashed (Argon2id / bcrypt ≥ 12); minimum length enforced.
- [ ] Generic login errors; rate limiting on auth routes.
- [ ] Routes protected by default; public routes allow-listed.
- [ ] Handlers verify session AND role AND ownership/tenant.
- [ ] Admin and permission changes written to the audit log.
