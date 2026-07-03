# Dotfiles

This repo is automatically cloned into `~/dotfiles` by GitHub Codespaces and `install.sh` is run at container creation time.

## What install.sh does

- Installs Claude Code (`npm install -g @anthropic-ai/claude-code`)
- Creates a `.claude-docs/` scratch dir in every git repo under `/workspaces`, excluded via that
  repo's local `.git/info/exclude` (not a global gitignore)
- Symlinks `skills/learn/` from this repo into `~/.claude/skills/learn`, making the `/learn`
  command (student-mode, two-tier code walkthroughs) available in every codespace

## Authentication

Run `claude login` once after each new codespace opens to authenticate with your Anthropic subscription.

## Repo structure

```
dotfiles/
├── install.sh       # run automatically by Codespaces on container creation
├── CLAUDE.md        # this file
├── skills/
│   └── learn/       # SKILL.md for the /learn command, symlinked into ~/.claude/skills/learn
├── .claude-docs/    # planning docs for this repo (tracked here, ignored elsewhere)
└── README.md
```
