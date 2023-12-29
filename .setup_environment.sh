#!/bin/bash
# Make sure all required packages are installed
required_packages=(
    "i3"
    "i3-wm"
    "i3lock"
    "i3status"
    "nvim"
    "tmux"
    "zsh"
)
sudo apt update

echo  "${required_packages[@]}"
sudo apt install ${required_package[*]}

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

if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
    rm ~/.zhrc
    mv ~/.zshrc.pre-oh-my-szh ~/.zshrc
fi

# Create symlink to .zshrc
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.bak
    ln -s ~/.config/.zshrc ~/.zshrc
fi
