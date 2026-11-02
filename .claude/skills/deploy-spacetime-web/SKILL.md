---
description: Deploy spacetime-web apps (the spacetimedb.com website, SpacetimeAuth, StackBench) by opening a PR in clockworklabs/kubernetes that bumps their images to a given commit, and report env var, secret and migration changes. Use when the user asks to deploy or release spacetimedb.com, the website, web-client, SpacetimeAuth or StackBench.
argument-hint: <website|spacetimeauth|stackbench>... <prod|staging|all> <commit-sha>
---

## Request

`$ARGUMENTS`

## Apps

All three live in `clockworklabs/spacetime-web`. Charts are under `applications/clusters/pnap-k8s/remote-clusters/<cluster>/charts/<chart>/` in `clockworklabs/kubernetes`, where `<cluster>` is `spacetimedb-prod` or `spacetimedb-stg`.

| App | Source dir | Chart | Image | Docker job | Sealed secret | Migration command |
|---|---|---|---|---|---|---|
| Website (spacetimedb.com) | `spacetimedb.com/` | `web-client` | `ghcr.io/clockworklabs/spacetimedb-web` | `spacetimedb.com` | `web-client-env` | `drizzle-kit migrate` in `spacetimedb.com`, never `push` |
| SpacetimeAuth | `spacetime-auth/` | `spacetimeauth` | `ghcr.io/clockworklabs/spacetimeauth` | `SpacetimeAuth` | `spacetimeauth-env` | `drizzle-kit migrate` in `spacetime-auth`, never `push` |
| StackBench | `stackbench.org/` | `stackbench` | `ghcr.io/clockworklabs/stackbench-web` | `stackbench.org` | `stackbench-env` | `node --import tsx scripts/migrate.ts` with the new image |

PR labels: `web-client`, `SpacetimeAuth`, `StackBench`. Never edit charts under `applications/clusters/spacetimedb-prod/...`: that is the legacy cluster.

## Instructions

### 1. Gate

Do this before anything else. All three inputs must come from what the user typed in their current request, never from `git log`, the deployed tag, earlier conversation, or arguments the user didn't type. If any check fails, stop, say what's missing, and do nothing else: no clone, no branch, no edit, no guess.

- **Apps:** one or more of the three above, named explicitly. "Deploy" or "deploy everything" without names is not enough. Several apps share one PR and one version.
- **Environment:** `prod`, `staging` or `all`, named explicitly. There is no default: a hostname like "spacetimedb.com" doesn't count as choosing prod.
- **Version:** a `clockworklabs/spacetime-web` commit matching `^[0-9a-f]{7,40}$`. `latest`, `main`, `HEAD`, branches, tags and "the last one" are refused.
- Resolve it with `gh api repos/clockworklabs/spacetime-web/commits/<version> --jq .sha`. If it doesn't resolve, or the result doesn't start with the input, stop.
- The image tag is `commit-<first 7 chars>`. Call those 7 chars `<new>`.
- Check each image was pushed. Find the run with `gh run list --repo clockworklabs/spacetime-web --workflow docker.yml --commit <full sha> --json databaseId,status`, then `gh run view <id> --repo clockworklabs/spacetime-web --json jobs --jq '.jobs[] | "\(.name)\t\(.conclusion)"'`. Jobs run independently, so check the job of each requested app. If one didn't succeed, stop and report it.

### 2. Environment

| Requested | Cluster | `<env>` |
|---|---|---|
| `prod` | `spacetimedb-prod` | `prod` |
| `staging` | `spacetimedb-stg` | `stg` |

`all` means both, as two separate PRs. A PR never touches more than one cluster. Run steps 3 to 5 once per environment, staging first, after step 1 passes.

### 3. Prepare clones

Work in the scratchpad directory; never touch the user's own checkouts.

```sh
gh repo clone clockworklabs/kubernetes <scratch>/kubernetes -- --depth 1
gh repo clone clockworklabs/spacetime-web <scratch>/spacetime-web -- --filter=blob:none
```

For each app:

- Read the deployed tag from the `image:` line of its `values.yaml` in this environment's cluster. Call its 7 chars `<old>`; it differs per app.
- If `<old>` equals `<new>`, drop that app and say it's already deployed. If none remain, skip this environment's PR.
- If `<new>` isn't a descendant of `<old>` (`git merge-base --is-ancestor <old> <new>` fails), warn that this is a rollback or a side branch and list the commits it drops.

### 4. Detect changes in `<old>...<new>`

Per app, scoped to its source dir, against this environment's `deployment.yaml` and sealed secret. Report only, except for removing unused env vars (below): don't add or change env vars or secrets, and never run a migration.

**Migrations**
- New files in `<source dir>/migrations/*.sql`, listed by name with the PR that added them (`git log --format='%h %s' <old>..<new> -- <file>`).
- Migrations are never applied on start; they run by hand with the app's migration command. Each one is a Deployment step, "before merging" unless the migration or its PR says otherwise. Read it for destructive changes (drops, renames, `NOT NULL` without default) and say so.
- New files in `<source dir>/scripts/` that look like backfills or one-off jobs: read their PR and add a step if it asks for one.

**Env vars**
- Added or removed `process.env.X` reads in `git diff <old> <new> -- <source dir> ':!**/e2e/**' ':!**/tests/**' ':!**/*.test.*' ':!**/*.spec.*'`; test-only vars never reach production. SpacetimeAuth reads most of them in `src/configuration.ts`.
- Website only: added or removed names in `.env.template` and `.env.production`. `%%X%%` placeholders in `.env.production` are filled at startup from env var `X`, so a new one needs `X` in `deployment.yaml`. `import.meta.env.VITE_*` without a placeholder is baked in at build time: mention it, no deployment change.
- StackBench: also check `stackbench.org/DEPLOYMENT.md` and `scripts/setup-auth.mjs` for new settings.
- Check each new runtime var against the `env:` list in the chart's `templates/deployment.yaml`, and say whether it's already set, optional (has a default in code), or missing.
- A changed default for a var not set in `deployment.yaml` changes production behavior: list it under behavior changes.

**Secrets**
- A new var holding a credential (key, token, secret, password, webhook URL) needs a `secretKeyRef` to the app's sealed secret and a new key in `templates/<sealed secret>.sealedsecret.yaml`. This skill can't seal it: report it as a step that blocks the merge.

**Unused env vars (removed in the PR)**

A var in the chart's `deployment.yaml` `env:` list is unused when `git grep -w <NAME> <ref> -- <source dir> ':!**/e2e/**' ':!**/tests/**' ':!**/*.test.*' ':!**/*.spec.*'` finds nothing at both `<old>` and `<new>`. The search covers code, `Dockerfile`, `server.js`, nginx config and `.env.production` placeholders. Dynamic reads like `process.env[name]` still spell the name out somewhere, so they're caught.

- Unused at `<new>` but still read at `<old>`: keep it. Pods still on `<old>` during the rollout, or after a rollback, need it. The next deploy removes it. List it as "removed next deploy".
- Keep, and only report, any var that might be read without its name in the source:
  - read by Node, a library or the platform (`NODE_ENV`, `NODE_OPTIONS`, `PORT`, `TZ`, `DEBUG`, `OTEL_*`, `SENTRY_*`, `DATABASE_URL`)
  - matching a name built from parts, like `` `STRIPE_PRICE_ID_${n}` ``
  - passed to a child process through `{ ...process.env }`
- For each var removed, find the commit that dropped its last use: `git log -S <NAME> --format='%h %s' -1 <old> -- <source dir>`. Cite it in the PR.
- Delete its whole entry from `deployment.yaml`, `valueFrom` block included.
- If it was a `secretKeyRef`, also delete that key from `encryptedData` in `templates/<sealed secret>.sealedsecret.yaml`. Each key is sealed independently, so no resealing is needed. Only delete the key if no other entry in the cluster's charts still uses it (`grep -rn <key> <cluster>/charts`).
- Removals touch this environment's cluster only.

If an app has nothing in a category, say so in one line, e.g. "No SpacetimeAuth migration, env var or secret change."

### 5. Open the PR

`<labels>` joins the requested apps' labels with "and" in table order, e.g. `web-client and SpacetimeAuth`.

1. In the kubernetes clone, `git switch -c julien/deploy-<env>-<app slugs>-<new>`, e.g. `julien/deploy-prod-web-client-spacetimeauth-761bbd2`.
2. In each app's `values.yaml` in this environment's cluster, replace `commit-<old>` with `commit-<new>`. Commit with the message `Deploy <env> <labels> to <new>`.
3. If step 4 found unused env vars, remove them in a second commit, `Remove unused <env> <labels> env vars`, so the bump can be reverted on its own. Change nothing else, and never touch the other cluster. Push with `git push -u origin <branch>`.
4. Write the body to a scratchpad file and run `gh pr create --repo clockworklabs/kubernetes --base main --title "Deploy <env> <labels> to <new>" --body-file <file>`.
5. Never merge, approve or enable auto-merge.
6. For `all`, start the next environment from a fresh branch off `main`, not from this one.

Body, dropping empty sections. Apps sharing an `<old>` share a compare line (`web-client and SpacetimeAuth: …`).

```markdown
Deploys spacetime-web `main` at https://github.com/clockworklabs/spacetime-web/commit/<new>.

- <label>: [`<old>...<new>`](https://github.com/clockworklabs/spacetime-web/compare/<old>...<new>)

## Deployment

1. <Before merging: migrations by name and app, new secrets to seal, env vars to add to `deployment.yaml`, with PR links.>
2. <After the deploy: backfill scripts, admin actions.>

<Name each app with nothing to do: No spacetimedb.com migration or new env var.>

## Removed env vars

- `<NAME>` (<label>, <sealed secret key if any>): unused since <commit or PR link>.
- <Kept for now: vars unused only at `<new>`, or possibly read indirectly, with why.>

## <Label> behavior changes

- <User-visible or breaking changes worth a heads-up, with PR links. Skip routine features and fixes.>
```

Follow the writing rules in `pr-description`: facts only, one per bullet, no filler.

### 6. Report

Reply with each PR link, then per environment and app the findings from step 4 under **Migrations**, **Env vars**, **Secrets** and **Removed env vars**, each with what must happen and when (before merge or after deploy). Lead with anything that blocks the merge.
