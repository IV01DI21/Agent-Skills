---
name: software-development
description: Core engineering discipline for writing, changing, debugging, testing and reviewing code in any language. Use for ANY coding task — implementing a feature, fixing a bug, refactoring, writing tests, reviewing a diff, setting up a project, or explaining code — even when the user only says "fix this" or "add X". Load alongside the more specific skills (frontend-development, backend-development, system-architecture, secure-coding, owasp-top-10) when the task touches those areas.
---

# Software Development

Open-source skill. Licensed MIT (see repository LICENSE).

## Mental model

The codebase is the spec. Before writing anything, learn how the project
already does it — naming, structure, error handling, test style, libraries —
and write code that reads like the surrounding code. A correct change that
looks foreign is a maintenance cost; a change that matches is invisible.

Work in small, verifiable steps: understand → plan → change → verify →
report. Never claim something works without having run something that
proves it.

## Rules (apply every time)

1. **Read before you write.** Open the files you will change and their
   immediate callers. Find an existing example of the pattern you need and
   copy its shape. Do not introduce a new library, framework or pattern when
   the project already has one for the job.
2. **Smallest change that solves the real problem.** Fix the root cause, not
   the symptom. No drive-by refactors, renames or reformatting in the same
   change unless asked — they bury the real diff.
3. **Match the code around you**: naming, comment density, file layout,
   error-handling idiom, import style, formatting.
4. **Handle failure paths explicitly.** Validate inputs at boundaries, never
   swallow exceptions silently, return/raise errors with enough context to
   debug, and clean up resources (files, connections, locks).
5. **Tests are part of the change.** Add or update a test that fails without
   the fix and passes with it. Prefer testing behaviour over implementation
   details. Run the existing suite, type checker and linter before declaring
   done.
6. **No secrets in code.** Credentials, tokens and keys come from environment
   or a secret store; never commit them, never log them.
7. **Report honestly.** If tests fail, show the output. If you skipped a step,
   say so. If you are unsure, say what would confirm it.

## Workflow

1. **Understand** — restate the goal; identify inputs, outputs, constraints,
   edge cases. Ask only when a decision is genuinely the user's.
2. **Explore** — locate the relevant code (search by symbol, route, error
   text). Note conventions and existing helpers to reuse.
3. **Plan** — for anything beyond a one-file change, list the files and the
   order of edits. Identify what could break.
4. **Implement** — incremental edits; keep the build green between steps.
5. **Verify** — run tests, type check, lint; exercise the change for real
   (run the app, call the endpoint, open the page).
6. **Report** — what changed, why, how it was verified, anything left open.

## Debugging

Reproduce first, then form ONE hypothesis at a time and test it with the
cheapest experiment (a log line, a failing test, a bisect). Read the actual
error and stack trace fully before guessing. If two hypotheses fail, step
back and gather more evidence instead of guessing a third. Once fixed, add a
regression test.

## Reference files — load on demand

- `references/code-quality.md` — clean-code principles, naming, SOLID,
  common smells and refactorings. **Load when refactoring or reviewing.**
- `references/testing.md` — test pyramid, what to test, mocking rules,
  flaky-test fixes. **Load before writing or fixing tests.**
- `references/git-and-review.md` — commit hygiene, branching, PR and
  code-review checklist. **Load before committing, opening a PR, or
  reviewing someone's diff.**

## Pre-flight (run before saying "done")

- [ ] I read the code I changed and matched its conventions.
- [ ] The change is minimal and addresses the root cause.
- [ ] Error paths and edge cases (empty, null, large, concurrent) handled.
- [ ] A test covers the change; full suite, types and lint pass — or I
      reported exactly what fails.
- [ ] No secrets, debug prints, commented-out code or stray files left.
- [ ] My summary states how the change was verified.
