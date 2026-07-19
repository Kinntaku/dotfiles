# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=0
HISTFILESIZE=0
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kinntaku/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/usr/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/kinntaku/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# starship
if [[ "$TERM" != "linux" ]]; then
    source <(starship init zsh)
fi

export PATH="$PATH:/home/kinntaku/.cargo/bin"

export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock
export NAVI_PATH="$DOTFILES/navi"

alias prime-run='__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia '
alias nv='print -z $(navi --print)'
alias ls='eza --icons=always'
alias tree='eza --icons=always --tree'
alias vi="nvim"
alias ff=fastfetch
alias conda='micromamba'
alias docker='podman'
alias snvim='sudo -E nvim'
