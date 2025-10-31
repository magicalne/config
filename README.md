# My ultimate configs

- alacritty
- ghostty
- zsh
- tmux
- nvim
- [startship](https://starship.rs/)

## bins

### github
- rust-analyzer

### packages
- llvm*

### cargo
- alacritty
- ripgrep
- proximity-sort 
- exa
- fd-find

### pip
- pyright
- ruff

### fonts

Need [nerd fonts](https://www.nerdfonts.com/font-downloads)

Other amazing fonts:

- [monego](https://github.com/cseelus/monego)

## startship

### Install

```shell
curl -sS https://starship.rs/install.sh | sh
```

Find more themes: https://starship.rs/presets/

## tmux plugin init

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## tabby

Say goodbye to Copilot.

### Install nvidia container toolkit

```sh
sudo dnf install -y nvidia-container-toolkit
```

### Generate profile with nvidia-ctk

```sh
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
nvidia-ctk cdi list ## check generated profile
```

### Run with docker

```sh
podman run -it --gpus all \
  -p 8080:8080 -v $HOME/ssd/apps/.tabby:/data \
  tabbyml/tabby serve --model StarCoder-1B --device cuda --no-webserver
```



## Ghostty

- https://github.com/sahaj-b/ghostty-cursor-shaders
