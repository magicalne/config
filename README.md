# Terminal dotfiles

This repo is the source of truth for my terminal-first setup across macOS and Linux.

## Principles

- macOS and Linux are first-class
- Windows is not a target
- fish is the main shell
- tmux, Neovim, and pi coding agent are core tools
- symlinks are the default, not copies
- machine-local secrets and one-off hacks should live outside git

## Layout

The repo uses a home-directory mirror under `dotfiles/`.

That means files in the repo map naturally to `$HOME` targets:

- `dotfiles/.tmux.conf` -> `~/.tmux.conf`
- `dotfiles/.config/fish/config.fish` -> `~/.config/fish/config.fish`
- `dotfiles/.config/nvim/init.vim` -> `~/.config/nvim/init.vim`
- `dotfiles/.pi/agent/settings.json` -> `~/.pi/agent/settings.json`
- `dotfiles/.local/bin/notify` -> `~/.local/bin/notify`

The exact mapping list lives in `manifests/links.txt`.

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
- fd / `fd-find`
- exa
- cargo / rustup
- rust-analyzer
- clippy
- rustfmt
- python / pip / pipenv
- ruff
- pyright
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
- Ollama
- DeepSeek
- Mistral
- Gemini
- Qwen
- Z.ai / Zhipu
- Moonshot / Kimi
- OpenRouter
- Cerebras
- Hyperbolic

### Optional / legacy

- zsh / oh-my-zsh
- Vim migration config under `dotfiles/.config/vim/` if reintroduced later
- TabbyML
- conda / miniconda

## Repo workflow

This repo is **symlink-first**.

That means:

- the repo stays the source of truth
- `./apply.sh` links repo files into `$HOME`
- `./bootstrap.sh` installs missing software, applies links, and installs plugins
- `./sync-local.sh` imports unmanaged files from `$HOME` back into the repo before linking

Once everything is symlinked, editing a config in `$HOME` edits the repo copy automatically.

## Commands

### Bootstrap a new machine

```sh
./bootstrap.sh
```

Optional legacy zsh support:

```sh
./bootstrap.sh --with-zsh
```

### Re-apply links after pulling changes

```sh
./apply.sh
```

### Import local unmanaged changes back into the repo

```sh
./sync-local.sh
```

Dry-run is supported on all scripts:

```sh
./bootstrap.sh --dry-run
./apply.sh --dry-run
./sync-local.sh --dry-run
```

## What gets managed

Managed file mappings live in `manifests/links.txt`.

Package manifests live in `packages/`:

- `packages/Brewfile`
- `packages/apt.txt`
- `packages/dnf.txt`
- `packages/pacman.txt`
- `packages/cargo.txt`
- `packages/pip.txt`
- `packages/npm-global.txt`

## Local / private overrides

Keep machine-specific or private values out of shared config when possible.

Preferred local override files:

- `~/.profile.local`
- `~/.config/fish/local.fish`
- `~/.config/fish/llm.local.fish`
- `~/.zshrc.local`
- `~/.config/nvim/local.plugins.vim`
- `~/.config/nvim/local.vim`
- `~/.pi/agent/mcp.json`

Tracked shared files must not contain live secrets.

Bootstrap creates local placeholders for the most sensitive files if they do not already exist:

- `~/.profile.local`
- `~/.config/fish/llm.local.fish`
- `~/.pi/agent/mcp.json`

Templates live in the repo here:

- `dotfiles/.profile.local.example`
- `dotfiles/.config/fish/llm.local.example.fish`
- `dotfiles/.pi/agent/mcp.example.json`

Private / machine-local files intentionally ignored by git include repo-side placeholders like:

- `dotfiles/.config/fish/fish_variables`
- `dotfiles/.pi/agent/auth.json`
- `dotfiles/.pi/agent/mcp.json`
- `dotfiles/.pi/agent/mcp-cache.json`
- `dotfiles/.pi/agent/mcp-npx-cache.json`
- local override files such as `dotfiles/.config/fish/llm.local.fish` and `dotfiles/.profile.local`

## Fonts

Recommended:

- JetBrainsMono Nerd Font Mono
- more Nerd Fonts: <https://www.nerdfonts.com/font-downloads>
- Monego: <https://github.com/cseelus/monego>

## Notes

- tmux plugins are installed through TPM into `~/.tmux/plugins`.
- Neovim plugins are managed with vim-plug.
- `dotfiles/.local/bin/notify` is linked to `~/.local/bin/notify` and supports both macOS and Linux notification backends.
- pi MCP secrets are not committed. Start from `dotfiles/.pi/agent/mcp.example.json`.
- LLM API keys are not committed. Keep them in `~/.config/fish/llm.local.fish`.
- General private shell exports belong in `~/.profile.local`.
- Run `./scripts/check-secrets.sh` before committing if you want a quick sanity check.
- zsh is kept as a legacy fallback, not the preferred future path.

## Optional extras

### Tabby / local model serving

Optional experiments and side tooling still in the workflow:

- TabbyML
- Nvidia container toolkit
- `nvidia-ctk`
- podman / docker GPU workflows
