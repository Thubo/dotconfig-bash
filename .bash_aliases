# Make sure .pwd file exists
if [[ ! -f ~/.pwd ]]; then
  touch ~/.pwd
fi

# Make some possibly destructive commands more interactive.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Add some easy shortcuts for formatted directory listings and add a touch of color.
alias ll='ls -lhF --color=auto'
alias lm='ls -lhF --color=auto | more'
alias lt='ls -lhFtr --color=auto'
alias la='ls -AhlF --color=auto'
alias lA='ls -Ahld --color=auto .?*'
alias lh='ls -AhlF --color=auto -d .*'
alias lam='ls -AhlF --color=auto | more'
alias ls='ls -F'
alias l='ls -CF'

# Make grep more user friendly by highlighting matches
# and exclude grepping through .svn folders.
alias grep='grep --color=auto --exclude-dir=\.svn'
alias vi='vim'

# Nice Stuff
alias ..='cd ..'
alias ...='cd ../..'
alias c="tr -d '\n' | xclip -selection p"
alias cc="xclip -selection c"
alias p="xclip -o -selection p"
alias pp="xclip -o -selection c"
alias awknf="awk '{print \$NF}'"
alias awknf2="awk '{print \$(NF-2)}'"
alias swd="echo $(pwd) > ~/.pwd"
alias goto="cd $(cat ~/.pwd)"
alias root="sudo su -"
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias dist-upgrade="sudo apt-get -qqq update; sudo apt-get -y dist-upgrade; alert"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Ugly Stuff
alias cssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Mercurial
alias hgb='hg bookmark'
alias hgc='hg crecord'
alias hgh='hg help'
alias hgi='hg incoming -gn --stat -p'
alias hgo='hg outgoing -gn --stat -p'
alias hgp='grep "default" .hg/hgrc'
alias hgs='hg status'
alias hgv='hg view'

# Programms
alias irssi='screen -S irssi -xR irssi'
alias mrj='mr -j10'

# Source any file in $HOME/.bash_aliases.d/
if [ -d $HOME/.bash_aliases.d ]; then
    for file in $HOME/.bash_aliases.d/*; do . $file; done
fi