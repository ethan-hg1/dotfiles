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

# Skip first-run onboarding wizard
if [ ! -f ~/.claude/settings.json ]; then
  echo "[dotfiles] Writing default Claude Code settings..."
  mkdir -p ~/.claude
  cat > ~/.claude/settings.json << 'EOF'
{
  "theme": "dark"
}
EOF
fi

# Create personal .claude-docs scratch space
echo "[dotfiles] Creating ~/.claude-docs..."
mkdir -p ~/.claude-docs

# Global gitignore — keeps .claude-docs/ out of every project repo
echo "[dotfiles] Configuring global gitignore..."
if ! grep -qx '.claude-docs/' ~/.gitignore_global 2>/dev/null; then
  echo '.claude-docs/' >> ~/.gitignore_global
fi
git config --global core.excludesfile ~/.gitignore_global

echo "[dotfiles] Done."
