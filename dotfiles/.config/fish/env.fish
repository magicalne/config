# General environment variables shared across macOS and Linux

set -gx GOPATH $HOME/go
set -gx TERM xterm-256color
set -gx EDITOR nvim

for path in \
    $HOME/cli/bin \
    $HOME/.bun/bin \
    $HOME/.local/bin \
    $HOME/.cargo/bin \
    $GOPATH/bin
    if test -d $path
        fish_add_path $path
    end
end

switch (uname)
    case Darwin
        for path in /opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/binutils/bin
            if test -d $path
                fish_add_path $path
            end
        end
    case Linux
        if test -x /home/linuxbrew/.linuxbrew/bin/brew
            eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        end

        if test -d /usr/lib64/gio/modules
            set -gx GIO_EXTRA_MODULES /usr/lib64/gio/modules
        end

        if test -d /usr/lib64/pkgconfig
            set -gx PKG_CONFIG_PATH /usr/lib64/pkgconfig
        end
end

if test -f ~/.config/fish/llm.fish
    source ~/.config/fish/llm.fish
end
