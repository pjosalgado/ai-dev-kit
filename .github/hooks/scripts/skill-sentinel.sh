#!/bin/bash
# Finish marker for the pjos-test-name-audit skill. Run the changed-test gate here so
# the sentinel remains reliable even when the postToolUse hook is unavailable.
#
# Usage: skill-sentinel.sh [project-dir]
#   project-dir: the project whose changed tests should run. Resolution order:
#   argument > previously recorded target (.last-target) > config default.
# Records the resolved target for the hook and prints it with the log path.
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)" || HOOKS_DIR=""
if [ -n "$HOOKS_DIR" ] && [ -f "$HOOKS_DIR/../config.env" ]; then
  . "$HOOKS_DIR/../config.env"
fi

target="${1:-}"
if [ -n "$target" ]; then
  if [ -d "$target" ]; then
    target="$(cd "$target" && pwd)"
  else
    target=""
  fi
fi
if [ -z "$target" ] && [ -n "${LAST_TARGET_FILE:-}" ] && [ -f "$LAST_TARGET_FILE" ]; then
  candidate="$(cat "$LAST_TARGET_FILE" 2>/dev/null || true)"
  if [ -d "$candidate" ]; then
    target="$candidate"
  fi
fi
if [ -z "$target" ] && [ -n "${TARGET_PROJECT:-}" ] && [ -d "$TARGET_PROJECT" ]; then
  target="$TARGET_PROJECT"
fi

echo "SKILL_COMPLETE: pjos-test-name-audit finished - test gate armed"
if [ -z "$target" ]; then
  echo "test-gate: no target project - pass one: skill-sentinel.sh <project-dir>"
  exit 0
fi
mkdir -p "${KIT_RUNTIME:-/tmp}" 2>/dev/null || true
printf '%s\n' "$target" > "$LAST_TARGET_FILE" 2>/dev/null || true
echo "test-gate target: $target"
echo "test-gate log: $target/target/copilot-hook/last-test-run.log"
"$HOOKS_DIR/run-changed-tests.sh" sentinel "$target"
