# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022
# umask 077

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes further directories
for dir in \
  "$HOME/.bin" \
  "$HOME/.rvm/bin"
do
  if [ -d $dir ] ; then
    export PATH=$PATH:$dir
  fi
done

# export further variables
for exp in \
  "EDITOR=vim"
do
  export $exp
done

export FLEETCTL_ENDPOINT=http://172.17.8.101:4001
export KUBERNETES_MASTER=http://172.17.8.101:8080

