# Code Quality

## Principles

- **Readability first.** Code is read far more than written. Optimise for the
  next reader.
- **KISS** — the simplest design that meets today's requirements.
- **YAGNI** — don't build for hypothetical futures.
- **DRY, with judgement** — remove duplication of *knowledge*, not of
  coincidentally similar lines. Three similar cases before abstracting.
- **Single responsibility** — a function does one thing; a module has one
  reason to change.
- **Explicit over clever** — no magic, no hidden side effects.

## SOLID (object-oriented code)

| Principle | Meaning | Smell when violated |
|---|---|---|
| Single Responsibility | One reason to change | "Manager"/"Utils" god classes |
| Open/Closed | Extend without modifying | Growing `switch` on type |
| Liskov Substitution | Subtypes honour the base contract | Overrides that throw "not supported" |
| Interface Segregation | Small, focused interfaces | Implementers stubbing unused methods |
| Dependency Inversion | Depend on abstractions | `new` of concrete infra inside business logic |

## Naming

- Names reveal intent: `elapsedMs`, not `t`; `isEligible`, not `flag`.
- Functions are verbs (`calculateTotal`), booleans are predicates
  (`hasAccess`), collections are plural.
- Avoid abbreviations except universally known ones (`id`, `url`, `db`).
- Same concept → same word across the codebase.

## Functions

- Short and at one level of abstraction.
- Few parameters (≤3); group the rest into an object.
- Prefer pure functions; isolate I/O at the edges.
- Guard clauses / early returns over deep nesting.

## Comments

- Explain *why*, not *what*. Good code explains *what*.
- Keep comments true — a stale comment is worse than none.
- Document public APIs, non-obvious constraints, and workarounds (with a link
  to the issue).

## Common smells → refactorings

| Smell | Refactoring |
|---|---|
| Long function | Extract function |
| Long parameter list | Introduce parameter object |
| Duplicated logic | Extract shared function/module |
| Feature envy | Move method to the data's owner |
| Primitive obsession | Introduce value type (Email, Money) |
| Shotgun surgery | Consolidate the concept into one module |
| Deep nesting | Guard clauses, extract function |
| Boolean flag params | Split into two functions |
| Magic numbers/strings | Named constants / enums |

## Error handling

- Fail fast at boundaries with clear messages.
- Use the language's idiom (exceptions, `Result`, error returns) consistently.
- Never `catch` and ignore. Either handle, wrap with context, or re-raise.
- Don't use exceptions for normal control flow.
- User-facing errors are friendly; logs carry the technical detail.

## Performance (only when it matters)

- Measure before optimising; profile, don't guess.
- Watch for N+1 queries, unbounded loops over remote calls, loading whole
  datasets into memory, and quadratic algorithms on growing input.
- Choose the right data structure (set/map lookups vs list scans).
