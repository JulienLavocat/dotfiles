if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR=nvim

export VOLTA_HOME="$HOME/.volta"

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin/spark/bin"
export PATH="$VOLTA_HOME/bin:$PATH"

alias cd='z'
alias editrc='nvim ~/.zshrc && source ~/.zshrc'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(zoxide init zsh)" 

source <(fzf --zsh)

for config (~/.zsh/*.zsh) source $config

if [ -z "$TMUX" ]
  then
  tmux attach -t main || tmux new -s main
fi

