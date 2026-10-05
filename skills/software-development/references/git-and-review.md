# Git and Code Review

## Commits

- One logical change per commit; the build passes at every commit.
- Message: imperative summary ≤ 72 chars, blank line, body explaining *why*.
  Conventional Commits are a good default when the project has none:
  `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `perf:`, `ci:`.
- Never commit secrets, `.env` files, build output, or large binaries. Check
  `git diff --staged` before every commit.
- Don't rewrite shared history (`push --force` on shared branches) without
  agreement.

## Branching

- Never commit directly to the default branch for non-trivial work; use a
  feature branch (`feat/…`, `fix/…`).
- Keep branches short-lived; rebase or merge from main frequently.
- Delete merged branches.

## Pull requests

A good PR description has:

1. **What** changed (summary).
2. **Why** (link to issue/requirement).
3. **How it was tested** (commands, screenshots for UI).
4. **Risk / rollout notes** (migrations, feature flags, breaking changes).

Keep PRs small (ideally < 400 changed lines). Split refactors from behaviour
changes.

## Reviewing code — checklist

**Correctness**
- Does it do what the PR says? Edge cases, null handling, off-by-one,
  error paths, concurrency/races, time zones.

**Security**
- Input validated; output encoded; queries parameterised.
- Authorization checked on every new endpoint / data access.
- No secrets, no sensitive data in logs.

**Design**
- Fits existing architecture and conventions; no needless abstraction.
- Responsibilities in the right layer.

**Tests**
- New behaviour covered; regression test for bug fixes; tests meaningful.

**Operability**
- Logging/metrics for new failure modes; migrations reversible; config
  documented.

**Readability**
- Clear names, small functions, comments explain *why*.

## Giving feedback

- Prioritise: blocking bugs/security > design > nits. Label nits as nits.
- Be specific and suggest a fix; explain the reasoning.
- Comment on the code, not the person.
