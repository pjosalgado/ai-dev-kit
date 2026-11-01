#!/bin/bash
# agentStop/Stop hook (VS Code): safety net - run the changed-test gate at the
# end of the turn when the skill was invoked (marker armed by userPromptSubmitted)
# but the sentinel never fired. IntelliJ does not support this event today.
# Target resolution: .last-target > config fallback.
cat >/dev/null 2>&1 || true
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)" || exit 0
[ -f "$HOOKS_DIR/../config.env" ] && . "$HOOKS_DIR/../config.env"
[ -n "${KIT_RUNTIME:-}" ] || exit 0
marker="$KIT_RUNTIME/pending.marker"
[ -f "$marker" ] || exit 0
# atomic claim: agentStop and Stop may both be configured for the same event
claim="$KIT_RUNTIME/marker.claim.$$"
if ! mv "$marker" "$claim" 2>/dev/null; then
  exit 0
fi
rm -f "$claim"
target=""
[ -f "$LAST_TARGET_FILE" ] && target="$(cat "$LAST_TARGET_FILE" 2>/dev/null || true)"
if [ -z "$target" ] || [ ! -d "$target" ]; then
  target="$TARGET_PROJECT"
fi
if [ -z "$target" ] || [ ! -d "$target" ]; then
  mkdir -p "$KIT_RUNTIME" 2>/dev/null || true
  echo "$(date '+%Y-%m-%dT%H:%M:%S%z') agentStop: no target project resolved" >> "$KIT_RUNTIME/hook.log"
  exit 0
fi
mkdir -p "$KIT_RUNTIME" 2>/dev/null || true
/bin/bash "$HOOKS_DIR/run-changed-tests.sh" agent-stop "$target" >> "$KIT_RUNTIME/hook.log" 2>&1 || true
exit 0
