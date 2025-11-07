#!/bin/bash
# Make sure all required packages are installed
required_packages=(
    "alacritty"
    "fonts-font-awesome"
    "fzf"
    "i3"
    "i3-wm"
    "i3lock"
    "i3status"
    "flameshot"
    "pavucontrol"
    "tmux"
    "vim-gtk3"
)

echo  "Installing the following packages: ${required_packages[@]}"
sudo apt update

echo "################## APT INSTALL ###########################"
sudo apt install "${required_packages[@]}"

# Snap applications
echo "################## SNAP INSTALL ###########################"
sudo snap install spotify

#TODO: Installer et configurer nvim
symlink ~/.config/vim/.vimrc ~/.vimrc

# Install lazygit from github
if ! command -v lazygit &> /dev/null; then
    echo Installing lazygit from github repo

    cd ~/
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit.tar.gz
    rm -r lazigit
else
    echo LazyGit already installed to version: \r $(lazygit --version)
fi

# Install oh-my-zsh and configure
sudo apt install zsh-syntax-highlighting zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
ln -s ~/.oh-my-zsh ~/.config/oh-my-zsh

if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
    rm ~/.zhrc
    mv ~/.zshrc.pre-oh-my-szh ~/.zshrc
fi

# Create symlink to .zshrc
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.bak
fi
ln -s ~/.config/.zshrc ~/.zshrc

# Setup alacritty as default terminal
sudo update-alternatives --config x-terminal-emulator

# Symlink to global gitignore config
ln -s ~/.config/.gitignore_global ~/.gitignore_global
