#!/usr/bin/env bash
# Print my git commits and GitHub PR activity since a date, for standup catch-up.
#   collect.sh [since]   since: anything `date -d` parses (UTC unless it names a zone);
#                        defaults to the start of the last workday
# Repos are found one level under each directory in $STANDUP_ROOTS (default: ~/clockworklabs).
# All times are UTC, ISO 8601.
set -uo pipefail
export TZ=UTC

if [[ -n "${1:-}" ]]; then
  since=$(date -d "$1" +%Y-%m-%dT%H:%M:%SZ)
else
  dow=$(date +%u)
  days=$(( dow == 1 ? 3 : (dow == 7 ? 2 : 1) ))
  since=$(date -d "00:00 $days days ago" +%Y-%m-%dT%H:%M:%SZ)
fi
day=${since%%T*}
echo "# Activity since $since"

echo
echo "## Commits (sha | authored | repo | branches | subject)"
declare -A seen
for root in ${STANDUP_ROOTS:-$HOME/clockworklabs}; do
  for dir in "$root"/*/; do
    common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || continue
    [[ -n "${seen[$common]:-}" ]] && continue
    seen[$common]=1
    repo=$(basename "$(dirname "$common")")
    email=$(git -C "$dir" config user.email) || continue
    # Author dates survive rebases, so a rebased copy matches its original.
    git -C "$dir" log --branches --remotes --no-merges --author="$email" --since="$since" \
      --format="%h | %ad | $repo | %S | %s" --date=format-local:%Y-%m-%dT%H:%M:%SZ 2>/dev/null
  done
done | awk -F' [|] ' '!seen[$2 FS $3 FS $5]++' | sort -t'|' -k3,3 -k2,2

me=$(gh api user -q .login)

echo
echo "## PRs I authored (repo#number | state | branch | opened | merged or closed | title | url)"
gh search prs --author=@me --updated=">=$day" --limit 100 --json repository \
  --jq '.[].repository.nameWithOwner' | sort -u | while read -r repo; do
  gh pr list -R "$repo" --author @me --state all --search "updated:>=$day" --limit 100 </dev/null \
    --json number,state,headRefName,createdAt,mergedAt,closedAt,title,url \
    --jq ".[] | \"$repo#\\(.number) | \\(.state | ascii_downcase) | \\(.headRefName) | \\(.createdAt) | \\(.mergedAt // .closedAt // \"-\") | \\(.title) | \\(.url)\""
done

echo
echo "## PRs I reviewed or commented on (repo#number | state | my activity in range | title | url)"
# Search can't say when I reviewed, so fetch my reviews and comments per PR.
# </dev/null keeps gh from reading the loop's input.
{
  gh search prs --reviewed-by=@me --updated=">=$day" --limit 100 --json repository,number,state,title,url,author \
    --jq ".[] | select(.author.login != \"$me\") | [.repository.nameWithOwner, .number, .state, .title, .url] | @tsv"
  gh search prs --commenter=@me --updated=">=$day" --limit 100 --json repository,number,state,title,url,author \
    --jq ".[] | select(.author.login != \"$me\") | [.repository.nameWithOwner, .number, .state, .title, .url] | @tsv"
} | sort -u | while IFS=$'\t' read -r repo num state title url; do
  activity=$(
    {
      gh api --paginate "repos/$repo/pulls/$num/reviews" </dev/null \
        --jq ".[] | select(.user.login == \"$me\") | [.submitted_at, .state] | @tsv"
      gh api --paginate "repos/$repo/issues/$num/comments" </dev/null \
        --jq ".[] | select(.user.login == \"$me\") | [.created_at, \"COMMENT\"] | @tsv"
    } | sort | awk -F'\t' -v since="$since" '$1 >= since { printf "%s%s %s", (n++ ? ", " : ""), $1, $2 }'
  )
  [[ -n "$activity" ]] && echo "$repo#$num | $state | $activity | $title | $url"
done
