if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions fast-syntax-highlighting)

# Must be set before oh-my-zsh runs compinit
fpath=(~/.zsh/completions $fpath)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR=nvim
# $(tty) returns "not a tty" under p10k instant prompt, $TTY is set by zsh itself
export GPG_TTY=$TTY

# Homebrew lives in a different prefix on Apple Silicon, Intel macs and Linux
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $brew ]] && eval "$($brew shellenv)" && break
done
unset brew

case $OSTYPE in
  darwin*) source ~/.zsh/os/darwin.sh ;;
  linux*) source ~/.zsh/os/linux.sh ;;
esac

export VOLTA_HOME="$HOME/.volta"
export BUN_INSTALL="$HOME/.bun"
export GODOT="$HOME/.config/godotenv/godot/bin/godot"

# (N-/) skips directories that don't exist on this machine, -U removes duplicates
typeset -U path
path=(
  $HOME/.opencode/bin(N-/)
  $BUN_INSTALL/bin(N-/)
  $PNPM_HOME(N-/)
  $path
  $HOME/.local/bin(N-/)
  $HOME/.local/bin/spark/bin(N-/)
  $VOLTA_HOME/bin(N-/)
  $HOME/.dotnet/tools(N-/)
  $HOME/go/bin(N-/)
  $HOME/.config/godotenv/godot/bin(N-/)
)

alias editrc='cd ~/dotfiles && nvim && source ~/.zshrc'

for config (~/.zsh/*.sh(N)) source $config
for project (~/.zsh/projects/*.sh(N)) source $project

# Settings for this machine only, not tracked in the dotfiles
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[ng] )) && source <(ng completion script)
[[ -s "$HOME/.oh-my-zsh/completions/_bun" ]] && source "$HOME/.oh-my-zsh/completions/_bun"

if [ -z "$TMUX" ] && (( $+commands[tmux] ))
  then
  tmux attach -t main || tmux new -s main
fi

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/julien/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/julien/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/julien/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/julien/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# zoxide must be initialized last, after anything else that sets up shell hooks
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
