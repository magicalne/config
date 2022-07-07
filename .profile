
. "$HOME/.cargo/env"
export PATH=$HOME/cli/bin:$HOME/.local/bin:$PATH
export GOPATH=$HOME/go
export GIO_EXTRA_MODULES=/usr/lib64/gio/modules/
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
export http_proxy=socks5://192.168.2.1:23456
export https_proxy=socks5://192.168.2.1:23456

export FPATH=/usr/share/zsh/site-functions:/usr/share/zsh/5.8.1/functions:$FPATH
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export TERM=xterm-256color

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias kk='/home/magicalne/ssd/git/nervos/godwoken-kicker/kicker'
alias sudo='sudo '
alias vim='nvim'
