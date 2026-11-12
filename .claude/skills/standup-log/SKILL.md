---
description: Log work to the user's standup tracker. Use proactively, right after finishing a substantive piece of work in any repo (opened, merged or reviewed a PR, addressed review feedback, fixed or root-caused a bug, deployed or released, finished an investigation, made a decision, wrote a doc). Check before the final reply of any turn that pushed commits, opened or edited a PR, or deployed. Use when the user asks to log something, catch up or sync their standup log, or prepare their standup.
argument-hint: [catch-up [since] | standup | <text to log>]
---

## Request

`$ARGUMENTS`

## Already logged since the last workday

!`did -l 2>&1 || echo "(tracker unreachable)"`

## Tool

`did` posts to the tracker (a SpacetimeDB database on maincloud, page: https://maincloud.spacetimedb.com/v1/database/standup-tracker-03zxw/route).

```sh
did [-p project] [-s source] [-u url] [-x external-id] [-a time] "<text>"
did -l [-j] [-a since]    # entries since the last workday (or since), -j for JSON with ids and timestamps
did -b entries.json       # post a JSON array of entries in one request
```

- `-p`: defaults to the current repo's name (worktrees resolve to the main repo). Pass it explicitly when running outside the repo the work was in.
- `-s`: `claude` for work done in a Claude session, `git` or `github` for catch-up imports. Defaults to `manual`.
- `-x`: re-logging an existing id is a no-op. Always set it for anything that could be logged twice.
- `-a`: when the work happened, if not now, in UTC (`2026-11-10T18:11:00Z`). Times without a zone are read as UTC.

## Writing an entry

One short sentence a teammate would care about in standup:

- About 12 words at most. Start with a past-tense verb: Merged, Opened, Approved, Fixed, Deployed, Wrote.
- Say what changed in plain words. Don't paste the PR title or keep prefixes like "Home:" or "Docs -". Name the concrete change, not "Got X ready" or "Unblocked X".
- No lists, colons, semicolons or parentheses. SHAs, PR numbers and details belong in the `-u` link.
- A PR opened and merged on the same day is "Merged", not "Opened and merged" or "Shipped".
- No trailing period.

| Don't | Do |
|---|---|
| Opened and merged PR: Add shareable promo code links and QR codes | Merged shareable promo code links and QR codes |
| Opened PR: Fix signing in to a second SpacetimeAuth project | Opened a fix for signing in to a second SpacetimeAuth project |
| Merged PR: Fix database names truncated to a few letters on the profile page | Merged the fix for truncated database names on the profile page |
| Requested changes on, then approved PR: Add a /compare overview page | Approved the /compare overview page after changes |
| Approved PR: Home: Update home page to new designs | Approved the home page redesign |
| Deployed web-client and SpacetimeAuth to staging and production (3f16ab2) | Deployed web-client and SpacetimeAuth to production |
| How To Guides PR: moved the guides into How To Guides and wrote matchmaking, turn-based game, … guides | Wrote eight game guides for the docs |
| SpacetimeAuth login page redesign PR: guest sign-in set apart, project background images, provider icon row, … | Redesigned the SpacetimeAuth login page |
| Unblocked the TypeScript SDK React Native reconnect fix PR: added the missing rollback safety section, CI green | Added the missing rollback section to the React Native reconnect fix |
| Addressed review on the billing export metric PR: added a failure counter that catches intermittent export failures | Added a failure counter to the billing export metric |
| Worked on spacetime-web / Edited tooltip.tsx / Ran tests | Nothing: no outcome, don't log it |

Link the PR, issue or doc with `-u` when there is one. Never put secrets, tokens or credentials in the text.

## Mode 1: log as you go (default)

When this skill fires after finishing work in a session:

1. Skip it if the work has no outcome worth mentioning at standup: answering a question, reading code, small edits, failed experiments with no conclusion.
2. Skip it if the list above already covers this work.
3. Run one `did -s claude …` per distinct outcome, usually one. Use ids like `gh:pr:<owner/repo>#<n>:opened` when a PR is involved.
4. Tell the user in one line what was logged. Don't ask first.

## Mode 2: catch up (`catch-up [since]`, "sync my standup log")

All times are UTC. A 30-day range takes about a minute to collect.

1. Collect, then build entries in a scratch directory:
   ```sh
   ~/.claude/skills/standup-log/collect.sh [since] > activity.txt
   ~/.claude/skills/standup-log/entries.py activity.txt entries.json
   ```
   `entries.py` documents its grouping rules and assigns deterministic `externalId`s, so overlapping catch-ups never duplicate entries. Keep its ids and times.
2. Run `did -l -j -a <since>` and drop entries an existing entry describes under a different id (e.g. one logged during a session).
3. `entries.py` texts are drafts. Rewrite every one as under "Writing an entry". If a commit message says nothing useful, ask instead of guessing.
4. Show a short summary (count per project, plus the rewritten entries), then post with `did -b entries.json`.

## Mode 3: prepare standup (`standup`, "prepare my standup")

1. Run mode 2 first so the log is complete.
2. Run `did -l` and write the update:

```markdown
**Yesterday** (or **Friday** on Mondays)
- <project>: <outcome>, <outcome>

**Today**
- <what's in progress or next, inferred from open PRs and today's entries; say if it's a guess>
```

Group by project, merge related entries, and keep it to what can be said in under a minute. Print it in chat; don't log it.
