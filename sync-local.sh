#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/dotfiles.sh
source "$REPO_ROOT/scripts/lib/dotfiles.sh"

WITH_ZSH=0
DRY_RUN=0
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.dotfiles-backups/sync/$TIMESTAMP"

usage() {
    cat <<'EOF'
Usage: ./sync-local.sh [--with-zsh] [--dry-run]

Imports local files from $HOME back into the repo for managed paths that are
not already symlinked to this repo.

  --with-zsh   Also import the legacy zsh config.
  --dry-run    Print actions without changing anything.
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

log "Importing local changes from $HOME into $REPO_ROOT"
[ "$WITH_ZSH" -eq 1 ] && info "including legacy zsh config"
[ "$DRY_RUN" -eq 1 ] && info "dry-run mode enabled"

while IFS='|' read -r group repo_relative target_relative; do
    case "$group" in
        ''|'#'*)
            continue
            ;;
    esac

    should_include_group "$group" "$WITH_ZSH" || continue
    import_local_file "$repo_relative" "$target_relative" "$BACKUP_ROOT" "$DRY_RUN"
done < <(manifest_entries)

if [ -d "$BACKUP_ROOT" ]; then
    log "Backups stored in $BACKUP_ROOT"
fi

log "Done"
