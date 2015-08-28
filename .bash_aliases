# Make sure .pwd file exists
if [[ ! -f ~/.pwd ]]; then
  touch ~/.pwd
fi

# Make some possibly destructive commands more interactive.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias cpr='cp -i -r'

# Add some easy shortcuts for formatted directory listings and add a touch of color.
alias la='ls -AhlF --color=auto'
alias lam='ls -AhlF --color=auto | more'
alias lh='ls -Ahld --color=auto .?*'
alias lhm='ls -Ahld --color=auto .?* | more'
alias ll='ls -lhF --color=auto'
alias llm='ls -lhF --color=auto | more'
alias ls='ls -CF --color=auto'
alias lt='ls -lhFtr --color=auto'

# Make grep more user friendly by highlighting matches
# and exclude grepping through .svn folders.
alias grep='grep --color=auto --exclude-dir=\.svn --exclude-dir=\.git'
alias fgrep='fgrep --color=auto --exclude-dir=\.svn --exclude-dir=\.git'
alias egrep='egrep --color=auto --exclude-dir=\.svn --exclude-dir=\.git'

# Software
alias vi='vim'
alias tmux='tmux -2'
alias view='vim -R'
alias g='git'
alias myscreen='screen -RR $USER'
alias gitconfig='vim $HOME/.gitconfig'
alias enw='emacs -nw'

# Nice Stuff
alias ..='cd ..'
alias ...='cd ../..'
alias c="tr -d '\n' | xclip -selection p"
alias cc="xclip -selection c"
alias p="xclip -o -selection p"
alias pp="xclip -o -selection c"
alias awknf="awk '{print \$NF}'"
alias bsource="source ~/.bashrc"
alias swd="echo $(pwd) > ~/.pwd"
alias goto="cd $(cat ~/.pwd)"
alias root="sudo -i"
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias dus='du * -sh | sort -h'
alias das='find . -maxdepth 1 -name ".?*" | xargs du -sch | sort -h'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Ugly Stuff
alias cssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Mercurial
# alias hgb='hg bookmark'
# alias hgc='hg crecord'
# alias hgh='hg help'
# alias hgi='hg incoming -gn --stat -p'
# alias hgo='hg outgoing -gn --stat -p'
# alias hgp='grep "default" .hg/hgrc'
# alias hgs='hg status'
# alias hgv='hg view'

# Programms
alias irssi='screen -S irssi -xR irssi'
alias mrj='mr -j10'

