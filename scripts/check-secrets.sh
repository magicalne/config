#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PATTERN='(sk-[A-Za-z0-9_-]+|ghp_[A-Za-z0-9]+|glpat-[A-Za-z0-9_-]+|xox[baprs]-[A-Za-z0-9-]+|AIza[0-9A-Za-z_-]+|Bearer [A-Za-z0-9._-]{20,}|(API_KEY|AUTH_TOKEN)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9._-]{16,})'

if rg -n --hidden -S "$PATTERN" \
    . \
    -g '!.git/*' \
    -g '!scripts/check-secrets.sh' \
    -g '!dotfiles/.pi/agent/mcp.example.json' \
    -g '!dotfiles/.config/fish/llm.local.example.fish' \
    -g '!dotfiles/.profile.local.example' \
    -g '!dotfiles/.config/nvim/autoload/plug.vim'
then
    echo
    echo 'Potential secret-like content found. Review before committing.' >&2
    exit 1
fi

echo 'No obvious secrets found.'
