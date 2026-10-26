# Fork runner for B2

## Shape

### Problem Statement
How might we run B2 one task at a time, each in a fresh session that shares one cached prefix with the others, so that long builds don't fill up the context or re-pay for the same file reads?

### Recommended Direction
`skills/auto/run.sh <topic>` starts a prep session that reads `docs/plan/<topic>.md` and every file listed under the unchecked tasks' "Files likely touched" (already in B1's task template), editing nothing. It then forks the prep once per unchecked task of the current phase (`opencode run --session <prep> --fork --auto`). Each fork follows B2 for one task: re-read before editing, verify, tick, commit, no questions. The runner stops at the first unticked task or the next `### Checkpoint:`. A rerun re-preps from current files, so forks never start from file reads that are a whole phase out of date.

Inside tmux, the runner moves to its own pane of the current window, runs the tasks there one after another, and prints `join: opencode -s <id>` per task. Outside tmux, everything runs inline. The `auto` skill plans into the same file and calls the runner.

### Key Assumptions to Validate
- [x] Forks hit the prep cache. Real run, 2026-10-25, infomaniak/euria-code: the Task 2 fork's first turn read 9,856 tokens from cache with 241 uncached. The first fork cached only 4,480 of ~10k, a one-off partial write per phase.
- [x] B2 doesn't block on questions under `--auto`: real two-task run finished with no prompts
- [ ] The Spec carries the reasoning: note any task that went wrong because of a decision missing from the plan
- [ ] opencode's edit tool rejects stale edits: untested; the fork prompt's re-read rule covers it

### MVP Scope
In: `run.sh`, `test.sh` (fake opencode, inline + private tmux server), now in `skills/auto/`. B1 unchanged.
Out: everything below.

### Not Doing (and Why)
- A separate prep skill: one prompt in the runner is enough
- Saving session IDs: every call re-preps, which also handles stale files
- Claude Code support: opencode only
- A review fork per task: add after the base loop has run on real work
- Parallel worktrees: merge conflicts, and speed isn't the goal
- A handoff-based prep: a summary loses the exact file reads

### Known Limits
- Forks ignore `--title` and show up as `prep: … (fork #1)`
- The runner's `git add -A` commits whatever isn't in `.gitignore`
