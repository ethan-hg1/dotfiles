#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): deny any `gh pr create` / `gh pr edit` (or
# `gh api` call against a pulls endpoint) whose title/body still carries the
# "Generated with Claude Code" footer. Defense in depth on top of
# `attribution.pr = ""` in ~/.claude/settings.json and the global
# ~/.claude/CLAUDE.md rule, both provisioned by install.sh.
#
# If the body is passed with --body-file/-F <path>, that file is read and
# scanned too. Limitation: a body piped in via stdin (`--body-file -`) or
# built by command substitution from another file can't be seen here.
set -euo pipefail

input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"

if [ -z "$command" ]; then
  exit 0
fi

# Only PR-writing commands, with `gh` in command position (start of a line or
# after ; & | ( — optionally behind VAR=value prefixes), so prose that merely
# mentions "gh pr create", e.g. in a commit message, doesn't trigger a deny.
pr_pattern='(^|[;&|(])[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*gh[[:space:]]+(pr[[:space:]]+(create|edit)([[:space:]]|$)|api[[:space:]].*pulls)'
if ! grep -qE "$pr_pattern" <<<"$command"; then
  exit 0
fi

footer_pattern='generated with \[?claude code|claude\.com/claude-code'

text="$command"

# Collect --body-file / -F arguments (with or without quotes, `=` or space).
while IFS= read -r path; do
  path="${path%\"}"; path="${path#\"}"
  path="${path%\'}"; path="${path#\'}"
  if [ -z "$path" ] || [ "$path" = "-" ]; then
    continue
  fi
  case "$path" in
    "~/"*) path="$HOME/${path#\~/}" ;;
    /*) ;;
    *) [ -n "$cwd" ] && path="$cwd/$path" ;;
  esac
  if [ -f "$path" ] && [ -r "$path" ]; then
    text+=$'\n'"$(cat -- "$path")"
  fi
done < <(grep -oE '(--body-file|-F)([[:space:]]+|=)("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:];&|]+)' <<<"$command" \
          | sed -E 's/^(--body-file|-F)([[:space:]]+|=)//' || true)

if grep -qiE "$footer_pattern" <<<"$text"; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "This pull request title/body includes the \"Generated with Claude Code\" footer (or a claude.com/claude-code link). PR attribution is disabled for this user. Remove that line and retry."
    }
  }'
fi
