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
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/go/bin"
export PATH="/home/julien/.config/godotenv/godot/bin:$PATH"

export GODOT="/home/julien/.config/godotenv/godot/bin/godot"

alias cd='z'
alias editrc='cd ~/dotfiles && nvim && source ~/.zshrc'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(zoxide init zsh)" 

source <(fzf --zsh)

for config (~/.zsh/*.sh) source $config
for project (~/.zsh/projects/*.sh) source $project

if [ -z "$TMUX" ]
  then
  tmux attach -t main || tmux new -s main
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/julien/.sdkman"
[[ -s "/Users/julien/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/julien/.sdkman/bin/sdkman-init.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/julien/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/julien/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/julien/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/julien/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# pnpm
export PNPM_HOME="/home/julien/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
