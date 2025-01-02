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
   export EDITOR='vim'
 else
   export EDITOR='nvim'
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
. $HOME/.omnimedrc 2> /dev/null
PATH=$PATH:~/Applications/Scripts
# Setting java-11 as default
#export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
#export PATH=$JAVA_HOME/jre/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HISTTIMEFORMAT="%Y-%m-%d %T "
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Load Angular CLI autocompletion.
#source <(ng completion script)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
