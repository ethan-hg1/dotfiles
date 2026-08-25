#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): force a confirmation prompt for any
# push-like command, even in an auto-accept/bypass-permissions session.
# Defense in depth on top of the permissions.ask rules in settings.json,
# which can be routed around by prefix-only matching or bypass modes.
set -euo pipefail

input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$input")"

if [ -z "$command" ]; then
  exit 0
fi

pattern='(^|[;&|]|[[:space:]])git[[:space:]]+push([[:space:]]|$)|(^|[;&|]|[[:space:]])gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)|(^|[;&|]|[[:space:]])gh[[:space:]]+release[[:space:]]+publish([[:space:]]|$)'

if grep -qiE "$pattern" <<<"$command"; then
  jq -n --arg cmd "$command" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("Push-like command detected: \"" + $cmd + "\" — this repo requires explicit confirmation before any push, force-push, PR merge, or release publish, regardless of permission mode.")
    }
  }'
fi
