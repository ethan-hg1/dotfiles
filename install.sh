#!/usr/bin/env bash
set -euo pipefail

echo "[dotfiles] Starting install..."

# Install Claude Code
if ! command -v claude &>/dev/null; then
  echo "[dotfiles] Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code || echo "[dotfiles] Warning: Claude Code install failed. Run 'npm install -g @anthropic-ai/claude-code' manually."
else
  echo "[dotfiles] Claude Code already installed: $(which claude)"
fi

# Skip first-run onboarding wizard (~/.claude.json is Claude Code's internal state file)
if [ ! -f ~/.claude.json ]; then
  echo "[dotfiles] Writing Claude Code state file to skip onboarding..."
  cat > ~/.claude.json << 'EOF'
{
  "hasCompletedOnboarding": true
}
EOF
fi

# Write default Claude Code settings (theme, etc.)
# "attribution" with empty strings disables Claude Code's built-in attribution:
# "pr" hides the "Generated with Claude Code" footer on pull request bodies,
# "commit" hides the Co-Authored-By trailer on commits.
if [ ! -f ~/.claude/settings.json ]; then
  echo "[dotfiles] Writing default Claude Code settings..."
  mkdir -p ~/.claude
  cat > ~/.claude/settings.json << 'EOF'
{
  "theme": "dark",
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
EOF
else
  # Existing settings file: merge the attribution key in, preserving everything else.
  if command -v jq &>/dev/null; then
    SETTINGS_TMP="$(mktemp)"
    if jq '.attribution = ((.attribution // {}) + {commit: "", pr: ""})' ~/.claude/settings.json > "$SETTINGS_TMP"; then
      if cmp -s "$SETTINGS_TMP" ~/.claude/settings.json; then
        rm -f "$SETTINGS_TMP"
        echo "[dotfiles] Claude Code attribution already disabled."
      else
        mv "$SETTINGS_TMP" ~/.claude/settings.json
        echo "[dotfiles] Disabled commit/PR attribution in existing ~/.claude/settings.json"
      fi
    else
      rm -f "$SETTINGS_TMP"
      echo "[dotfiles] Warning: ~/.claude/settings.json isn't valid JSON. Leaving it untouched."
    fi
  else
    echo "[dotfiles] Warning: jq not found; couldn't disable attribution in existing ~/.claude/settings.json."
  fi
fi

# Write global instruction not to add a Co-Authored-By trailer to git commits.
# GitHub resolves the default noreply@anthropic.com trailer to a real account
# (github.com/claude) and lists it as a contributor on every repo, which isn't
# wanted. Backed defense-in-depth by .claude/hooks/block-coauthor.sh in repos
# that have it, but this instruction is what makes it apply everywhere.
if [ ! -f ~/.claude/CLAUDE.md ]; then
  echo "[dotfiles] Writing global CLAUDE.md (no co-author trailer on commits)..."
  mkdir -p ~/.claude
  cat > ~/.claude/CLAUDE.md << 'EOF'
# Global instructions

## Git commits: no Co-Authored-By trailer

Never append a `Co-Authored-By: Claude ... <noreply@anthropic.com>` (or any Anthropic-model)
trailer to git commit messages, in this or any other repository. GitHub resolves that email to
a real account (`github.com/claude`) and credits it as a contributor on the repo's Contributors
page, which is not desired. This overrides the default commit-message behavior otherwise
described for git commits.
EOF
fi

# Append the pull-request rule to the global CLAUDE.md if it isn't there yet
# (so codespaces with an existing file gain it without being overwritten).
PR_RULE_HEADING='## Pull requests: no "Generated with Claude Code" footer'
if ! grep -qF "$PR_RULE_HEADING" ~/.claude/CLAUDE.md 2>/dev/null; then
  echo "[dotfiles] Adding PR attribution rule to global CLAUDE.md..."
  cat >> ~/.claude/CLAUDE.md << 'EOF'

## Pull requests: no "Generated with Claude Code" footer

Never add a "🤖 Generated with [Claude Code](https://claude.com/claude-code)" footer, or any
other Claude/Anthropic attribution, to pull request titles or descriptions, in this or any other
repository. This overrides the default pull-request behavior otherwise described for PRs.
EOF
fi

# Create .claude-docs/ inside every git repo under /workspaces
# Uses .git/info/exclude so it is ignored locally without touching global git config
echo "[dotfiles] Creating .claude-docs in workspaces..."
find /workspaces -name ".git" -type d 2>/dev/null | while read -r GIT_DIR; do
  PROJECT_ROOT=$(dirname "$GIT_DIR")
  CLAUDE_DOCS_DIR="$PROJECT_ROOT/.claude-docs"

  if [ ! -d "$CLAUDE_DOCS_DIR" ]; then
    mkdir -p "$CLAUDE_DOCS_DIR"
    echo "[dotfiles] Created $CLAUDE_DOCS_DIR"
  fi

  GIT_EXCLUDE="$GIT_DIR/info/exclude"
  if ! grep -qx '.claude-docs/' "$GIT_EXCLUDE" 2>/dev/null; then
    echo '.claude-docs/' >> "$GIT_EXCLUDE"
    echo "[dotfiles] Added .claude-docs/ to $GIT_EXCLUDE"
  fi
done

# Provision the "learn" skill (student-friendly two-tier code walkthroughs via /learn)
echo "[dotfiles] Provisioning learn skill..."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$DOTFILES_DIR/skills/learn"
SKILL_LINK=~/.claude/skills/learn
mkdir -p ~/.claude/skills
if [ -L "$SKILL_LINK" ]; then
  if [ "$(readlink "$SKILL_LINK")" = "$SKILL_SRC" ]; then
    echo "[dotfiles] learn skill already linked."
  else
    echo "[dotfiles] Warning: $SKILL_LINK is a symlink to something else ($(readlink "$SKILL_LINK")). Leaving it untouched."
  fi
elif [ -e "$SKILL_LINK" ]; then
  echo "[dotfiles] Warning: $SKILL_LINK already exists and is not managed by dotfiles. Leaving it untouched."
else
  ln -s "$SKILL_SRC" "$SKILL_LINK"
  echo "[dotfiles] Linked $SKILL_LINK -> $SKILL_SRC"
fi

echo "[dotfiles] Done."
