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

install_pip_packages() {
    local pkg

    if ! command_exists python3; then
        warn "python3 not available; skipping pip packages"
        return 0
    fi

    log "Installing pip packages"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if python3 -m pip show "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via pip"
            continue
        fi

        python3 -m pip install --user "$pkg" || warn "Failed to install $pkg via pip"
    done < <(run_list_file "$REPO_ROOT/packages/pip.txt")
}

install_npm_global_packages() {
    local pkg

    if ! command_exists npm; then
        warn "npm not available; skipping global npm packages"
        return 0
    fi

    log "Installing global npm packages"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            ''|'#'*)
                continue
                ;;
        esac

        if npm list -g --depth=0 "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            info "would install $pkg via npm"
            continue
        fi

        npm install -g "$pkg" || warn "Failed to install $pkg via npm"
    done < <(run_list_file "$REPO_ROOT/packages/npm-global.txt")
}

install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        info "tpm already installed"
        return 0
    fi

    if ! command_exists git; then
        warn "git not available; skipping tpm installation"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would clone tmux-plugins/tpm"
        return 0
    fi

    log "Installing tmux plugin manager"
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}

install_tmux_plugins() {
    local installer="$HOME/.tmux/plugins/tpm/bin/install_plugins"

    if [ ! -x "$installer" ]; then
        warn "tpm installer not found; skipping tmux plugin installation"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would install tmux plugins"
        return 0
    fi

    log "Installing tmux plugins"
    "$installer" || warn "tmux plugin installation failed"
}

install_neovim_plugins() {
    if ! command_exists nvim; then
        warn "nvim not available; skipping Neovim plugin installation"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "would run PlugInstall for Neovim"
        return 0
    fi

    log "Installing Neovim plugins"
    nvim --headless '+PlugInstall --sync' +qa || warn "Neovim plugin installation failed"
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
        install_cargo_packages
        install_pip_packages
        install_npm_global_packages
    fi

    apply_args=()
    [ "$WITH_ZSH" -eq 1 ] && apply_args+=(--with-zsh)
    [ "$DRY_RUN" -eq 1 ] && apply_args+=(--dry-run)
    "$REPO_ROOT/apply.sh" "${apply_args[@]}"

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
