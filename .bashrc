# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    # alias dir='dir --color=auto'
    # alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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

# Unlimit number of processes
ulimit -s unlimited

# Make tab-completion behave sort of zsh-like
# bind 'TAB:menu-complete'

#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# lc: Convert the parameters or STDIN to lowercase.
lc()
{
  if [ $# -eq 0 ]; then
    tr '[:upper:]' '[:lower:]'
  else
    tr '[:upper:]' '[:lower:]' <<< "$@"
  fi
}

#-----------------------------------------------------------------------------#
# uc: Convert the parameters or STDIN to uppercase.
uc()
{
  if [ $# -eq 0 ]; then
    tr '[:lower:]' '[:upper:]'
  else
    tr '[:lower:]' '[:upper:]' <<< "$@"
  fi
}

#-----------------------------------------------------------------------------#
# wtfis: Show what a given command really is. It is a combination of "type", "file"
# and "ls". Unlike "which", it does not only take $PATH into account. This
# means it works for aliases and hashes, too. (The name "whatis" was taken,
# and I did not want to overwrite "which", hence "wtfis".)
# The return value is the result of "type" for the last command specified.
#
# usage:
#
#   wtfis man
#   wtfis vi
#
# source: https://raw.githubusercontent.com/janmoesen/tilde/master/.bash/commands
wtfis()
{
  local cmd=""
  local type_tmp=""
  local type_command=""
  local i=1
  local ret=0

  if [ -n "$BASH_VERSION" ]; then
    type_command="type -p"
  else
    type_command=( whence -p ) # changes variable type as well
  fi

  if [ $# -eq 0 ]; then
    # Use "fc" to get the last command, and use that when no command
    # was given as a parameter to "wtfis".
    set -- $(fc -nl -1)

    while [ $# -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do
      # Ignore "sudo" and options ("-x" or "--bla").
      shift
    done

    # Replace the positional parameter array with the last command name.
    set -- "$1"
  fi

  for cmd; do
    type_tmp="$(type "$cmd")"
    ret=$?

    if [ $ret -eq 0 ]; then
      # Try to get the physical path. This works for hashes and
      # "normal" binaries.
      local path_tmp=$(${type_command} "$cmd" 2> /dev/null)

      if (( ? )) || ! test -x $path_tmp; then
        # Show the output from "type" without ANSI escapes.
        echo "${type_tmp//$'\e'/\\033}"

        case "$(command -v "$cmd")" in
          'alias')
            local alias_="$(alias "$cmd")"

            # The output looks like "alias foo='bar'" so
            # strip everything except the body.
            alias_="${alias_#*\'}"
            alias_="${alias_%\'}"

            # Use "read" to process escapes. E.g. 'test\ it'
            # will # be read as 'test it'. This allows for
            # spaces inside command names.
            read -d ' ' alias_ <<< "$alias_"

            # Recurse and indent the output.
            # TODO: prevent infinite recursion
            wtfis "$alias_" 2>&2 | sed 's/^/  /'

            ;;
          'keyword' | 'builtin')

            # Get the one-line description from the built-in
            # help, if available. Note that this does not
            # guarantee anything useful, though. Look at the
            # output for "help set", for instance.
            help "$cmd" 2> /dev/null | {
              local buf line
              read -r line
              while read -r line; do
                buf="$buf${line/.  */.} "
                if [[ "$buf" =~ \.\ $ ]]; then
                  echo "$buf"
                  break
                fi
              done
            }

            ;;
        esac
      else
        # For physical paths, get some more info.
        # First, get the one-line description from the man page.
        # ("col -b" gets rid of the backspaces used by OS X's man
        # to get a "bold" font.)
        (COLUMNS=10000 man "$(basename "$path_tmp")" 2>/dev/null) | col -b | \
        awk '/^NAME$/,/^$/' | {
          local buf=""
          local line=""

          read -r line
          while read -r line; do
            buf="$buf${line/.  */.} "
            if [[ "$buf" =~ \.\ $ ]]; then
              echo "$buf"
              buf=''
              break
            fi
          done

          [ -n "$buf" ] && echo "$buf"
        }

        # Get the absolute path for the binary.
        local full_path_tmp="$(
          cd "$(dirname "$path_tmp")" \
            && echo "$PWD/$(basename "$path_tmp")" \
            || echo "$path_tmp"
        )"

        # Then, combine the output of "type" and "file".
        local fileinfo="$(file "$full_path_tmp")"
        echo "${type_tmp%$path_tmp}${fileinfo}"

        # Finally, show it using "ls" and highlight the path.
        # If the path is a symlink, keep going until we find the
        # final destination. (This assumes there are no circular
        # references.)
        local paths_tmp=("$path_tmp")
        local target_path_tmp="$path_tmp"

        while [ -L "$target_path_tmp" ]; do
          target_path_tmp="$(readlink "$target_path_tmp")"
          paths_tmp+=("$(
            # Do some relative path resolving for systems
            # without readlink --canonicalize.
            cd "$(dirname "$path_tmp")"
            cd "$(dirname "$target_path_tmp")"
            echo "$PWD/$(basename "$target_path_tmp")"
          )")
        done

        local ls="$(command ls -fdalF "${paths_tmp[@]}")"
        echo "${ls/$path_tmp/$'\e[7m'${path_tmp}$'\e[27m'}"
      fi
    fi

    # Separate the output for all but the last command with blank lines.
    [ $i -lt $# ] && echo
    let i++
  done

  return $ret
}

#-----------------------------------------------------------------------------#
# whenis: Try to make sense of the date. It supports everything GNU date knows how to
# parse, as well as UNIX timestamps. It formats the given date using the
# default GNU date format, which you can override using "--format='%x %y %z'.
#
# usage:
#
#   $ whenis 1234567890            # UNIX timestamps
#   Sat Feb 14 00:31:30 CET 2009
#
#   $ whenis +1 year -3 months     # relative dates
#   Fri Jul 20 21:51:27 CEST 2012
#
#   $ whenis 2011-10-09 08:07:06   # MySQL DATETIME strings
#   Sun Oct  9 08:07:06 CEST 2011
#
#   $ whenis 1979-10-14T12:00:00.001-04:00 # HTML5 global date and time
#   Sun Oct 14 17:00:00 CET 1979
#
#   $ TZ=America/Vancouver whenis # Current time in Vancouver
#   Thu Oct 20 13:04:20 PDT 2011
#
# For more info, check out http://kak.be/gnudateformats.
whenis()
{
  # Default GNU date format as seen in date.c from GNU coreutils.
  local format='%a %b %e %H:%M:%S %Z %Y'
  if [[ "$1" =~ ^--format= ]]; then
    format="${1#--format=}"
    shift
  fi

  # Concatenate all arguments as one string specifying the date.
  local date="$*"
  if [[ "$date"  =~ ^[[:space:]]*$ ]]; then
    date='now'
  elif [[ "$date"  =~ ^[0-9]{13}$ ]]; then
    # Cut the microseconds part.
    date="${date:0:10}"
  fi

  # Use GNU date in all other situations.
  [[ "$date" =~ ^[0-9]+$ ]] && date="@$date"
  date -d "$date" +"$format"
}

#-----------------------------------------------------------------------------#
# testConnection: check if connection to google.com is possible
#
# usage:
#   testConnection 1  # will echo 1 || 0
#   testConnection    # will return 1 || 0
testConnection()
{
  local tmpReturn=1
  $(wget --tries=2 --timeout=2 www.google.com -qO- &>/dev/null 2>&1)

  if [ $? -eq 0 ]; then
    tmpReturn=0
  else
    tmpReturn=1
  fi

  if [ "$1" ] && [ $1 -eq 1 ]; then
    echo $tmpReturn
  else
    return $tmpReturn
  fi
}

#-----------------------------------------------------------------------------#
# netstat_used_local_ports: get used tcp-ports
netstat_used_local_ports()
{
  netstat -atn \
    | awk '{printf "%s\n", $4}' \
    | grep -oE '[0-9]*$' \
    | sort -n \
    | uniq
}


#-----------------------------------------------------------------------------#
# netstat_free_local_port: get one free tcp-port
netstat_free_local_port()
{
  # didn't work with zsh / bash is ok
  #read lowerPort upperPort < /proc/sys/net/ipv4/ip_local_port_range

  for port in $(seq 32768 61000); do
    for i in $(netstat_used_local_ports); do
      if [[ $used_port -eq $port ]]; then
        continue
      else
        echo $port
        return 0
      fi
    done
  done

  return 1
}

#-----------------------------------------------------------------------------#
# connection_overview: get stats-overview about your connections
netstat_connection_overview()
{
  netstat -nat \
    | awk '{print $6}' \
    | sort \
    | uniq -c \
    | sort -n
}

#-----------------------------------------------------------------------------#
# nice mount (http://catonmat.net/blog/another-ten-one-liners-from-commandlingfu-explained)
#
# displays mounted drive information in a nicely formatted manner
mount_info()
{
  (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2="";1') \
    | column -t;
}

#-----------------------------------------------------------------------------#
# extract: extract of compressed-files
extract()
{
  if [ -f $1 ] ; then
    local lower=$(lc $1)

    case $lower in
      *.tar.bz2)   tar xvjf $1     ;;
      *.tar.gz)    tar xvzf $1     ;;
      *.bz2)       bunzip2 $1      ;;
      *.rar)       unrar e $1      ;;
      *.gz)        gunzip $1       ;;
      *.tar)       tar xvf $1      ;;
      *.tbz2)      tar xvjf $1     ;;
      *.tgz)       tar xvzf $1     ;;
      *.lha)       lha e $1        ;;
      *.zip)       unzip $1        ;;
      *.Z)         uncompress $1   ;;
      *.7z)        7z x $1         ;;
      *)           echo "'$1' cannot be extracted via >extract<"
                   return 1        ;;
    esac

  else
    echo "'$1' is not a valid file"
  fi
}

#-----------------------------------------------------------------------------#
# givedef: shell function to define words
# http://vikros.tumblr.com/post/23750050330/cute-little-function-time
givedef()
{
  if [ $# -ge 2 ]; then
    echo "givedef: too many arguments" >&2
    return 1
  else
    curl --silent "dict://dict.org/d:$1"
  fi
}

#-----------------------------------------------------------------------------#
# calc: Simple calculator
# usage: e.g.: 3+3 || 6*6/2
calc()
{
  local result=""
  result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
  #                       └─ default (when `--mathlib` is used) is 20
  #
  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    printf "$result" |
    sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
        -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
        -e 's/0*$//;s/\.$//'   # remove trailing zeros
  else
    printf "$result"
  fi
  printf "\n"
}

#-----------------------------------------------------------------------------#
# mkd: Create a new directory and enter it
mkd()
{
  mkdir -p "$@" && cd "$_"
}

#-----------------------------------------------------------------------------#
# fs: Determine size of a file or total size of a directory
fs()
{
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* *
  fi
}

#-----------------------------------------------------------------------------#
# server: Start an HTTP server from a directory, optionally specifying the port
server()
{
  local free_port=$(netstat_free_local_port)
  local port="${1:-${free_port}}"
  sleep 1 && o "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

#-----------------------------------------------------------------------------#
# tail with search highlight
#
# usage: t /var/log/Xorg.0.log [kHz]
t()
{
  if [ $# -eq 0 ]; then
    echo "Usage: t /var/log/Xorg.0.log [kHz]"
    return 1
  else
    if [ $2 ]; then
      tail -n 50 -f $1 | perl -pe "s/$2/${COLOR_LIGHT_RED}$&${COLOR_NO_COLOUR}/g"
    else
      tail -n 50 -f $1
    fi
  fi
}


#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Ruby Version Manager
if [[ -e $HOME/.rvm/scripts/rvm ]]; then
  source "$HOME/.rvm/scripts/rvm"
fi

# Wine Export
#export WINEARCH=win32
#export WINEPREFIX=~/.win32

#-----------------------------------------------------------------------------#
# Git Exports
# Replaced by ~/.gitconfig.local :
# [user]
#   name  = Matthias Thubauville
#   email = matthias.thubo@gmail.com
# export GIT_AUTHOR_NAME="Matthias Thubauville"
# export GIT_AUTHOR_EMAIL=matthias.thubo@gmail.com
# export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
# export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

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
# Improve prompt
set_prompt ()
{
  Last_Command=$? # Must come first!
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

  # Add a bright white exit status for the last command
  # PS1="$White\$? "
  # # If it was successful, print a green check mark. Otherwise, print
  # # a red X.
  # if [[ $Last_Command == 0 ]]; then
  #   PS1+="$Green$Checkmark "
  # else
  #   PS1+="$Red$FancyX "
  # fi

  # If root, just print the host in red. Otherwise, print the current user
  # and host in green.
  # This does not work well on ubuntu, but on any other distribution, which
  # allow 'su root' this works fine.
  if [[ $EUID == 0 ]]; then
    PS1="${Lightred}\\u@\\h"
    PS1+="${White}:\w"
    PS1+="\n"
    PS1+="${White}\${Last_Command} "
    PS1+="${Lightred}T${TIER}"
    PS1+="${Lightred}# "
    PS1+="${Reset}"
  else
    PS1="${Lightgreen}\\u@\\h"
  fi

  if [[ $SIMPLE_PROMPT == 1 ]]; then
    PS1+="${White}:\w "
    PS1+="${White}# "
    PS1+="${Reset}"
  else
    PS1+="${White}:\w"
    # PS1+=" ${Yellow}\$(hg_ps1)"
    PS1+="${Yellow}$(git_branch)"
    PS1+="${Yellow}$(git_numbers)"
    PS1+="\n"
    PS1+="${White}\${Last_Command} "
    PS1+="${Lightred}T${TIER} "
    PS1+="${White}# "
    PS1+="${Reset}"
  fi

  # Set current path to Terminator title
  if [ "$TERM" == "xterm" ]; then
    setWindowTitle() {
      echo -ne "\e]2;$*\a"
    }
    updateWindowTitle() {
      setWindowTitle "${USER%%.*}@${HOSTNAME%%.*}:${PWD/$HOME/~}"
    }
    updateWindowTitle
  fi

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
