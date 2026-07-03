# dotfiles

Personal dotfiles repo for GitHub Codespaces. Automatically installs and configures Claude Code in every new codespace.

## What it does

On every new codespace, GitHub clones this repo to `~/dotfiles` and runs `install.sh`, which:

- Installs Claude Code via `npm install -g @anthropic-ai/claude-code`
- Writes a default `~/.claude/settings.json` to skip the first-run onboarding wizard
- Creates a `.claude-docs/` scratch dir in every git repo under `/workspaces`, and adds it to
  that repo's local `.git/info/exclude` so it's never accidentally committed
- Provisions a `learn` skill (`/learn`) into every codespace — a student-friendly, two-tier
  code walkthrough tool, symlinked from this repo so it stays in sync on `git pull`

## First steps after a new codespace opens

1. Run `claude login` to authenticate with your Anthropic subscription
2. Start using Claude Code
3. Try `/learn path/to/file.py` (optionally `/learn path/to/file.py 10-40`) to get a plain-language
   overview of some code, then ask to "go deeper" for a full line-by-line breakdown

## Enabling dotfiles

In GitHub: `Settings → Codespaces → Dotfiles` → select this repo.
