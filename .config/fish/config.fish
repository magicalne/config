# ============================================
# Environment Variables
# ============================================
#
source ~/.config/fish/alias.fish
source ~/.config/fish/env.fish
set -gx EDITOR nvim


# Bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# Source your env file (if it contains env vars)
# Note: Fish doesn't source shell files directly, you'll need to convert it
# For now, manually add any needed vars from ~/.config/.env here

# ============================================
# Node Version Manager (fnm)
# ============================================
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# ============================================
# FZF Integration
# ============================================
if command -q fzf
    fzf --fish | source
end

# ============================================
# Starship Prompt (same as zsh!)
# ============================================
if command -q starship
    starship init fish | source
end

# ============================================
# Key Bindings
# ============================================
# Ctrl+n to accept autosuggestion (like your zsh binding)
bind \cn accept-autosuggestion

# ============================================
# Autosuggestion Color (like your ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE)
# ============================================
set -g fish_color_autosuggestion brblack

# ============================================
# Aliases (convert your git aliases if needed)
# ============================================
# Fish has git abbreviations built-in, but you can add custom ones:
# abbr -a gst 'git status'
# abbr -a gco 'git checkout'
# etc.

# ============================================
# Vi Mode (from your vi-mode plugin)
# ============================================
fish_vi_key_bindings
