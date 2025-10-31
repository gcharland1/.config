# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.config/oh-my-zsh"
#
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="simple"
ZSH_THEME="eastwood"

# Enable auto-corrections
ENABLE_CORRECTION="true"

plugins=(
    git
    npm
    zsh-autosuggestions
    shrink-path
    sudo
    poetry
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    # TODO: Remplacer par nvim quand c'est configuré
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

# Source omnimed aliases (if available)
if [ -f ~/.bash_aliases_omnimed ]; then
    . ~/.bash_aliases_omnimed
fi

# Source personnal aliases
if [ -f ~/.config/my_aliases ]; then
    . ~/.config/my_aliases
fi

# Environment variables settés depuis omnimedrc
eval "$(direnv hook zsh)"

. $HOME/.omnimedrc 2> /dev/null
PATH=$PATH:/home/devjava/Applications/Scripts

# Setting java-11 as default
export JAVA_HOME=$(find /usr/lib/jvm -maxdepth 3 -type d -name "*jdk-11*" -print -quit | sed 's/\/bin.*//g')
export PATH=$JAVA_HOME/bin:$PATH

export HIST_STAMPS="%Y-%m-%d %T "
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
PATH=$PATH:~/Applications/Scripts
export HISTTIMEFORMAT="%Y-%m-%d %T "
