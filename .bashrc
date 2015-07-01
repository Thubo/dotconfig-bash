################################################################################
# .bashrc for root
#
# Author: Matthias Thubauville
#
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
#
################################################################################

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Search in history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#-----------------------------------------------------------------------------#
# Git Exports
# Replaced by ~/.gitconfig.local :
# [user]
#   name  = Matthias Thubauville
#   email = matthias.thubo@gmail.com
export GIT_AUTHOR_NAME="Matthias Thubauville"
export GIT_AUTHOR_EMAIL=matthias.thubo@gmail.com
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"


#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Source global aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
# Source global functions
if [ -f ~/.bash_functions ]; then
  . ~/.bash_functions
fi

#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Source special stuff
# Name the files .alias, .function and .bash to clarify what they do.  Note,
# however that the naming does not change the way they are treated. Make sure
# only you can write in this directory, since it is a way to inject some bad
# code in your environment.
if [ -d $HOME/.bash.d ]; then
  for file in $HOME/.bash.d/*; do . $file; done
fi

#-----------------------------------------------------------------------------#
# Tiering
# Check if TIER is existing, set it to 0 if not
if [[ `export | grep TIER` == "" ]]; then
    export TIER=0
else
    let TIER++
fi
# Trap function to decrement tier on exit
function de_tier {
    let TIER--
}
# The actual trap
trap de_tier EXIT
# Now use $TIER to get the tiering level

#-----------------------------------------------------------------------------#
# Reload my bashrc
function reload_bashrc () {
  source ~/.bashrc
  let TIER--
}

#-----------------------------------------------------------------------------#
# Colors
Black='\[\e[0;30m\]'
Darkgrey='\[\e[1;30m\]'
Lightgrey='\[\e[0;37m\]'
White='\[\e[1;37m\]'
Red='\[\e[0;31m\]'
Lightred='\[\e[1;31m\]'
Green='\[\e[0;32m\]'
Lightgreen='\[\e[1;32m\]'
Brown='\[\e[0;33m\]'
Yellow='\[\e[1;33m\]'
Blue='\[\e[0;34m\]'
Lightblue='\[\e[1;34m\]'
Purple='\[\e[0;35m\]'
Lightpurple='\[\e[1;35m\]'
Cyan='\[\e[0;36m\]'
Lightcyan='\[\e[1;36m\]'
Reset='\[\e[0m\]'
# FancyX='\342\234\227'
# Checkmark='\342\234\223'

#-----------------------------------------------------------------------------#
# Warning
echo -e "\e[1;31m >> You are root << \e[0m"

#-----------------------------------------------------------------------------#
# Improve prompt
set_prompt ()
{
  Last_Command=$? # Must come first!

    PS1="${Lightred}\\u@\\h"
    PS1+="${White}:\w "
    PS1+="\n"
    PS1+="${White}\${Last_Command} "
    PS1+="${Lightred}T${TIER} "
    PS1+="${White}# "
    PS1+="${Reset}"

}
# Sync the history with every new prompy between shells
# export PROMPT_COMMAND='history -a; history -c; history -r; set_prompt'
# 'Normal' history behavior
export PROMPT_COMMAND='set_prompt'
#-----------------------------------------------------------------------------#
# Dynamic 'motd' - not realy a motd, but similar function
if type dynmotd > /dev/null 2>&1 ; then
  dynmotd
fi
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
