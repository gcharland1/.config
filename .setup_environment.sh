#!/bin/bash
# Make sure all required packages are installed
required_packages=(
    "nvim"
    "tmux"
    "zsh"
)
sudo apt update
sudo apt install "${required_package[*]}"

# Install lazygit from github
if ! command -v lazygit &> /dev/null; then
    echo Installing lazygit from github repo

    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit.tar.gz
    rm -r lazigit
else
    echo LazyGit already installed to version: \r $(lazygit --version)
fi

# Create symlink to .zshrc
ln -s ~/.config/.zshrc ~/.zshrc
