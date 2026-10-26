---
name: auto
description: Takes a feature from a rough ask to a running build in one invocation. Picks the planning step to start from, writes Intent, Spec and Tasks into docs/plan/<topic>.md, then hands the Tasks to run.sh, which does each one in a session forked from one shared prep. Use for "auto <ask>" or when the user wants plan and build in one go. Not for a single planning step (use interview-me, idea-refine, grill-me or planning-and-task-breakdown) or building without a plan (use incremental-implementation).
---

Plan in this session, build in forks. The plan file `docs/plan/<topic>.md` is the state: read it first if it exists, and reuse its topic slug.

## Pick the start

Start at the first step that isn't settled, and say in one line where you start and why, so the user can push back.

| State                                                                | Start at |
| -------------------------------------------------------------------- | -------- |
| No plan, and the ask is missing who, why, or what success looks like | Intent   |
| Intent clear, more than one reasonable way to do it                  | Shape    |
| Shape clear, decisions still open                                    | Spec     |
| Spec done, no Tasks                                                  | Tasks    |
| Tasks with unchecked boxes                                           | Run      |

Read code only as far as a step needs: grep and excerpts to decide, whole files only to settle a detail. The prep reads the full files later.

## Intent

- State your best read in one sentence with a confidence number.
- Ask one question at a time, each with your guess attached.
- When the answer sounds like best practice rather than a want, ask what they'd want if they didn't have to justify it.
- Restate: outcome, user, success, constraint, out of scope. Go on only after an explicit yes.
- Write `## Intent`.

## Shape

- Skip it when there is one obvious way.
- Give 3-5 options that differ in kind, each with its cost, and recommend one.
- Name the bet behind the pick and what would kill it.
- Write `## Shape`: the direction, MVP scope, a Not doing list.

## Spec

- Walk the open decisions one by one, each with your recommendation, until none is left.
- Look up what the code can answer instead of asking.
- Write `## Spec`: one line per decision, then `### Not deciding`.

## Tasks

Write `## Tasks` in exactly this shape; run.sh parses the checkbox lines and checkpoint headings:

```markdown
## Tasks

### Phase 1: <name>

- [ ] Task 1: <title>
- [ ] Task 2: <title>

### Checkpoint: <name>

- [ ] <what to check before going on>

## Task 1: <title>

**Acceptance criteria:**

- [ ] <testable condition>

**Verification:** `<command that proves it>`

**Files likely touched:**

- `path/to/file`
- `path/to/similar` (read only: the pattern to follow)
```

- Slice vertically: each task delivers a working path and leaves the tree green.
- Small or medium tasks; split one that needs "and" in its title.
- A checkpoint every 2-3 tasks, the riskiest task first.
- List every file a task edits or must read in "Files likely touched". The prep reads only these, so a missing file costs every fork.
- Never overwrite a `## Tasks` section that still has unchecked tasks for other work. Ask.

## Run

Ask: run the current phase unattended, or build here? For unattended, run this from the repo root, report its output, and stop:

```sh
~/.agents/skills/auto/run.sh <topic>
```

It reads the plan and every listed file once in a prep session, then forks it per task, so each task starts from the same cached context. It stops at the next checkpoint. Rerun it after review to start the next phase with a fresh prep. Inside tmux it runs in its own pane and prints `join: opencode -s <id>` per task.

To build here instead, follow "Doing one task" for each task in order.

## Doing one task

A fork of the prep runs this for one task.

- Do only that task. Re-read a file before editing it; what the prep read may be stale.
- Make the smallest change that meets the acceptance criteria. Touch nothing outside its scope.
- Run its verification. Ask no questions: if blocked or failing, leave the box unticked, say why, and stop.
- On a pass, tick it (`- [x] Task N:`), commit only the files this task changed, and stop.
