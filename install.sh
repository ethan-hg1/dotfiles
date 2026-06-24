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
if [ ! -f ~/.claude/settings.json ]; then
  echo "[dotfiles] Writing default Claude Code settings..."
  mkdir -p ~/.claude
  cat > ~/.claude/settings.json << 'EOF'
{
  "theme": "dark"
}
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

echo "[dotfiles] Done."
