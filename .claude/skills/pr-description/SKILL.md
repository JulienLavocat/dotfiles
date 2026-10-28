---
description: Write a pull request title and description for the current branch, and open the PR when asked. Use when the user asks to open a PR or for a PR description.
---

## Branch

!`git branch --show-current`

## Base branch

!`git symbolic-ref --quiet --short refs/remotes/origin/HEAD || git rev-parse --verify --quiet --abbrev-ref origin/main || echo origin/master`

## Commits since the base branch

!`B=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || git rev-parse --verify --quiet --abbrev-ref origin/main || echo origin/master); git log --format='### %h %s%n%n%b' "$B..HEAD"`

## Changed files

!`B=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || git rev-parse --verify --quiet --abbrev-ref origin/main || echo origin/master); git diff --stat "$B...HEAD"`

## Instructions

### Gather

- Read every commit message above; they are the main source. Skim the diff only where a commit message is thin or missing.
- Look for docs added or changed on the branch (plans, endpoint lists, READMEs) so the description can link to them instead of repeating them.
- Note migrations, new environment variables, new dependencies and new test commands.
- Ignore untracked and uncommitted files.

### Title

Imperative, sentence case, no prefix, no trailing period, under ~60 characters. Name the feature, not the mechanism: "Add management API with API keys", not "feat: add fastify plugin and keys table".

### Body

Omit needless words. Every line must tell a reviewer something they can't see at a glance in the diff. Use this shape, dropping any section that would be empty:

```markdown
<One or two sentences: what the PR adds and why. Point to docs on the branch for details.>

## <Feature or commit theme>

- <What changed, as behavior. Lead with the fact, then the detail.>
- <Security, limits, defaults and non-obvious decisions get their own bullet.>

## Other changes

- <Incidental fixes and cleanups, one line each.>

## Deployment

- <Migrations by name, env vars production needs, config or infra steps.>

## Testing

- `<command>`: <what it covers>.
```

- One `##` section per coherent theme; usually one per commit when commits are distinct features.
- Put file paths, routes, env vars, scopes and commands in backticks.
- State facts plainly: no "this PR", "we", filler adjectives, emojis or marketing tone.
- Don't list files; the diff does that.
- No attribution lines.

### Be direct

- Lead with the point. No preamble ("This change introduces…", "As part of this work…").
- Cut words that carry no meaning: "also", "just", "basically", "various", "some", "in order to" (→ "to"), "is able to" (→ "can"), "make use of" (→ "use").
- Short, common words; active voice.
- Prefer bullets to prose: they carry facts densely and scan fast. Keep paragraphs for the intro.
- One fact per bullet. Don't restate what the heading or intro already says.
- No hedging, justification or background a reviewer didn't need.
- Before finishing, reread each sentence: if removing it or a word loses nothing, remove it.

### Keep it short

A reviewer should read the whole body in under a minute. Aim for 10–20 lines; go longer only for a PR with several distinct features.

- Describe outcomes and decisions, not implementation. Leave out helper names, what each test asserts, and how code is split into files.
- Collapse related details into one bullet instead of nesting sub-bullets.
- Leave out scaffolding a reviewer will notice anyway, such as example tests or boilerplate config.
- In Testing, give one line per command with its result. Don't list manual checks, mutation checks or tools that passed as usual (`tsc`, ESLint, Prettier).

### Open the PR (only when asked)

1. Check `gh pr list --head <branch>`; if a PR exists, give its link instead of creating another, or update its body with `gh pr edit <number> --body-file <file>` when asked.
2. Push with `git push -u origin <branch>` if the branch has no upstream.
3. Write the body to a file in the scratchpad directory and run `gh pr create --base <base> --title "<title>" --body-file <file>`, where `<base>` is the base branch above without the `origin/` prefix (for example `master`).
4. Reply with the link and a few lines on what the PR contains and anything left out (e.g. untracked files).
