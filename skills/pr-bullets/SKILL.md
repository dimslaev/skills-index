---
name: pr-bullets
description: Writes a PR description as short bullets over the changes against the parent branch. Use for "pr bullets" or a bullet-only PR body. Not for a PR body with summary, evidence and merge danger (use pr).
---

Write a PR description as a flat bullet list of the changes against the parent branch.

## Find the base

Git doesn't record a branch's parent. Take the first that works:

1. Open PR: `gh pr view --json baseRefName -q .baseRefName`.
2. Nearest branch: for each other local and remote branch, count `git rev-list --count $(git merge-base <branch> HEAD)..HEAD`. Take the lowest.
3. Remote default: `git symbolic-ref --short refs/remotes/origin/HEAD`.

## Write

Read `git diff <base>...HEAD` and `git log <base>..HEAD`.

```
Base: <base>

- <change>
- <change>
```

- One bullet per logical change, not per file or commit.
- Imperative verb first: "Add rate limit to login route".
- 5-10 words. Simple and technical.
- Use the real file, symbol, or flag name.
- No headings, title, or summary. Only the base line and the bullets.
