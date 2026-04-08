#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/dotfiles.sh
source "$REPO_ROOT/scripts/lib/dotfiles.sh"

WITH_ZSH=0
DRY_RUN=0
SKIP_PACKAGES=0
SKIP_PLUGINS=0

usage() {
    cat <<'EOF'
Usage: ./bootstrap.sh [--with-zsh] [--dry-run] [--skip-packages] [--skip-plugins]

  --with-zsh      Also link the legacy zsh config.
  --dry-run       Print actions without changing anything.
  --skip-packages Skip package installation.
  --skip-plugins  Skip tmux / Neovim plugin installation.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --with-zsh)
            WITH_ZSH=1
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        --skip-packages)
            SKIP_PACKAGES=1
            ;;
        --skip-plugins)
            SKIP_PLUGINS=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown argument: $1"
            ;;
    esac
    shift
done

append_user_bins_to_path() {
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"
}

run_list_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    cat "$file"
}

ensure_homebrew() {
    if command_exists brew; then
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install Homebrew"
        return 0
    fi

    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_brew_bundle() {
    ensure_homebrew

    if ! command_exists brew; then
        warn "brew is still unavailable; skipping Brewfile"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would run brew bundle --file $REPO_ROOT/packages/Brewfile"
        return 0
    fi

    log "Installing Homebrew packages"
    brew bundle --file "$REPO_ROOT/packages/Brewfile"
}

install_apt_packages() {
    local pkg
    log "Installing apt packages"

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would run apt-get update"
    else
        as_root apt-get update
    fi

    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if dpkg -s "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via apt"
            continue
        fi

        as_root apt-get install -y "$pkg" || warn "Failed to install $pkg via apt"
    done < <(run_list_file "$REPO_ROOT/packages/apt.txt")
}

install_dnf_packages() {
    local pkg
    log "Installing dnf packages"

    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if rpm -q "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via dnf"
            continue
        fi

        as_root dnf install -y "$pkg" || warn "Failed to install $pkg via dnf"
    done < <(run_list_file "$REPO_ROOT/packages/dnf.txt")
}

install_pacman_packages() {
    local pkg
    log "Installing pacman packages"

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would run pacman -Sy"
    else
        as_root pacman -Sy --noconfirm
    fi

    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via pacman"
            continue
        fi

        as_root pacman -S --noconfirm --needed "$pkg" || warn "Failed to install $pkg via pacman"
    done < <(run_list_file "$REPO_ROOT/packages/pacman.txt")
}

install_system_packages() {
    case "$(os_name)" in
        macos)
            install_brew_bundle
            ;;
        linux)
            if command_exists apt-get; then
                install_apt_packages
            elif command_exists dnf; then
                install_dnf_packages
            elif command_exists pacman; then
                install_pacman_packages
            elif command_exists brew; then
                install_brew_bundle
            else
                warn "No supported package manager found; skipping system package installation"
            fi
            ;;
        *)
            warn "Unsupported OS for package installation"
            ;;
    esac
}

install_rustup_if_missing() {
    if command_exists rustup; then
        info "rustup already installed"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install rustup"
        return 0
    fi

    log "Installing rustup"
    curl https://sh.rustup.rs -sSf | sh -s -- -y

    append_user_bins_to_path
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
}

install_starship_if_missing() {
    if command_exists starship; then
        info "starship already installed"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install starship"
        return 0
    fi

    log "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

install_bun_if_missing() {
    if command_exists bun; then
        info "bun already installed"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install bun"
        return 0
    fi

    log "Installing bun"
    curl -fsSL https://bun.sh/install | bash
    append_user_bins_to_path
}

install_cargo_packages() {
    local pkg

    if ! command_exists cargo; then
        warn "cargo not available; skipping cargo packages"
        return 0
    fi

    log "Installing cargo packages"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if cargo install --list | grep -q "^$pkg v"; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via cargo"
            continue
        fi

        cargo install "$pkg" || warn "Failed to install $pkg via cargo"
    done < <(run_list_file "$REPO_ROOT/packages/cargo.txt")
}

install_uv_if_missing() {
    if command_exists uv; then
        info "uv already installed"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install uv"
        return 0
    fi

    log "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh
    append_user_bins_to_path
}

uv_tool_installed() {
    local pkg="$1"

    uv tool list 2>/dev/null | awk '/^[^[:space:]-]/ { print $1 }' | grep -Fxq "$pkg"
}

install_uv_tools() {
    local pkg

    if ! command_exists uv; then
        warn "uv not available; skipping uv tools"
        return 0
    fi

    log "Installing uv tools"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if uv_tool_installed "$pkg"; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via uv tool"
            continue
        fi

        uv tool install "$pkg" || warn "Failed to install $pkg via uv tool"
    done < <(run_list_file "$REPO_ROOT/packages/uv-tools.txt")
}

bun_global_package_installed() {
    local pkg="$1"

    bun pm ls -g --depth 0 2>/dev/null | grep -Fq "$pkg@"
}

install_bun_global_packages() {
    local pkg

    if ! command_exists bun; then
        warn "bun not available; skipping Bun global packages"
        return 0
    fi

    log "Installing Bun global packages"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if bun_global_package_installed "$pkg"; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via bun"
            continue
        fi

        bun add --global "$pkg" || warn "Failed to install $pkg via bun"
    done < <(run_list_file "$REPO_ROOT/packages/bun-global.txt")
}

tmux_conf_uses_tpm() {
    local tmux_conf="$HOME/.tmux.conf"

    [ -f "$tmux_conf" ] || return 1
    grep -Fq "tmux-plugins/tpm" "$tmux_conf"
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    local tpm_entry="$tpm_dir/tpm"

    if [ -x "$tpm_entry" ]; then
        info "tpm already installed"
        return 0
    fi

    if ! command_exists git; then
        warn "git not available; skipping tpm installation"
        return 0
    fi

    if [ -d "$tpm_dir" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
            info "would recreate incomplete ~/.tmux/plugins/tpm checkout"
            return 0
        fi

        warn "Refreshing incomplete TPM checkout at ~/.tmux/plugins/tpm"
        rm -rf "$tpm_dir"
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would clone tmux-plugins/tpm into ~/.tmux/plugins/tpm"
        return 0
    fi

    log "Installing tmux plugin manager"
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || warn "Failed to clone tmux-plugins/tpm"
}

install_tmux_plugins() {
    local installer="$HOME/.tmux/plugins/tpm/bin/install_plugins"

    if ! tmux_conf_uses_tpm; then
        warn "~/.tmux.conf does not reference TPM; skipping tmux plugin installation"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install tmux plugins via TPM"
        return 0
    fi

    if ! command_exists tmux; then
        warn "tmux not available; skipping tmux plugin installation"
        return 0
    fi

    if [ ! -x "$installer" ]; then
        warn "tpm installer not found; skipping tmux plugin installation"
        return 0
    fi

    log "Installing tmux plugins"
    if ! tmux start-server \; source-file "$HOME/.tmux.conf" >/dev/null 2>&1; then
        warn "Failed to source ~/.tmux.conf for TPM; skipping tmux plugin installation"
        return 0
    fi

    "$installer" || warn "tmux plugin installation failed"
}

install_neovim_plugins() {
    local nvim_init="$HOME/.config/nvim/init.vim"
    local bootstrap_vim

    if ! command_exists nvim; then
        warn "nvim not available; skipping Neovim plugin installation"
        return 0
    fi

    if [ ! -f "$nvim_init" ]; then
        warn "~/.config/nvim/init.vim not found; skipping Neovim plugin installation"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would run PlugInstall for Neovim and install treesitter parsers"
        return 0
    fi

    bootstrap_vim="$(mktemp "${TMPDIR:-/tmp}/nvim-bootstrap.XXXXXX")"
    if ! awk '{ print } /call plug#end\(\)/ { exit }' "$nvim_init" > "$bootstrap_vim"; then
        rm -f "$bootstrap_vim"
        warn "Failed to prepare bootstrap Neovim config"
        return 0
    fi

    log "Installing Neovim plugins"
    if ! nvim --headless -u "$bootstrap_vim" '+PlugInstall --sync' +qa; then
        rm -f "$bootstrap_vim"
        warn "Neovim plugin installation failed"
        return 0
    fi

    rm -f "$bootstrap_vim"

    log "Installing Neovim treesitter parsers"
    nvim --headless \
        "+lua require('nvim-treesitter').install({ 'c', 'html', 'javascript', 'lua', 'python', 'rust', 'solidity', 'tsx', 'typescript' }):wait(300000)" \
        +qa || warn "Neovim treesitter parser installation failed"

    log "Verifying Neovim config"
    nvim --headless +qa || warn "Neovim config verification failed after plugin installation"
}

configure_git_hooks() {
    if ! command_exists git; then
        warn "git not available; skipping git hook setup"
        return 0
    fi

    if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        warn "Not inside a git repository; skipping git hook setup"
        return 0
    fi

    if [ ! -d "$REPO_ROOT/.githooks" ]; then
        warn "Missing .githooks directory; skipping git hook setup"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would set git core.hooksPath to .githooks"
        return 0
    fi

    git -C "$REPO_ROOT" config core.hooksPath .githooks
    info "configured repo-local git hooks (.githooks)"
}

seed_private_example() {
    local example="$1"
    local target="$2"
    local warning_message="$3"

    [ -f "$example" ] || return 0
    [ -f "$target" ] && return 0

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would create placeholder $target"
        return 0
    fi

    ensure_parent_dir "$target"
    cp "$example" "$target"
    warn "$warning_message"
}

seed_private_examples() {
    seed_private_example \
        "$REPO_ROOT/dotfiles/.pi/agent/mcp.example.json" \
        "$HOME/.pi/agent/mcp.json" \
        "Created placeholder ~/.pi/agent/mcp.json. Fill in your private API keys before using MCP."

    seed_private_example \
        "$REPO_ROOT/dotfiles/.config/fish/llm.local.example.fish" \
        "$HOME/.config/fish/llm.local.fish" \
        "Created placeholder ~/.config/fish/llm.local.fish. Fill in only the API keys you actually use."

    seed_private_example \
        "$REPO_ROOT/dotfiles/.profile.local.example" \
        "$HOME/.profile.local" \
        "Created placeholder ~/.profile.local for private shell exports."
}

print_notes() {
    cat <<'EOF'

Next steps / reminders:
- Fonts: install a Nerd Font, ideally JetBrainsMono Nerd Font Mono.
- Private shell overrides live in ~/.profile.local, ~/.config/fish/local.fish, and ~/.config/fish/llm.local.fish.
- Private API keys should never be added to tracked files under dotfiles/.
- Private pi MCP config lives in ~/.pi/agent/mcp.json.
- Review and fill the placeholder files created during bootstrap before using AI tooling.
- Python CLI tools are installed with uv; Bun-managed CLIs land in ~/.bun/bin.
- bootstrap.sh bootstraps TPM into ~/.tmux/plugins/tpm and installs tmux plugins unless --skip-plugins is used.
- A pre-commit hook is configured through .githooks and runs ./scripts/check-secrets.sh.
- Use ./sync-local.sh before editing in the repo if you made changes directly in $HOME.
EOF
}

main() {
    append_user_bins_to_path

    if [ "$SKIP_PACKAGES" -eq 0 ]; then
        install_system_packages
        install_rustup_if_missing
        append_user_bins_to_path
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
        install_starship_if_missing
        install_bun_if_missing
        install_uv_if_missing
        install_cargo_packages
        install_uv_tools
        install_bun_global_packages
    fi

    if [ "$WITH_ZSH" -eq 1 ] && [ "$DRY_RUN" -eq 1 ]; then
        "$REPO_ROOT/apply.sh" --with-zsh --dry-run
    elif [ "$WITH_ZSH" -eq 1 ]; then
        "$REPO_ROOT/apply.sh" --with-zsh
    elif [ "$DRY_RUN" -eq 1 ]; then
        "$REPO_ROOT/apply.sh" --dry-run
    else
        "$REPO_ROOT/apply.sh"
    fi

    configure_git_hooks

    if [ "$SKIP_PLUGINS" -eq 0 ]; then
        install_tpm
        install_tmux_plugins
        install_neovim_plugins
    fi

    seed_private_examples
    print_notes
}

log "Bootstrapping dotfiles from $REPO_ROOT"
[ "$DRY_RUN" -eq 1 ] && info "dry-run mode enabled"
main
