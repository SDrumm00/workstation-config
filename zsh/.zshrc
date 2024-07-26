# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/scott/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#  Add 256 color support in terminal
export TERM="xterm-256color"

# Enable powerlevel9k ttheme
source /usr/share/powerlevel9k/powerlevel9k.zsh-theme
