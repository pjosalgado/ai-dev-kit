#!/bin/bash
# userPromptSubmitted hook: arm the test-gate marker when the skill is invoked,
# disarm it on any other prompt so a stale marker can never trigger agentStop.
# The marker lives on the ai-dev-kit side - target-independent by design.
payload="$(cat 2>/dev/null || true)"
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)" || exit 0
[ -f "$HOOKS_DIR/../config.env" ] && . "$HOOKS_DIR/../config.env"
[ -n "${KIT_RUNTIME:-}" ] || exit 0
mkdir -p "$KIT_RUNTIME" 2>/dev/null || true
marker="$KIT_RUNTIME/pending.marker"
if printf '%s' "$payload" | grep -q 'pjos-test-name-audit'; then
  : > "$marker" 2>/dev/null || true
else
  rm -f "$marker" 2>/dev/null || true
fi
exit 0
