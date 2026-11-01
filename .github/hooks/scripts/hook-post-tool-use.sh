#!/bin/bash
# postToolUse hook: fire the changed-test gate when the skill's sentinel command
# appears in a terminal tool payload. Greps the raw payload so it works across
# IDE payload shapes (IntelliJ camelCase, VS Code snake_case).
# Target resolution: .last-target (written by the sentinel) > config fallback.
payload="$(cat 2>/dev/null || true)"
printf '%s' "$payload" | grep -q 'skill-sentinel.sh' || exit 0
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)" || exit 0
[ -f "$HOOKS_DIR/../config.env" ] && . "$HOOKS_DIR/../config.env"
[ -n "${KIT_RUNTIME:-}" ] || exit 0
mkdir -p "$KIT_RUNTIME" 2>/dev/null || true
marker="$KIT_RUNTIME/pending.marker"
[ -f "$marker" ] || exit 0
target=""
[ -f "$LAST_TARGET_FILE" ] && target="$(cat "$LAST_TARGET_FILE" 2>/dev/null || true)"
if [ -z "$target" ] || [ ! -d "$target" ]; then
  target="$TARGET_PROJECT"
fi
if [ -z "$target" ] || [ ! -d "$target" ]; then
  echo "$(date '+%Y-%m-%dT%H:%M:%S%z') postToolUse: no target project resolved" >> "$KIT_RUNTIME/hook.log"
  exit 0
fi
/bin/bash "$HOOKS_DIR/run-changed-tests.sh" sentinel "$target" >> "$KIT_RUNTIME/hook.log" 2>&1 || true
exit 0
