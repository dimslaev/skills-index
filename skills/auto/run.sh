#!/usr/bin/env bash
# Runs the unchecked tasks of the current phase of docs/plan/<topic>.md, each in an opencode
# session forked from one prep session, so every task reuses the prep's prompt cache.
# Stops at the next checkpoint or the first failed task; rerun to continue with a fresh prep.
# Inside tmux it moves itself to a new pane of this window and returns at once.
set -euo pipefail

topic=${1:?usage: run.sh <topic>}
plan=docs/plan/$topic.md
out=${TMPDIR:-/tmp}/opencode-runs
mkdir -p "$out"
[ -f "$plan" ] || { echo "no $plan" >&2; exit 1; }

# unchecked tasks from the first one up to the next checkpoint
tasks=$(awk '/^- \[ \] Task [0-9]+:/ {s=1; sub(/^- \[ \] Task /, ""); sub(/:.*/, ""); print; next}
             s && /^#+ Checkpoint/ {exit}' "$plan")
[ -n "$tasks" ] || { echo "no unchecked tasks in $plan"; exit 0; }

# Called from inside tmux (a terminal or an agent's shell): move to a pane and return at once,
# so an agent's shell call doesn't block for the whole phase.
if [ -n "${TMUX:-}" ] && [ -z "${RUN_SH_IN_PANE:-}" ]; then
  f=$out/pane-$$.sh
  # tmux starts panes through the login shell, whose rc files may rewrite PATH
  printf 'export PATH=%q RUN_SH_IN_PANE=1\n%s; read -r -p "enter closes this pane"\n' \
    "$PATH" "$(printf '%q ' "$0" "$1")" > "$f"
  tmux split-window -d -t "${TMUX_PANE:-}" -c "$PWD" "bash $(printf %q "$f")"
  echo "runner started in a new tmux pane: $plan"
  exit 0
fi

# newest session whose title starts with $1; session list is newest first
newest() { opencode session list | awk -F'\t' -v t="$1" 'index($2, t) == 1 {print $1; exit}'; }

prep_title="prep: $topic $(date +%s)"
status=$(git status --porcelain)
opencode run --auto --title "$prep_title" "Read $plan, then every file listed under the unchecked tasks' 'Files likely touched'. Do not edit anything. Reply only: loaded."
prep=$(newest "$prep_title")
[ -n "$prep" ] || { echo "prep session not found" >&2; exit 1; }
[ "$(git status --porcelain)" = "$status" ] || { echo "prep edited files, stopping" >&2; exit 1; }
opencode session export "$prep" > "$out/$topic-$prep.json"
echo "prep: opencode -s $prep  (export: $out/$topic-$prep.json)"

for n in $tasks; do
  title=$(grep -m1 -E "^- \[ \] Task $n:" "$plan" | sed -E 's/^- \[ \] Task [0-9]+: *//')
  echo "== Task $n: $title"
  before=$(newest "$prep_title (fork") head=$(git rev-parse HEAD)
  opencode run --auto --session "$prep" --fork "Follow the 'Doing one task' section of the auto skill for Task $n of $plan, and only that task. Implement it yourself; never call run.sh. Re-read a file before editing it; what you read earlier may be stale. Ask no questions. If you are blocked or verification fails, leave its box unticked, say why, and stop. If it passes, tick it (- [x] Task $n:), commit only the files this task changed, then stop." &
  # forks ignore --title and are named after the prep, so the new fork is the newest one not seen before
  fork=$before
  while [ "$fork" = "$before" ] && kill -0 $! 2>/dev/null; do sleep 0.2; fork=$(newest "$prep_title (fork"); done
  [ "$fork" = "$before" ] || echo "join: opencode -s $fork"
  wait $! || { echo "Task $n: opencode failed" >&2; exit 1; }
  grep -qE "^- \[x\] Task $n:" "$plan" || { echo "Task $n not ticked, stopping" >&2; exit 1; }
  [ "$(git rev-parse HEAD)" != "$head" ] || echo "warning: Task $n made no commit" >&2
done

if grep -qE '^- \[ \] Task [0-9]+:' "$plan"; then
  echo "checkpoint reached: review, then rerun run.sh $topic"
else
  echo "all tasks done: $plan"
fi
