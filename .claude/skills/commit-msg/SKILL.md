---
description: Generate a commit message and description based on the changes made in the codebase, and create the commit when asked. Use when the user asks for a commit message or to commit.
---

## Status

!`git status --short`

## Staged changes

!`git diff --cached`

## Unstaged changes

!`git diff`

## Recent commits

!`git log --oneline -10`

## Instructions

Generate a commit message and short description based on the changes. If anything is staged, describe only the staged changes; otherwise describe everything in the status above, including untracked files (read them, their content is not in the diffs).

The commit message should be concise and follow the conventional commits format. Match the recent commits: same types, scope names and casing. Imperative, no trailing period, under ~72 characters.

The description should provide more context about the changes made. Prefer bullet points to list the changes, and include any relevant information that would help reviewers understand the purpose and impact of the changes. Skip the description for a single trivial change. No attribution lines.

## Committing (only when asked)

1. Stage by explicit path, or everything when the user asked to commit everything. Never force-add ignored files. Ask before staging anything that looks like a secret, build output or a machine-local file.
2. Commit with `git commit -F -` and a heredoc so the body keeps its formatting. Commits may be GPG-signed; that's expected.
3. Never push, amend or skip hooks unless asked.
4. Reply with the new commit's short hash and subject, and anything left uncommitted.
