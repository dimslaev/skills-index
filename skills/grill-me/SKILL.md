---
name: grill-me
description: Grill the user relentlessly about a plan, decision or idea until there is a shared understanding, then write it as the Spec. Use when the user wants to stress-test their thinking or says "grill me". Not for finding the intent (use interview-me), or choosing between shapes (use idea-refine).
---

Interview the user relentlessly until you reach a shared understanding. If `docs/plan/<topic>.md` exists, its Intent and Shape are settled: grill the edge cases and details, never re-ask them. Map it as a design tree: every decision branches into the decisions that hang off it.

The frontier is every decision whose prerequisites are settled. Ask one frontier question per message, with your recommended answer, worded so "yes" accepts it:

```
Q: <question, with choices if there are any>
Recommended: <your answer>
```

Wait for the answer, recompute the frontier, ask the next one.

Finding facts is your job. If a question needs a fact from the code or environment, look it up, using a subagent if it's slow, and ask other frontier questions meanwhile. Decisions are the user's.

Stop when the frontier is empty: every branch visited, nothing silently assumed. Don't act until the user confirms the shared understanding.

When the user confirms, write the `## Spec` section of `docs/plan/<topic>.md` (create the file if needed; reuse the slug if it exists): the resolved decisions grouped by branch, one line each, then a `### Not deciding` list for what was deliberately left open. Don't restate Intent or Shape.
