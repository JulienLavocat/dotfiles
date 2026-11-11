#!/usr/bin/env python3
"""Turn collect.sh output into tracker entries, one per unit of work.

    entries.py <collect-output.txt> <entries.json>

- PRs I authored: an entry when opened and when merged (one entry if both on the same day).
  Closed-unmerged PRs are skipped. Staging and prod deploys of one sha on one day are one entry.
- PRs I reviewed: one entry per PR, at my deciding review (approval or change request).
- Commits: one entry per branch per day, unless a PR event on that branch already covers the day.
  Commits authored before the range are rebased copies of older work and are skipped.

externalIds are deterministic, so re-running over overlapping ranges never duplicates entries.
Prints a summary; review it and rewrite long texts before posting.
"""
import json, re, sys, collections
from datetime import datetime, timezone
lines = open(sys.argv[1]).read().splitlines()
since = lines[0].split()[-1]
sec = None; commits = []; authored = []; reviewed = []
for l in lines[1:]:
    if l.startswith('## Commits'): sec = 'c'; continue
    if l.startswith('## PRs I authored'): sec = 'a'; continue
    if l.startswith('## PRs I reviewed'): sec = 'r'; continue
    if not l.strip() or l.startswith('#'): continue
    p = [x.strip() for x in l.split(' | ')]
    if sec == 'c': commits.append(dict(sha=p[0], at=p[1], repo=p[2], branch=p[3], subj=' | '.join(p[4:])))
    elif sec == 'a': authored.append(dict(ref=p[0], state=p[1], branch=p[2], opened=p[3], closed=p[4], title=' | '.join(p[5:-1]), url=p[-1]))
    elif sec == 'r': reviewed.append(dict(ref=p[0], state=p[1], activity=p[2], title=' | '.join(p[3:-1]), url=p[-1]))

local_repo = lambda ref: ref.split('/')[1].split('#')[0].lower()   # clockworklabs/spacetime-web#1 -> spacetime-web
entries = []
def add(text, project, source, at, xid, url=None):
    entries.append(dict(text=text, project=project, source=source, atMs=None, at=at, externalId=xid, **({'url': url} if url else {})))

day = lambda ts: ts[:10]
covered = set()          # (repo, branch, day) already described by a PR event
pr_by_branch = {}
deploys = collections.defaultdict(list)
for pr in authored:
    repo = local_repo(pr['ref']); pr_by_branch[(repo, pr['branch'])] = pr
    merged = pr['state'] == 'merged' and pr['closed'] >= since
    opened = pr['opened'] >= since
    if pr['state'] == 'closed':
        covered.add((repo, pr['branch'], day(pr['opened']))); continue
    if pr['title'].startswith('Deploy ') and merged:
        m = re.match(r'Deploy (stg|prod) (.+) to (\w+)', pr['title'])
        deploys[(day(pr['closed']), m.group(2), m.group(3))].append((m.group(1), pr))
        covered.add((repo, pr['branch'], day(pr['opened']))); continue
    pid = f"gh:pr:{pr['ref']}"
    if opened and merged and day(pr['opened']) == day(pr['closed']):
        add(f"Opened and merged PR: {pr['title']}", repo, 'github', pr['closed'], pid + ':merged', pr['url'])
    else:
        if opened: add(f"Opened PR: {pr['title']}", repo, 'github', pr['opened'], pid + ':opened', pr['url'])
        if merged: add(f"Merged PR: {pr['title']}", repo, 'github', pr['closed'], pid + ':merged', pr['url'])
    if opened: covered.add((repo, pr['branch'], day(pr['opened'])))
    if merged: covered.add((repo, pr['branch'], day(pr['closed'])))

for (d, what, sha), items in sorted(deploys.items()):
    envs = sorted({e for e, _ in items}, key=lambda e: e != 'stg')
    names = {'stg': 'staging', 'prod': 'production'}
    main = next((pr for e, pr in items if e == 'prod'), items[0][1])
    add(f"Deployed {what} to {' and '.join(names[e] for e in envs)} ({sha})", 'kubernetes', 'github',
        max(pr['closed'] for _, pr in items), f"gh:pr:{main['ref']}:merged", main['url'])

for r in reviewed:
    events = [a.rsplit(' ', 1) for a in r['activity'].split(', ')]
    states = [s for _, s in events]
    decisive = [e for e in events if e[1] in ('APPROVED', 'CHANGES_REQUESTED')]
    at = (decisive or events)[-1][0]
    if 'CHANGES_REQUESTED' in states and states[-1] != 'CHANGES_REQUESTED' and 'APPROVED' in states: verb = 'Requested changes on, then approved'
    elif decisive and decisive[-1][1] == 'APPROVED': verb = 'Approved'
    elif decisive: verb = 'Requested changes on'
    else: verb = 'Reviewed'
    add(f"{verb} PR: {r['title']}", local_repo(r['ref']), 'github', at, f"gh:pr:{r['ref']}:reviewed", r['url'])

groups = collections.OrderedDict()
for c in commits:
    if c['at'] < since: continue                       # rebased copy of older work
    branch = re.sub(r'^origin/', '', c['branch'])
    if branch.startswith('backup/') or branch == 'refs/stash': continue
    key = (c['repo'], branch, day(c['at']))
    if key in covered: continue
    groups.setdefault(key, []).append(c)
for (repo, branch, d), cs in groups.items():
    pr = pr_by_branch.get((repo, branch))
    if pr and pr['state'] == 'closed': continue
    subjects = '; '.join(c['subj'] for c in cs)
    text = f"Worked on PR {pr['title']}: {subjects}" if pr else subjects
    add(text, repo, 'git', cs[-1]['at'], f"git:{repo}:{branch}:{d}", pr['url'] if pr else None)

for e in entries:
    e['atMs'] = int(datetime.strptime(e.pop('at'), '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc).timestamp() * 1000)
entries.sort(key=lambda e: e['atMs'])
json.dump(entries, open(sys.argv[2], 'w'), indent=1)
for e in entries:
    at = datetime.fromtimestamp(e['atMs'] / 1000, timezone.utc).strftime('%Y-%m-%dT%H:%MZ')
    print(f"{at} {e['source']:6} [{e['project']}] {e['text']}  ({e['externalId']})")
