# Plan: Claude Code in All Future Codespaces

## How Codespaces Dotfiles Work

GitHub Codespaces automatically detects a repo named `dotfiles` on your account, clones it into `~/dotfiles`, and runs an install script at container creation time. Scripts it looks for (in priority order): `install.sh`, `bootstrap.sh`, `setup.sh`. We'll use `install.sh`.

---

## Implementation Steps

### 1. Create `install.sh`
The script needs to:
- Install Claude Code globally via `npm install -g @anthropic-ai/claude-code`
- Create `~/.claude-docs/` as a personal scratch space available in every codespace
- Configure a global gitignore (`~/.gitignore_global`) that excludes `.claude-docs/` so it is never accidentally committed in any project repo
- Be idempotent — safe to run multiple times

### 2. Handle Authentication
Claude Code with a subscription authenticates via `claude login` (OAuth browser flow). Run it manually each time a new codespace opens — no secrets or stored credentials needed.

### 3. (Optional) Default Configuration
`install.sh` can symlink or copy a `claude/settings.json` from the dotfiles repo into `~/.claude/settings.json` to pre-configure Claude Code preferences (theme, model, permissions, etc.) across all codespaces.

### 4. Enable Dotfiles in Codespaces Settings
In GitHub: `Settings → Codespaces → Dotfiles` → enable and point to this repo (`dotfiles`).

---

## Recommended `install.sh` Structure

```bash
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

# (Optional) symlink Claude config
# mkdir -p ~/.claude
# ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
```

---

## Decisions

1. **Config**: Leave Claude Code settings at defaults for now. May revisit later.
2. **Install method**: Use `npm install -g @anthropic-ai/claude-code`. Codespaces always has Node/npm; it's the official install path and easy to version-pin later. No curl needed.
3. **Scope**: `install.sh` stays Claude-focused — no shell config or PATH tweaks.
4. **CLAUDE.md**: Add one to this repo for context about the dotfiles setup itself. Do not symlink into new codespaces.

---

## File Layout (End State)

```
dotfiles/
├── install.sh              # entry point — run by Codespaces automatically
├── claude/
│   └── settings.json       # (optional) shared Claude Code config
├── .claude-docs/
│   ├── prompt.md
│   └── plan.md             # this file
└── README.md
```
