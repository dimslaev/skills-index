#!/usr/bin/env bash
# Runs run.sh against a fake opencode in a throwaway repo, inline and inside a private tmux server:
# stop at the checkpoint, stop on a failed task, resume.
set -euo pipefail
run=$(cd "$(dirname "$0")" && pwd)/run.sh
tmp=$(mktemp -d); trap 'tmux -L "t$$" kill-server 2>/dev/null || true; rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

cat > "$tmp/bin/opencode" <<'EOF'
#!/usr/bin/env bash
log=$TMPDIR/calls
case "$1 $2" in
  "session list") awk '{l[NR]=$0} END {for (i=NR; i; i--) print "ses_" i "\t" l[i]}' "$log"; exit ;;
  "session export") echo '{}'; exit ;;
esac
while [ $# -gt 1 ]; do
  case $1 in --title) title=$2; shift ;; --session) session=$2; shift ;; --fork) fork=1 ;; esac; shift
done
[[ $title == prep:* ]] && { echo "$title" >> "$log"; exit 0; }
[[ ${fork:-} && ${session:-} == ses_* ]] || exit 1
# like opencode: a fork is named after its source and ignores --title
echo "$(sed -n "${session#ses_}p" "$log") (fork #1)" >> "$log"
[[ $1 =~ for\ Task\ ([0-9]+) ]] || exit 1
n=${BASH_REMATCH[1]}
[ "$n" = "$(cat "$TMPDIR/fail" 2>/dev/null)" ] && exit 0  # pretend verification failed: no tick
echo "$n" > "out$n"
sed -i.bak "s/^- \[ \] Task $n:/- [x] Task $n:/" docs/plan/demo.md && rm docs/plan/demo.md.bak
git add "out$n" docs/plan/demo.md && git commit -qm "task $n"
EOF
chmod +x "$tmp/bin/opencode"

scenario() {
  local repo=$1
  mkdir -p "$repo/docs/plan" && cd "$repo" && git init -q
  printf '## Tasks\n- [ ] Task 1: one\n- [ ] Task 2: two\n### Checkpoint: A\n- [ ] ok\n- [ ] Task 3: three\n' > docs/plan/demo.md
  git add -A && git commit -qm init
  echo mine > unrelated  # a dirty tree is fine; the forks commit only their own files
  echo 2 > "$TMPDIR/fail"
  "$run" demo && { echo "FAIL: should stop at Task 2"; return 1; } || true
  rm "$TMPDIR/fail"
  git checkout -q .
  "$run" demo | grep -q "checkpoint reached"
  "$run" demo | grep -q "all tasks done"
  [ "$(git log --format=%s | head -3 | tr '\n' '|')" = "task 3|task 2|task 1|" ]
  [ "$(git status --porcelain)" = "?? unrelated" ]
}

export PATH="$tmp/bin:$PATH" TMPDIR="$tmp"
(unset TMUX; scenario "$tmp/inline")
echo "inline ok"

# private tmux server: run.sh splits panes in it, never in the user's sessions
detach() {  # a plain call inside tmux returns at once, the runner finishes in its own pane
  mkdir -p "$1/docs/plan" && cd "$1" && git init -q
  printf -- '- [ ] Task 1: one\n' > docs/plan/demo.md && git add -A && git commit -qm init
  "$run" demo | grep -q "runner started in a new tmux pane"
  for _ in $(seq 50); do git log --format=%s | grep -q "task 1" && return; sleep 0.2; done
  return 1
}
{ declare -p PATH TMPDIR run; declare -f scenario detach
  echo "(export RUN_SH_IN_PANE=1; scenario $tmp/tmux) && detach $tmp/detach > $tmp/tmux.log 2>&1; echo \$? > $tmp/tmux.rc; tmux wait-for -S done"; } > "$tmp/driver.sh"
tmux -L "t$$" new-session -d -x 200 -y 50 "bash $tmp/driver.sh"
tmux -L "t$$" wait-for done
[ "$(cat "$tmp/tmux.rc")" = 0 ] || { cat "$tmp/tmux.log"; exit 1; }
echo "tmux ok"
