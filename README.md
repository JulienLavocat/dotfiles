# Dotfiles

## Create and add an SSH key to Github

1. Run: `ssh-keygen -t ed25519 -C "<email>"`
2. Copy the public key: `cat ~/.ssh/id_ed25519.pub`
3. Add it to Github: https://github.com/settings/keys

## Setup

### 1. Homebrew / Linuxbrew

Source: https://brew.sh/
- Run: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### 2. Stow

1. Install stow: `brew install stow`
2. Clone the dotfiles: `git clone git@github.com:JulienLavocat/dotfiles.git`
3. Setup the dotfiles (**must be ran inside the dotfiles directory**): `stow . -v`

### 3. Zsh / Oh-My-Zsh / Powerlevel10k

Source: https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df
1. Install Zsh and set it as default shell for the user: `brew install zsh && command -v zsh | sudo tee -a /etc/shells && chsh -s $(which zsh)`
2. Logout and log back in
3. Install Oh-My-Zsh: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
2. Install zsh-autosuggestions: `git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions`
3. Install zsh-syntax-highlighting: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting`
4. Install fast-syntax-highlighting: `git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting`
5. Install Powerlevel10k: `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k`

### 4. Install Alacritty

Version >=0.13 is required and can be hard to find, snap has an updated version => https://snapcraft.io/alacritty
- Run: `snap install alacritty --classic`

### 5. Zoxide

- Run: `brew install zoxide`

### 6. Tmux

- Run: `brew install tmux`

### 5. Install Neovim

- Install Neovim and it's required dependencies: `brew install lazygit neovim ripgrep fzf gcc volta`

### 6. End steps

1. Logout from the user and log back in
2. Run Alacritty
