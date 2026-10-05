# Dependency Safety (Supply Chain)

Every package you install runs with your permissions — on your laptop, in
CI, and in production. Since late 2025 the dominant attack on JavaScript
and Python projects has been **malware published as a new version of a
legitimate, popular package** after its maintainer's account or release
pipeline was compromised. Typical behaviour:

- runs automatically at install time through a `preinstall`/`postinstall`
  script;
- steals whatever credentials it can reach — registry tokens, source-host
  tokens, SSH keys, cloud keys, `.env` files, CI secrets, AI-tool
  configuration, crypto wallets;
- uses stolen publishing tokens to release infected versions of the
  victim's own packages (a self-spreading worm);
- sometimes plants persistence (editor tasks, agent hooks, CI workflows)
  or destroys files.

Other routes: typosquatted names (`reqeusts`, `expres`), dependency
confusion (a public package named like your private one), and poisoned CI
caches or actions. Most malicious versions are detected and removed
within hours to a few days — which is why the defences below work.

Examples use npm; the same controls exist for pnpm, yarn, bun, pip/uv,
Composer and others — check the tool's docs for the exact setting.

## Rule 1 — Install only what is required

Before adding a dependency, in this order:

1. **Can the platform do it?** Standard library, runtime APIs (`fetch`,
   `crypto`, `Intl`, `structuredClone`, `URL`), or the framework already
   in the project.
2. **Is it already installed?** Search the manifest and lockfile before
   adding a second library for the same job.
3. **Is it a few lines?** Write the small helper instead of importing a
   package (and its tree) for one function.
4. Only then add a package — and add the **smallest** one, as a
   `devDependency` if it isn't needed at runtime.

Remove dependencies that are no longer imported. Fewer packages means
fewer maintainers who can be compromised.

**For an AI agent:** never install a package the task doesn't need; never
install a package whose name you are not certain exists (a guessed name
may be a squatter's); say which packages you added and why; don't run
`npx <package>` or pipe remote scripts into a shell for unvetted tools.

## Rule 2 — Vet before adding

- [ ] Exact name and publisher/scope match the official docs or repo
      (typosquats differ by one character).
- [ ] Actively maintained; real download numbers; source repository
      linked and matching the published code.
- [ ] The version you are taking is **not brand new** (see cooldown).
- [ ] Any install scripts? Is that expected for this package (native
      build) or suspicious?
- [ ] How many transitive dependencies does it bring?
- [ ] Known vulnerabilities / advisories for it?
- [ ] Licence acceptable.

## Rule 3 — Lock, pin and delay

- **Commit the lockfile.** It records exact versions and integrity
  hashes.
- **CI and production install from the lockfile only** (`npm ci`), never
  a resolving install that can pull a newer version.
- **Don't blindly upgrade.** Update deliberately, read what changed,
  update one group at a time. Avoid `latest`/`*` ranges; consider exact
  versions for critical packages.
- **Cooldown — refuse versions younger than a few days.** Modern package
  managers support a minimum release age; a 3–7 day delay filters out
  nearly all of these attacks. In npm (11.10+) the setting is in days:

  ```ini
  # .npmrc
  min-release-age=7
  ```

  Configure the same delay in your update bot (Dependabot/Renovate
  cooldown), or it will open PRs you can't install. Override only for an
  urgent security fix you have verified.

## Rule 4 — Don't run install scripts by default

Install-time scripts are how this malware executes.

```ini
# .npmrc
ignore-scripts=true
```

Then explicitly allow/rebuild only the few packages that need a build
step (native modules, some ORMs' client generation) — and run the
project's own build/generate commands yourself. Expect to do this
consciously; that is the point.

## Rule 5 — Limit what an install can steal

- No long-lived secrets on the machine or runner that does installs where
  avoidable: short-lived cloud credentials, narrowly scoped tokens, no
  production keys on a developer laptop.
- CI: least-privilege tokens, secrets exposed only to the steps that need
  them, third-party actions pinned to a commit hash, restricted network
  egress where possible, no secrets for untrusted pull requests.
- If you publish packages: 2FA on registry and source-host accounts,
  trusted publishing (OIDC) instead of stored tokens, protected release
  branches.

## Rule 6 — Scan and watch

- Vulnerability audit in CI (`npm audit` or equivalent) and automated
  update PRs.
- Verify registry signatures/provenance where supported
  (`npm audit signatures`).
- Review lockfile diffs in every change: an unexpected new package or a
  version bump you didn't ask for is a red flag.
- Before installing or upgrading during an active incident, check current
  advisories for the packages involved (registry advisories, your
  scanner's feed, reputable security vendors).

## If you may have installed a malicious version

Treat the machine as compromised — removing the package is not enough.

1. Stop: disconnect, don't keep working or pushing from it.
2. Identify what was installed and when (lockfile, install logs,
   published indicators of compromise).
3. **Rotate every credential the machine or runner could read** —
   source-host tokens, registry tokens, SSH keys, cloud keys, database
   passwords, API keys in `.env`, CI secrets. From a clean device.
4. Look for persistence: unfamiliar editor tasks, agent/tool hooks, shell
   profile changes, scheduled jobs, new CI workflows, new repositories or
   deploy keys on your account.
5. Review access logs (source host, cloud, registry) for activity after
   the install time.
6. Rebuild the environment from a clean state and reinstall from a
   known-good lockfile.

## Quick checklist for every dependency change

- [ ] The package is actually needed; no built-in or existing alternative.
- [ ] Name, publisher and repository verified.
- [ ] Version is past the cooldown; lockfile updated and committed.
- [ ] Install scripts stayed disabled (or the exception is deliberate).
- [ ] Lockfile diff reviewed — only expected packages changed.
- [ ] Audit clean, or findings assessed.
- [ ] The summary of the change names every package added or upgraded.
