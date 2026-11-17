# dotfiles

Personal dotfiles repo for GitHub Codespaces. Automatically installs and configures Claude Code in every new codespace.

## What it does

On every new codespace, GitHub clones this repo to `~/dotfiles` and runs `install.sh`, which:

- Installs Claude Code via `npm install -g @anthropic-ai/claude-code`
- Writes `~/.claude.json` to skip the first-run onboarding wizard, and a default
  `~/.claude/settings.json` (dark theme, attribution off)
- Creates a `.claude-docs/` scratch dir in every git repo under `/workspaces`, and adds it to
  that repo's local `.git/info/exclude` so it's never accidentally committed
- Provisions a `learn` skill (`/learn`) into every codespace — a student-friendly, two-tier
  code walkthrough tool, symlinked from this repo so it stays in sync on `git pull`
- Writes a global `~/.claude/CLAUDE.md` instructing Claude not to add a `Co-Authored-By`
  trailer to git commits — GitHub resolves the default trailer to a real account
  (`github.com/claude`) and lists it as a contributor on every repo, which isn't wanted
- Turns off Claude Code's built-in attribution by setting `"attribution": {"commit": "", "pr": ""}`
  in `~/.claude/settings.json` (merged into an existing file with `jq`), so pull requests no
  longer get the "🤖 Generated with Claude Code" footer; the global `CLAUDE.md` gets a matching
  PR rule, and this repo adds a hook that blocks PR commands still carrying the footer

## First steps after a new codespace opens

1. Run `claude login` to authenticate with your Anthropic subscription
2. Start using Claude Code
3. Try `/learn path/to/file.py` (optionally `/learn path/to/file.py 10-40`) to get a plain-language
   overview of some code, then ask to "go deeper" for a full line-by-line breakdown

## Enabling dotfiles

In GitHub: `Settings → Codespaces → Dotfiles` → select this repo.
