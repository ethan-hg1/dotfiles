# Dotfiles

This repo is automatically cloned into `~/dotfiles` by GitHub Codespaces and `install.sh` is run at container creation time.

## What install.sh does

- Installs Claude Code (`npm install -g @anthropic-ai/claude-code`)
- Creates `~/.claude-docs/` as a scratch space for Claude-related notes in each codespace
- Adds `.claude-docs/` to a global gitignore (`~/.gitignore_global`) so it is never accidentally committed in any project repo

## Authentication

Run `claude login` once after each new codespace opens to authenticate with your Anthropic subscription.

## Repo structure

```
dotfiles/
├── install.sh       # run automatically by Codespaces on container creation
├── CLAUDE.md        # this file
├── .claude-docs/    # planning docs for this repo (tracked here, ignored elsewhere)
└── README.md
```
