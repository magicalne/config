#!/usr/bin/env bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LINK_MANIFEST="$DOTFILES_ROOT/manifests/links.txt"

log() {
    printf '==> %s\n' "$*"
}

info() {
    printf '  -> %s\n' "$*"
}

warn() {
    printf 'WARN: %s\n' "$*" >&2
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

os_name() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

expand_home_target() {
    local relative_path="$1"
    printf '%s/%s\n' "$HOME" "$relative_path"
}

ensure_parent_dir() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
}

manifest_entries() {
    [ -f "$LINK_MANIFEST" ] || die "Missing manifest: $LINK_MANIFEST"
    cat "$LINK_MANIFEST"
}

should_include_group() {
    local group="$1"
    local with_zsh="${2:-0}"
    local current_os
    current_os="$(os_name)"

    case "$group" in
        common)
            return 0
            ;;
        optional-zsh)
            [ "$with_zsh" -eq 1 ]
            ;;
        macos)
            [ "$current_os" = "macos" ]
            ;;
        linux)
            [ "$current_os" = "linux" ]
            ;;
        *)
            return 1
            ;;
    esac
}

backup_path_for() {
    local backup_root="$1"
    local relative_target="$2"
    printf '%s/%s\n' "$backup_root" "$relative_target"
}

backup_existing_target() {
    local target_path="$1"
    local relative_target="$2"
    local backup_root="$3"
    local dry_run="${4:-0}"
    local backup_path

    backup_path="$(backup_path_for "$backup_root" "$relative_target")"
    ensure_parent_dir "$backup_path"

    if [ "$dry_run" -eq 1 ]; then
        info "would back up $target_path -> $backup_path"
        return 0
    fi

    mv "$target_path" "$backup_path"
    info "backed up $target_path -> $backup_path"
}

apply_link() {
    local repo_relative="$1"
    local target_relative="$2"
    local backup_root="$3"
    local dry_run="${4:-0}"
    local source_path target_path

    source_path="$DOTFILES_ROOT/$repo_relative"
    target_path="$(expand_home_target "$target_relative")"

    if [ ! -e "$source_path" ] && [ ! -L "$source_path" ]; then
        warn "Skipping missing source: $repo_relative"
        return 0
    fi

    ensure_parent_dir "$target_path"

    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
        info "$target_relative already linked"
        return 0
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup_existing_target "$target_path" "$target_relative" "$backup_root" "$dry_run"
    fi

    if [ "$dry_run" -eq 1 ]; then
        info "would link $target_relative -> $source_path"
        return 0
    fi

    ln -s "$source_path" "$target_path"
    info "linked $target_relative -> $source_path"
}

import_local_file() {
    local repo_relative="$1"
    local target_relative="$2"
    local backup_root="$3"
    local dry_run="${4:-0}"
    local repo_path home_path backup_path

    repo_path="$DOTFILES_ROOT/$repo_relative"
    home_path="$(expand_home_target "$target_relative")"

    if [ ! -e "$home_path" ] && [ ! -L "$home_path" ]; then
        info "skip missing $target_relative"
        return 0
    fi

    if [ -L "$home_path" ] && [ "$(readlink "$home_path")" = "$repo_path" ]; then
        info "skip managed symlink $target_relative"
        return 0
    fi

    ensure_parent_dir "$repo_path"

    if [ -e "$repo_path" ] || [ -L "$repo_path" ]; then
        backup_path="$(backup_path_for "$backup_root" "$repo_relative")"
        ensure_parent_dir "$backup_path"
        if [ "$dry_run" -eq 1 ]; then
            info "would back up repo copy $repo_relative -> $backup_path"
        else
            cp -R "$repo_path" "$backup_path"
            info "backed up repo copy $repo_relative -> $backup_path"
        fi
    fi

    if [ "$dry_run" -eq 1 ]; then
        info "would import $target_relative -> $repo_relative"
        return 0
    fi

    cp "$home_path" "$repo_path"
    info "imported $target_relative -> $repo_relative"
}
