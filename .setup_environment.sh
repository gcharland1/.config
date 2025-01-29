#!/bin/bash
# Make sure all required packages are installed
required_packages=(
    "fonts-font-awesome"
    "i3"
    "i3-wm"
    "i3lock"
    "i3status"
    "pavucontrol"
    "tmux"
    "xterm"
    "zsh"
)

echo  "Installing the following packages: ${required_packages[@]}"
sudo apt update
sudo apt install "${required_package[@]}"

# Snap applications
sudo snap install spotify

#TODO: Installer et configurer nvim

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
sudo apt install zsh-autosuggestions zsh-syntax-highlighting zsh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# Setup urxvt as default terminal
sudo update-alternatives --config x-terminal-emulator
