# Integrations, Configuration and Deployment

## Webhooks (inbound)

Anyone can POST to a webhook URL — never trust the payload.

1. **Verify the signature** from the provider's signature header using the
   webhook secret from environment. This usually needs the **raw request
   body**, not parsed JSON — configure the framework accordingly.
2. On failure return `400`/`401` immediately; don't process, don't log the
   payload.
3. **Idempotency** — providers deliver at least once, so the same event
   can arrive several times:
   - look up the event ID in a `webhook_events` table;
   - if present, return `200` (already handled);
   - otherwise process and record the event ID (unique constraint).
4. **Respond fast** — verify, persist the event (table or queue), return
   `200`; do heavy work (PDFs, emails) in a background worker. Slow
   handlers cause provider retries.

## Calling third-party APIs

- Timeouts on every call; bounded retries with backoff for idempotent
  operations; idempotency keys for payments/creates.
- Validate responses like user input.
- Test-mode keys in development, production keys only in production.
- Wrap each provider behind one module so it can be mocked and swapped.
- Plan for the provider being down: queue, degrade, or fail clearly.

## Environment and configuration

| File | Purpose | Commit? |
|---|---|---|
| `.env.example` | Every required variable with fake/empty values | Yes |
| `.env` / `.env.local` | Local values and real secrets | **No** |
| `.env.test` | Test environment | No |
| `.env.production` | Rare — prefer a secret manager / CI secrets | No |

- Browser-exposed variables need the framework's public prefix
  (`NEXT_PUBLIC_`, `VITE_`); everything else stays server-side. Never give
  a secret a public prefix.
- **Validate at startup and fail fast**:

```ts
// lib/env.ts
import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  NEXT_PUBLIC_APP_URL: z.string().url(),
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  console.error('Invalid environment variables:', parsed.error.format());
  process.exit(1);
}
export const env = parsed.data;
```

  Import config from this module instead of reading `process.env`
  directly.
- CI/CD secrets live in the platform's secret store, referenced by name —
  never hard-coded in workflow files.

## Docker rules

1. **Never publish internal services.** Databases, caches, queues and
   admin panels get **no** host port mapping; the app reaches them over
   the internal container network. Reach admin tools through an SSH
   tunnel.
2. **Reverse proxy in front.** Only the proxy listens on 80/443, handles
   TLS and forwards to the app container.
3. **Host firewall as a second layer**: default deny incoming; allow only
   SSH, 80, 443. (Confirm SSH is allowed before enabling, or you lock
   yourself out. Note that container port publishing can bypass some host
   firewalls — rule 1 is the primary control.)
4. **Named volumes** for databases and uploads. Never run
   `docker compose down -v` in production — `-v` deletes the data.
5. **Secrets at runtime**, not baked in: never `COPY .env` into an image;
   use `env_file`/secret mounts. URL-encode special characters in
   connection-string passwords.
6. **Production mode only** on servers: build, then start the production
   server (`NODE_ENV=production`). Dev mode exposes stack traces and
   wastes resources.
7. **Resilience**: `restart: unless-stopped`; healthchecks; the app
   `depends_on` the database being healthy; Docker enabled on boot.
8. Minimal base images, run as non-root, pin image versions.

### Pre-launch checklist

- [ ] DB/cache have no published ports.
- [ ] Firewall on; only 22, 80, 443 open.
- [ ] Named volumes for all persistent data.
- [ ] Restart policy and healthchecks on every service.
- [ ] App running in production mode behind TLS.
- [ ] Automated database backups configured **and a restore tested**.
- [ ] Monitoring/alerting and error tracking in place.

## CI/CD pipeline

**CI (every push / pull request) — the validation gate**
1. Install strictly from the lockfile (`npm ci` or equivalent).
2. Lint and format check; dependency vulnerability audit.
3. Generate/validate the database schema client.
4. Type check (`tsc --noEmit`).
5. Run tests.

Any failure aborts — broken code is never deployed. Never push to the
main branch without passing tests.

**CD (after CI passes on main)**
1. Connect to the server with a deploy key stored in CI secrets.
2. Pull the release (or pull a pre-built image).
3. Build and restart containers.
4. Apply pending migrations (`migrate deploy`).
5. Health-check; roll back on failure.

## Backups and recovery

- Automated, scheduled dumps stored off the server, encrypted, with
  retention.
- Back up before every production migration.
- Rehearse the restore — an untested backup is not a backup.
- Know your RPO (acceptable data loss) and RTO (acceptable downtime).

## Testing gate

- Unit tests for utilities, calculations, transformations and validation
  schemas (accept good input, reject bad).
- End-to-end tests only for critical user journeys (auth, the core loop,
  key admin flows), against a **dedicated test database**; select by ARIA
  role or `data-testid`, not CSS classes.
- A production bug is fixed by first writing a test that reproduces it.
- Review generated tests for tautologies — a test that can't fail proves
  nothing.
