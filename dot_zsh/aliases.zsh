### Python / Python 3
alias python="python3"
alias pip="pip3"

### Utils
alias editrc="nvim ~/.zshrc && source ~/.zshrc"
alias gitamend="git add -A && git commit --amend && git push --force-with-lease"
alias cl="clear"
alias k='kubectl'
alias kubefwd='sudo kubefwd svc -c ~/.kube/config'

### Terraform
alias tf='terraform'
alias tfd='terraform destroy --auto-approve'
alias tfa='terraform apply --auto-approve'
alias tfr='terraform refresh'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfw='terraform workspace'

# Neovim
alias n='nvim'
alias editnvim='cd ~/.config/nvim && n'

### Misc
alias tlr='teller'
