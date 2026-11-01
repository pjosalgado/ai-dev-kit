#!/bin/bash
# Test gate: run only the tests affected by uncommitted changes in the target project.
# Usage: run-changed-tests.sh [reason] [target-project-dir]
#   target-project-dir: absolute path (or relative to cwd). Falls back to the
#   sentinel's recorded target, then to TARGET_PROJECT from config.env.
# Writes <target>/target/copilot-hook/last-test-run.log with a RESULT: line.
set -uo pipefail

reason="${1:-manual}"
target="${2:-}"

HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)" || exit 1
[ -f "$HOOKS_DIR/../config.env" ] && . "$HOOKS_DIR/../config.env"
if [ -z "${KIT_RUNTIME:-}" ]; then
  echo "test-gate: config.env not found next to scripts" >&2
  exit 1
fi
if [ -z "$target" ] && [ -f "${LAST_TARGET_FILE:-}" ]; then
  target="$(cat "$LAST_TARGET_FILE" 2>/dev/null || true)"
fi
if [ -z "$target" ]; then
  target="${TARGET_PROJECT:-}"
fi
if [ -z "$target" ] || [ ! -d "$target" ]; then
  echo "test-gate: target project not found: ${target:-<unset>}" >&2
  exit 1
fi
target="$(cd "$target" && pwd)"
cd "$target" || exit 1
git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "test-gate: $target is not a git repository" >&2; exit 1; }

log="$target/target/copilot-hook/last-test-run.log"
marker="$KIT_RUNTIME/pending.marker"
lock="$KIT_RUNTIME/.run.lock"
mkdir -p "$target/target/copilot-hook" "$KIT_RUNTIME" 2>/dev/null || true

# Disarm the marker so the agentStop safety net does not run again this turn.
rm -f "$marker"

# One run at a time; reclaim a stale lock whose process is gone.
if ! mkdir "$lock" 2>/dev/null; then
  lock_pid="$(cat "$lock/pid" 2>/dev/null || true)"
  if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
    echo "test-gate: another run is already in progress (pid $lock_pid) - skipping"
    exit 0
  fi
  rm -rf "$lock"
  mkdir "$lock" 2>/dev/null || exit 0
fi
echo $$ > "$lock/pid" 2>/dev/null || true
trap 'rm -rf "$lock"' EXIT

# The hook environment has a minimal PATH; add common tool locations.
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.sdkman/candidates/java/current/bin:$PATH"

changed="$(
  {
    git diff --name-only HEAD -- 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
)"

specs=""
add_spec() {
  case ",$specs" in
    *",$1,"*) return 0 ;;
  esac
  specs="${specs}${specs:+,}$1"
}

while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    src/test/*Spec.groovy|src/test/*Test.groovy|src/test/*Spec.java|src/test/*Test.java)
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      add_spec "${base%.*}"
      ;;
    src/main/*.java|src/main/*.groovy)
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      base="${base%.*}"
      for cand in "${base}Spec" "${base}Test"; do
        match="$(find src/test -type f \( -name "${cand}.groovy" -o -name "${cand}.java" \) -print -quit 2>/dev/null)"
        if [ -n "$match" ]; then
          add_spec "$cand"
          break
        fi
      done
      ;;
  esac
done <<EOF
$changed
EOF

{
  echo "=== test-gate: reason=$reason, target=$target, $(date '+%Y-%m-%dT%H:%M:%S%z') ==="
  echo "--- changed files ---"
  printf '%s\n' "$changed"
} > "$log"

if [ -z "$specs" ]; then
  {
    echo "--- selection: none ---"
    echo "RESULT: SKIP (no changed tests)"
  } >> "$log"
  exit 0
fi

{
  echo "--- selection: $specs ---"
  echo "--- mvn test ---"
} >> "$log"

mvnw="./mvnw"
[ -x "$mvnw" ] || mvnw="mvn"
"$mvnw" test -Dtest="$specs" -DfailIfNoTests=false -Dsurefire.failIfNoSpecifiedTests=false 2>&1 | tee -a "$log"
rc=${PIPESTATUS[0]}

if [ "$rc" -eq 0 ]; then
  echo "RESULT: PASS" >> "$log"
else
  echo "RESULT: FAIL (exit $rc)" >> "$log"
fi
exit "$rc"
