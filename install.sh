#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code
if ! command -v claude &>/dev/null; then
  npm install -g @anthropic-ai/claude-code
fi

# Create personal .claude-docs scratch space
mkdir -p ~/.claude-docs

# Global gitignore — keeps .claude-docs/ out of every project repo
if ! grep -qx '.claude-docs/' ~/.gitignore_global 2>/dev/null; then
  echo '.claude-docs/' >> ~/.gitignore_global
fi
git config --global core.excludesfile ~/.gitignore_global
