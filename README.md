# Agent-Skills

Portable skills for AI coding agents (Claude Code and any agent that reads
`SKILL.md` files). Clone this repository on any machine, run the installer,
and the agent has the same engineering playbook everywhere.

No personal settings, credentials or project data live here — only reusable
methodology.

## Skills

| Skill | Use it for |
|---|---|
| [`software-development`](skills/software-development/SKILL.md) | Any coding task: implementing, debugging, refactoring, testing, code review, git hygiene |
| [`system-architecture`](skills/system-architecture/SKILL.md) | Designing systems: architecture styles, boundaries, data stores, scaling, reliability, ADRs |
| [`frontend-development`](skills/frontend-development/SKILL.md) | UI work: components, state, forms, UX states, accessibility, performance, SEO |
| [`backend-development`](skills/backend-development/SKILL.md) | Server work: APIs, validation, databases, migrations, auth, multi-tenancy, webhooks, Docker, CI/CD |
| [`secure-coding`](skills/secure-coding/SKILL.md) | Security engineering: threat modelling, authn/authz, crypto, secrets, security review |
| [`owasp-top-10`](skills/owasp-top-10/SKILL.md) | Auditing web apps and APIs against the OWASP Top 10 and API Security Top 10 |

Each skill is a folder:

```
skills/<name>/
├── SKILL.md         always-on rules, workflow and a pre-flight checklist
└── references/      detailed guides the agent loads only when needed
```

## Install on a new PC

Requires [Claude Code](https://claude.com/claude-code) and git.

**Windows (PowerShell)**

```powershell
git clone https://github.com/IV01DI21/Agent-Skills.git
cd Agent-Skills
.\install.ps1
```

**macOS / Linux / Git Bash**

```bash
git clone https://github.com/IV01DI21/Agent-Skills.git
cd Agent-Skills
bash install.sh
```

The installer copies every folder in `skills/` to `~/.claude/skills/`
(user scope — available in every project). Existing skills with the same
name are replaced; nothing else is touched. Restart Claude Code afterwards.

To install for one project only, copy the folders into that project's
`.claude/skills/` instead.

## Update

```bash
git pull
bash install.sh        # or .\install.ps1
```

## How the agent uses them

Skills trigger automatically from their `description` when a task matches —
no command needed. You can also invoke one explicitly, e.g. `/owasp-top-10`
or "use the secure-coding skill to review this endpoint".

## Adding a skill

1. Create `skills/<kebab-case-name>/SKILL.md` with frontmatter:

   ```markdown
   ---
   name: my-skill
   description: What it does and exactly when to use it.
   ---
   ```

2. Keep `SKILL.md` to rules that apply every time; put long material in
   `references/` and state when each file should be loaded.
3. End with a pre-flight checklist so the rules are actually enforced.
4. Never include secrets, credentials, internal hostnames or client data.

## License

MIT — see [LICENSE](LICENSE).
