# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.config/oh-my-zsh"
#
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="simple"
ZSH_THEME="eastwood"

plugins=(
    git
    zsh-autosuggestions
    sudo
)
source $ZSH/oh-my-zsh.sh
#
# Setting java-11 as default
export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
export PATH=$JAVA_HOME/jre/bin:$PATH

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='mvim'
 fi

# Source personnal aliases
source ~/.config/my_aliases
