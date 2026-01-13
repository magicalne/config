# General environment variables migrated from zsh .profile

# ========== PATH Configuration ==========
# Add each path component (order matters, first added = highest priority)
fish_add_path $HOME/cli/bin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.local/bin
# Linux paths (commented out for macOS)
# fish_add_path /opt/go/bin
# fish_add_path /opt/shadowsocks/bin
fish_add_path /opt/homebrew/opt/binutils/bin

# ========== Cargo/rust ==========
fish_add_path $HOME/.cargo/bin

# ========== System Environment Variables ==========
set -gx GIO_EXTRA_MODULES /usr/lib64/gio/modules/

# Proxy settings (commented out)
# set -gx http_proxy socks5://192.168.2.1:23456
# set -gx https_proxy socks5://192.168.2.1:23456

set -gx PKG_CONFIG_PATH /usr/lib64/pkgconfig
set -gx TERM xterm-256color
set -gx EDITOR /usr/bin/nvim

# FPATH is zsh-specific, not needed in fish
# set -gx FPATH /usr/share/zsh/site-functions:/usr/share/zsh/5.8.1/functions:$FPATH

# ========== Optional: Make these variables universal (persistent) ==========
# If you want these to persist across all fish sessions, use set -Ux instead:
# set -Ux EDITOR /usr/bin/nvim
# set -Ux TERM xterm-256color

# ========== Source LLM configurations ==========
if test -f ~/.config/fish/llm.fish
    source ~/.config/fish/llm.fish
end
