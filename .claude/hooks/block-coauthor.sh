#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): deny any git commit whose message still
# carries a Co-Authored-By trailer crediting Claude/Anthropic. Defense in
# depth on top of the global ~/.claude/CLAUDE.md instruction not to add one
# (provisioned into every codespace by install.sh) — this catches it even if
# that instruction gets missed, forgotten mid-session, or overridden.
#
# GitHub resolves noreply@anthropic.com to a real account (github.com/claude)
# and credits it as a contributor on the repo's Contributors page, which is
# not desired.
set -euo pipefail

input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$input")"

if [ -z "$command" ]; then
  exit 0
fi

if grep -qiE 'co-authored-by:.*(claude|anthropic\.com)' <<<"$command"; then
  jq -n --arg cmd "$command" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "This commit message includes a Co-Authored-By trailer crediting Claude/Anthropic. GitHub resolves that email to a real account and lists it as a contributor on this repo, which is not wanted. Retry the commit without that trailer line."
    }
  }'
fi
