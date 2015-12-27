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

# Dircolors
eval "`dircolors`"

# Search in history
# ...using the arrow keys
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
# ...using CTRL+P/N
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# Unlimit number of processes
ulimit -s unlimited

#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Source global aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
# Source global functions
if [ -d $HOME/.bash_functions ]; then
  for file in $HOME/.bash_functions/*.sh; do . $file; done
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
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Ruby Version Manager
if [[ -e $HOME/.rvm/scripts/rvm ]]; then
  source "$HOME/.rvm/scripts/rvm"
fi

#-----------------------------------------------------------------------------#
# Git Exports
# Replaced by ~/.gitconfig.local :
# [user]
#   name  = Matthias Thubauville
#   email = matthias.thubo@gmail.com
export GIT_AUTHOR_NAME="Matthias Thubauville"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"

#-----------------------------------------------------------------------------#
# HG Prompt
# hg_ps1() {
#   #hg prompt "{ on {branch}}{ at {bookmark}} {>>{status}}{update} {in:[+{incoming|count}]} {out:[+{outgoing|count}]}" 2> /dev/null
#   hg prompt "{ [hg] on {branch}}{ at {bookmark}} {>>{status}}{update}" 2> /dev/null
# }

#-----------------------------------------------------------------------------#
# Git Prompt
export GIT_PROMPT=1
function toggle_git_prompt () {
if [[ $GIT_PROMPT == 1 ]]; then
  GIT_PROMPT=0
  echo "git prompt is disabled!"
else
  GIT_PROMPT=1
  echo "git prompt is enabled!"
fi
}

# function git_color {
#   local git_status="$(git status 2> /dev/null)"
#
#   if [[ ! $git_status =~ "working directory clean" ]]; then
#     echo -e $COLOR_RED
#   elif [[ $git_status =~ "Your branch is ahead of" ]]; then
#     echo -e $COLOR_YELLOW
#   elif [[ $git_status =~ "nothing to commit" ]]; then
#     echo -e $COLOR_GREEN
#   else
#     echo -e $COLOR_OCHRE
#   fi
# }

function git_modified {
  if [[ $GIT_PROMPT == 0 ]]; then
    exit 0
  fi

  local global_modified="$(git status -s 2>/dev/null | wc -l)"

  if [[ $global_modified -gt 0 ]]; then
    echo " !"
  fi
}

function git_branch {
  if [[ $GIT_PROMPT == 0 ]]; then
    exit 0
  fi

  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo " [git] on $branch"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo " [git] at ($commit)"
  fi
}

function git_numbers {
  if [[ $GIT_PROMPT == 0 ]]; then
    exit 0
  fi

  local untracked="$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)"
  local modified="$(git ls-files -m 2>/dev/null | wc -l)"
  local staged="$(git diff --name-only --cached 2>/dev/null | wc -l)"

  if [[ $untracked -gt 0 ]]; then
    echo -n " ?$untracked"
  fi
  if [[ $modified -gt 0 ]]; then
    echo -n " >$modified"
  fi
  if [[ $staged -gt 0 ]]; then
    echo -n " ^$staged"
  fi
}

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
# Toggle prompt
# The simpler prompt has no newline and no mercurial information,
# this makes it easier to copy&paste code for example to store it wordpress
# Default is the non-simple mode:
export SIMPLE_PROMPT=0
# Switch between modes: Since the set_prompt command is called everytime a
# prompt is printed, the changes is instantaneous.
function toggle_prompt () {
 if [[ $SIMPLE_PROMPT == 0 ]]; then
   SIMPLE_PROMPT=1
 else
   SIMPLE_PROMPT=0
 fi
 toggle_git_prompt
}

#-----------------------------------------------------------------------------#
# Reload my bashrc
function reload_bashrc () {
  source ~/.bashrc
  let TIER--
}

#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Colors & Prompt
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
# Function to set the Window title
setxtermWindowTitle()
{
  echo -ne '\033]2;'$*'\007'
}
setscreenWindowTitle()
{
  echo -ne '\033k'$*'\033\\'
}
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

  # Set terminal title to current user@host:/path
  # WINDOW_TITLE="${USER%%.*}@${HOSTNAME%%.*}:${PWD/$HOME/~}"
  WINDOW_TITLE="${USER%%.*}@${HOSTNAME%%.*}"
  case $TERM in
    xterm* )
        setxtermWindowTitle "$WINDOW_TITLE"
      ;;
    screen* )
        setscreenWindowTitle "$WINDOW_TITLE"
      ;;
  esac
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
# Warning
echo -e "\e[1;31m >> You are root << \e[0m"

#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
