# AGENTS.md

## Purpose

This repo is the source of truth for terminal-centric personal configs across macOS and Linux.

Windows is not a target platform.

The goal is to keep the daily terminal workflow consistent across machines with minimal drift.

## User priorities

1. Terminal-first workflow.
2. Consistency across macOS and Linux.
3. Fish is the primary shell.
4. Neovim is the primary editor.
5. tmux is a first-class part of the workflow.
6. pi coding agent is a first-class tool.
7. zsh is legacy and optional.
8. Avoid Windows-specific work unless explicitly requested.

## Repo layout

The repo mirrors the home directory under `dotfiles/`.

Examples:

- `dotfiles/.tmux.conf` maps to `~/.tmux.conf`
- `dotfiles/.config/fish/config.fish` maps to `~/.config/fish/config.fish`
- `dotfiles/.config/nvim/init.vim` maps to `~/.config/nvim/init.vim`
- `dotfiles/.pi/agent/settings.json` maps to `~/.pi/agent/settings.json`
- `dotfiles/.local/bin/notify` maps to `~/.local/bin/notify`

Exact mappings live in `manifests/links.txt`.

## Canonical shared config areas

Primary shared configs in this repo include:

- `dotfiles/.tmux.conf`
- `dotfiles/.tmux.remote.conf`
- `dotfiles/.profile`
- `dotfiles/.config/fish/`
- `dotfiles/.config/nvim/`
- `dotfiles/.config/starship.toml`
- `dotfiles/.config/alacritty/alacritty.toml`
- `dotfiles/.config/ghostty/config`
- `dotfiles/.pi/agent/settings.json`
- `dotfiles/.pi/agent/models.json`
- `dotfiles/.pi/extensions/notify.ts`
- `dotfiles/.local/bin/notify`
- `dotfiles/.local/bin/edit_tmux_buffer.sh`

Optional / legacy:

- `dotfiles/.zshrc`
- Vim-specific configs only if intentionally reintroduced later

Automation and manifests:

- `bootstrap.sh` installs missing software, applies symlinks, installs plugins, and configures repo-local git hooks.
- `apply.sh` refreshes symlinks into `$HOME`.
- `sync-local.sh` imports unmanaged `$HOME` changes back into the repo.
- `.githooks/pre-commit` runs the secret sanity check before commits when hooks are enabled.
- `manifests/links.txt` is the source of truth for file mappings.
- `packages/` contains package manifests for macOS and Linux.

## Repo caveats

- `dotfiles/.config/nvim/init.vim` is the primary editor config.
- `dotfiles/.pi/agent/auth.json` and `dotfiles/.pi/agent/mcp.json` are private local files and must not be committed with secrets.
- `dotfiles/.config/fish/llm.fish` is shared logic only. Live API keys belong in `~/.config/fish/llm.local.fish`, not in the repo.
- General private exports belong in `~/.profile.local`, not in tracked files.
- `dotfiles/.config/fish/fish_variables` is machine-local state and is intentionally ignored.
- Windows-specific work is out of scope unless the user explicitly asks for it.
- Prefer symlink-friendly config management. The repo should remain the source of truth.

## Software in active use

### Core apps

- tmux
- fish
- neovim
- pi coding agent
- starship
- alacritty
- ghostty

### Supporting CLI / dev tools

- git
- bun / bunx
- fnm
- node / npm
- fzf
- ripgrep (`rg`)
- fd / fd-find
- exa
- cargo / rustup
- rust-analyzer / clippy / rustfmt
- python / pip / pipenv
- ruff / pyright
- go / goimports
- llvm / clang-format
- docker / podman
- vim-plug
- tmux plugin manager (`tpm`)
- xclip (Linux)
- osascript (macOS)

### AI / agent tooling

- pi coding agent
- GitHub Copilot provider for pi
- pi-provider-kiro
- pi-mcp-adapter
- Claude Code notification hook
- Ollama / DeepSeek / Mistral / Gemini / Qwen / Z.ai / Moonshot / OpenRouter

### Optional / legacy / side paths

- zsh / oh-my-zsh
- coc.nvim
- conda / miniconda
- TabbyML

## Local override files

Keep machine-specific or private customizations outside the shared files when possible.

Preferred local override files:

- `~/.profile.local`
- `~/.config/fish/local.fish`
- `~/.config/fish/llm.local.fish`
- `~/.zshrc.local`
- `~/.config/nvim/local.plugins.vim`
- `~/.config/nvim/local.vim`
- `~/.pi/agent/mcp.json`

Example templates in the repo:

- `dotfiles/.profile.local.example`
- `dotfiles/.config/fish/llm.local.example.fish`
- `dotfiles/.pi/agent/mcp.example.json`

## Change guidelines for agents

- Prefer shared config plus explicit macOS/Linux conditionals over per-machine hardcoded paths.
- Keep scripts idempotent and safe to rerun.
- Guard optional integrations with existence checks.
- Do not commit secrets, tokens, auth blobs, or machine IDs.
- If you touch anything related to auth or API keys, keep them in ignored local override files only.
- Avoid unnecessary plugin churn in tmux, fish, and neovim.
- If a value is machine-specific, move it into a local override instead of baking it into the shared config.
- Keep zsh support minimal unless the user explicitly asks to invest in it.
- Prefer keeping all home-mirrored config files under `dotfiles/`.

## Validation after changes

When relevant, validate with lightweight checks such as:

- `fish -C 'source ~/.config/fish/config.fish' -c exit`
- `tmux source-file ~/.tmux.conf`
- `nvim --headless +q`
- `./scripts/check-secrets.sh`
- verify `tmux`, `fish`, `nvim`, `starship`, `fzf`, `rg`, `fd`, and `pi` resolve as expected

## What not to do

- Do not assume Windows matters.
- Do not assume zsh is primary.
- Do not treat private `.pi` files as safe to commit.
- Do not treat untracked experimental files as canonical without confirmation.
