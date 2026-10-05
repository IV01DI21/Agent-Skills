# Testing

## Test pyramid

- **Unit (most)** — pure logic, fast, no I/O. Milliseconds each.
- **Integration (some)** — real database/queue/filesystem, module boundaries,
  HTTP handlers with a real router.
- **End-to-end (few)** — critical user journeys through the real UI/API.

## What to test

- The happy path, then: empty input, null/undefined, boundaries (0, 1, max),
  invalid types, duplicates, unicode, very large input, concurrency.
- Every bug fix gets a regression test that fails before the fix.
- Authorization: a user must NOT be able to access another user's data.
- Error paths: the right error type/status/message is produced.

## How to write them

- **Arrange / Act / Assert**, one behaviour per test.
- Test names describe behaviour: `returns 404 when order belongs to another
  user`.
- Test public behaviour, not private internals — refactors shouldn't break
  tests.
- Deterministic: control time, randomness, ordering, network.
- Independent: no reliance on test order or shared mutable state.
- Use factories/builders for test data; keep fixtures minimal and local.

## Mocking rules

- Mock at the boundary you don't own (third-party HTTP, payment gateways,
  clocks), not your own code.
- Prefer fakes/in-memory implementations over deep mock chains.
- Don't mock the database in integration tests — use a real one (container
  or test instance) so queries and constraints are actually exercised.
- A test that only verifies mocks were called usually tests nothing.

## Flaky tests

Common causes and fixes:

| Cause | Fix |
|---|---|
| Sleeps / timing | Wait for a condition, not a duration |
| Shared state between tests | Fresh setup per test, isolated DB transaction |
| Real clock / timezone | Inject or freeze the clock; use UTC |
| Order-dependent collections | Sort before asserting |
| External network | Stub at the boundary |

Never "fix" a flaky test by adding retries without understanding the cause.

## Coverage

Coverage shows what is *not* tested; it doesn't prove quality. Aim for high
coverage on business logic and security-relevant code, not on boilerplate.

## TDD loop (when useful)

Red (write a failing test) → Green (minimal code to pass) → Refactor (clean up
with tests green).
