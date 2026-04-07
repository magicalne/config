[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export GOPATH="$HOME/go"
export TERM="${TERM:-xterm-256color}"
export EDITOR="${EDITOR:-nvim}"

prepend_path() {
  [ -d "$1" ] && PATH="$1:$PATH"
}

prepend_path "$HOME/cli/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.bun/bin"
prepend_path "$HOME/.cargo/bin"
prepend_path "$GOPATH/bin"

case "$(uname -s)" in
  Darwin)
    prepend_path /opt/homebrew/bin
    prepend_path /opt/homebrew/sbin
    prepend_path /opt/homebrew/opt/binutils/bin
    ;;
  Linux)
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    [ -d /usr/lib64/gio/modules ] && export GIO_EXTRA_MODULES=/usr/lib64/gio/modules
    [ -d /usr/lib64/pkgconfig ] && export PKG_CONFIG_PATH=/usr/lib64/pkgconfig

    if command -v xclip >/dev/null 2>&1; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
    ;;
esac

export PATH

alias sudo='sudo '
alias vim='nvim'

if command -v eza >/dev/null 2>&1 && ! command -v exa >/dev/null 2>&1; then
  alias exa='eza'
fi

if command -v exa >/dev/null 2>&1; then
  alias ls='exa'
  alias ll='exa -l'
else
  alias ll='ls -la'
fi

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
