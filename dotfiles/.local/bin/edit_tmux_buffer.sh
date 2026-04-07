#!/usr/bin/env bash

set -euo pipefail

file="$(mktemp).sh"
tmux capture-pane -pS -32768 > "$file"
tmux new-window -n buffer "nvim '+ normal G $' \"$file\""
