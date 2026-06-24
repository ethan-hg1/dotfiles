# dotfiles

Personal dotfiles repo for GitHub Codespaces. Automatically installs and configures Claude Code in every new codespace.

## What it does

On every new codespace, GitHub clones this repo to `~/dotfiles` and runs `install.sh`, which:

- Installs Claude Code via `npm install -g @anthropic-ai/claude-code`
- Writes a default `~/.claude/settings.json` to skip the first-run onboarding wizard
- Creates `~/.claude-docs/` as a personal scratch space for Claude-related notes
- Adds `.claude-docs/` to a global gitignore so it is never accidentally committed in any project repo

## First steps after a new codespace opens

1. Run `claude login` to authenticate with your Anthropic subscription
2. Start using Claude Code

## Enabling dotfiles

In GitHub: `Settings → Codespaces → Dotfiles` → select this repo.
