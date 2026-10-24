# Skills coherence

## Intent

Confirmed 2026-10-24.

- **Outcome:** the skills read as one framework. Each skill sits in its stage, knows the skill before and after it, and points only to skills that exist.
- **How:** edit only the seams: descriptions, handoffs, dead references, overlap boundaries. Each author's method and voice stays. Attribution stays through a source line and `LICENSES/`.
- **PLAN funnel:** interview-me (broad intent) → idea-refine (pick a shape) → grill-me (edge cases and details, no repeated questions, ends by writing a short spec file) → BUILD.
- **Overlaps:** keep both skills in each pair, draw a sharp line between them, and point each to the other. `documentation-and-adrs` owns ADRs.
- **Removals:** `skill-update` with `sources.md`, `tdd`, `codebase-design`, `teach`, `domain-modeling`, and every reference to them. Update `index.txt`.
- **Out of scope:** restyling into one voice, new skills, changes to `references/` beyond fixing broken links.

## Shape

### Problem Statement
How might we make 17 skills from four authors feel like one framework, editing only where they connect?

### Recommended Direction
Descriptions carry the framework: each gets a stage tag, keeps its author's trigger phrases, and adds "Not for: … (use X)" pointing to its neighbour. This is where the agent chooses, so it's where incoherence costs the most.

The PLAN funnel shares one growing file, `docs/plan/<topic>.md`: interview-me writes Intent, idea-refine writes Shape, grill-me writes Spec. Each step runs without the earlier ones. planning-and-task-breakdown reads the Spec section and writes a Tasks section; incremental-implementation works through the Tasks.

Every dead link gets fixed on the way: deleted, or pointed to an installed skill or reference.

### Key Assumptions to Validate
- [ ] Descriptions stay distinct after the formula: read all 17 side by side
- [ ] The plan file helps more than it gets in the way: use it on the next real task

### MVP Scope
In: 17 descriptions, plan-file lines in the 3 PLAN skills + 2 BUILD skills (planning, incremental), all dead links, `index.txt`, README, removal of the 5 dropped skills.
Out: anything else in skill bodies.

### Not Doing (and Why)
- Standard header block: one more layer; descriptions already carry stage and neighbours
- Unified question format: touches each author's core method
- `FRAMEWORK.md`: a second source of truth next to descriptions and the index
- Restyling voice: out of scope by intent

### Open Questions
- None blocking. grill-me works out the details.

## Stages

Decisions per index stage, made after Shape. They override Intent and Shape where they differ.

### PLAN
- P1 interview-me → P2 idea-refine → P3 grill-me (writes Spec). P4 `to-spec` and P5 `wait-what` slots removed.
- Triggers: "grill me" and "stress-test" belong to grill-me only; remove them from interview-me and idea-refine descriptions.

### BUILD
- B1 `planning-and-task-breakdown` (restored): reads Spec, writes a Tasks section into the plan file.
- B2 `incremental-implementation`: works through Tasks. "Picking up the next task from a plan" now means the Tasks section.
- `tdd` dropped. Remove incremental's `test-driven-development` link (don't repoint); keep its own "write a test if none exists".
- Remove incremental's `git-workflow-and-versioning` link.

### CLEAN
- Unchanged for now: no reorder, no boundary edits, unslop stays. The user cleans manually.

### REVIEW
- R1 code-review-and-quality → R2 security-and-hardening → R3 receiving-code-review.
- code-review: repoint `performance-optimization` to `../../references/performance-checklist.md`.
- security: remove the `observability-and-instrumentation` and `debugging-and-error-recovery` mentions.
- `hardening-patterns.md` exists (`skills/security-and-hardening/references/`); its links are fine.
- code-review's "Change Descriptions" stays: it judges descriptions, pr writes them.

### WRITE
- W1 documentation-and-adrs, W2 pr, W3 pr-bullets, W4 technical-writing. `domain-modeling` removed (swapped back after implementation).
- No dead links in WRITE.
- `documentation-and-adrs` is the only ADR owner.
- technical-writing description drops "PR descriptions"; pr owns the PR body, technical-writing keeps docs and commit messages.
- handoff names `docs/plan/<topic>.md` among the artifacts to reference.
- pr: two versions. `pr` (Matt, untouched) and `pr-bullets` (local, new): bullets over the changes against `main`, 5-10 words each, simple and technical, no other sections.
- Two separate skills: `pr` and `pr-bullets`.

### Other
- `wait-what`, `handoff`: in a MISC section of the index (M1 handoff, M2 wait-what).
- `references/`: keep the unlinked checklists (accessibility, observability, orchestration, testing-patterns).

## Spec

### Attribution
- Each skill's source (repo and upstream path, or `local`) is listed in a table in the README, not in frontmatter. `pr` keeps its `credits` block.

### Descriptions
- No stage tag in descriptions; the stage lives only in `index.txt`.
- Indexed skills outside CLEAN keep the author's trigger phrases and add `Not for … (use X)` (no colon, so descriptions need no quotes). CLEAN, wait-what, handoff descriptions unchanged.
- technical-writing description unchanged (keeps "PR descriptions").

### Plan file
- `docs/plan/<topic>.md`, sections in order: Intent, Shape, Spec, Tasks. The step that creates the file sets the slug; later steps reuse it.
- interview-me writes Intent, idea-refine writes Shape; both ask before saving (replaces `docs/intent/`, `docs/ideas/`).
- grill-me writes Spec right after the user confirms the shared understanding, no second ask. Spec = decisions grouped by design-tree branch, one line each, plus a "Not deciding" list. No restating Intent or Shape.
- planning-and-task-breakdown reads Spec and writes a `## Tasks` checklist in the plan file instead of `tasks/plan.md` / `tasks/todo.md`. Never-overwrite rule applies to unchecked Tasks; external tracker option stays; `/build` mention removed.
- incremental-implementation ticks the task (`- [x]`) in the plan file at each commit.
- handoff names `docs/plan/<topic>.md` as an artifact to reference.

### pr-bullets (local)
- Base: open PR's base (`gh pr view --json baseRefName`) → nearest branch by fewest commits to `HEAD` → remote default (`git symbolic-ref refs/remotes/origin/HEAD`). State the base in one line.
- Read `git diff <base>...HEAD` and the log. Output a flat bullet list: one logical change per bullet, imperative, 5-10 words, real file/symbol names. No headings, title, or summary.

### Dead links
- interview-me, idea-refine: `spec-driven-development` → grill-me / the Spec section; `planning-and-task-breakdown` stays valid.
- incremental-implementation: remove `test-driven-development` and `git-workflow-and-versioning` links.
- code-review-and-quality: `performance-optimization` → `../../references/performance-checklist.md`.
- security-and-hardening: remove `observability-and-instrumentation` and `debugging-and-error-recovery` mentions.

### Housekeeping
- Delete `skill-update`, `tdd`, `codebase-design`, `teach`, `domain-modeling`, and their links in `~/.claude/skills/`. Link `pr-bullets` there.
- README: drop skill-update / `sources.md` lines, explain `source: local`, keep the Sources table, add dead-link cleanup `find -L ~/.claude/skills -maxdepth 1 -type l -delete`.
- `index.txt`: same layout and author column; PLAN P1-P3, BUILD B1-B2, CLEAN C1-C4 unchanged, REVIEW R1-R3 reordered, WRITE W1-W4; pr-bullets author `local`.
- No branch, no commit. Working tree only.

### Not deciding
- CLEAN boundaries (manual for now).
- Unlinked `references/` checklists (kept).
