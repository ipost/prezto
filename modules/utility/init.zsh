#
# Defines general aliases and functions.
#
# Authors:
#   Robby Russell <robby@planetargon.com>
#   Suraj N. Kurapati <sunaku@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
pmodload 'helper' 'spectrum'

# Correct commands.
setopt CORRECT

#
# Aliases
#

# Disable correction.
alias ack='nocorrect ack'
alias cd='nocorrect cd'
alias cp='nocorrect cp'
alias ebuild='nocorrect ebuild'
alias gcc='nocorrect gcc'
alias gist='nocorrect gist'
alias grep='nocorrect grep'
alias heroku='nocorrect heroku'
alias ln='nocorrect ln'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias rm='nocorrect rm'

# Disable globbing.
alias bower='noglob bower'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

# Define general aliases.
alias _='sudo'
alias b='${(z)BROWSER}'
alias cp="${aliases[cp]:-cp} -i"
alias e='${(z)VISUAL:-${(z)EDITOR}}'
alias ln="${aliases[ln]:-ln} -i"
alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias mv="${aliases[mv]:-mv} -i"
alias p='${(z)PAGER}'
alias po='popd'
alias pu='pushd'
alias rm="${aliases[rm]:-rm} -i"
alias type='type -a'
alias ag=rg

# ls
if is-callable 'dircolors'; then
  # GNU Core Utilities
  alias ls='ls --group-directories-first'

  if zstyle -t ':prezto:module:utility:ls' color; then
    if [[ -s "$HOME/.dir_colors" ]]; then
      eval "$(dircolors --sh "$HOME/.dir_colors")"
    else
      eval "$(dircolors --sh)"
    fi

    alias ls="${aliases[ls]:-ls} --color=auto"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
else
  # BSD Core Utilities
  if zstyle -t ':prezto:module:utility:ls' color; then
    # Define colors for BSD ls.
    export LSCOLORS='exfxcxdxbxGxDxabagacad'

    # Define colors for the completion system.
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

    alias ls="${aliases[ls]:-ls} -G"
  else
    alias ls="${aliases[ls]:-ls} -F"
  fi
fi

alias l='ls -1A'         # Lists in one column, hidden files.
alias ll='ls -lh'        # Lists human readable sizes.
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
alias sl='ls'            # I often screw this up.

# Grep
if zstyle -t ':prezto:module:utility:grep' color; then
  export GREP_COLOR='37;45'           # BSD.
  export GREP_COLORS="mt=$GREP_COLOR" # GNU.

  alias grep="${aliases[grep]:-grep} --color=auto"
fi

# Mac OS X Everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
else
  alias o='xdg-open'

  if (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif (( $+commands[xsel] )); then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

# File Download
if (( $+commands[curl] )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
elif (( $+commands[wget] )); then
  alias get='wget --continue --progress=bar --timestamping'
fi

# Resource Usage
alias df='df -kh'
alias du='du -kh'

if (( $+commands[htop] )); then
  alias top=htop
else
  if [[ "$OSTYPE" == (darwin*|*bsd*) ]]; then
    alias topc='top -o cpu'
    alias topm='top -o vsize'
  else
    alias topc='top -o %CPU'
    alias topm='top -o %MEM'
  fi
fi

# Miscellaneous

# Serves a directory via HTTP.
alias http-serve='python -m SimpleHTTPServer'

#
# Functions
#

# Makes a directory and changes to it.
function mkdcd {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pushes an entry onto the directory stack and lists its contents.
function pushdls {
  builtin pushd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Pops an entry off the directory stack and lists its contents.
function popdls {
  builtin popd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Prints columns 1 2 3 ... n.
function slit {
  awk "{ print ${(j:,:):-\$${^@}} }"
}

# Finds files and executes a command on them.
function find-exec {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}

# open workspace notes
function ws-notes {
  tmux rename-window "notes"
  cd ~/notes
  clear
  tmux split-window -h \; \
  send-keys \
  'cd ~/notes' C-j \
  'vim tasks' C-j \;
}

# open workspace zprezto
function ws-zprezto {
  tmux rename-window "zprezto"
  cd ~/.zprezto
  clear
  tmux split-window -h \; \
  send-keys 'cd ~/.zprezto' C-j \
  "printf '\033]2;%s\033\\' 'vim'" C-j \
  'vim modules/utility/init.zsh modules/git/alias.zsh' C-j \
  ':tab all' C-j \
  \;
}

# open workspace magellan
function ws-magellan {
  tmux rename-window "magellan"
  cd ~/code/magellan
  rvm use $(cat .ruby-version)
  clear
  tmux split-window -h \; \
  send-keys \
  'cd ~/code/magellan' C-j \
  "printf '\033]2;%s\033\\' 'vim'" C-j \
  'vim notes config/routes.rb' C-j \
  ':tab all' C-j\;
}

# open workspace partner-engine
function ws-partner-engine {
  tmux rename-window "partner-engine"
  cd ~/code/partner-engine
  rvm use $(cat .ruby-version)
  clear
  tmux split-window -h \; \
  send-keys \
  'cd ~/code/partner-engine' C-j \
  "printf '\033]2;%s\033\\' 'vim'" C-j \
  'vim notes config/routes.rb' C-j \
  ':tab all' C-j\;
}

# start BP microservices
# sleeps ensure apps boot in correct order
function start-services {
  tmux rename-window "services"
  tmux splitw -v
  tmux select-pane -U
  tmux send-keys \
  "printf '\033]2;%s\033\\' 'authenticator'" C-j \
  'cd ~/code/authenticator' C-j \
  'rvm use $(cat .ruby-version)' C-j \
  'bin/server' C-j \
  \;
  tmux splitw -h -p 33
  tmux send-keys \
  "printf '\033]2;%s\033\\' 'partner engine'" C-j \
  'cd ~/code/partner-engine' C-j \
  'rvm use $(cat .ruby-version)' C-j \
  'sleep 3' C-j \
  'bin/server' C-j \
  \;
  tmux select-pane -L
  tmux splitw -h -p 50
  tmux send-keys \
  "printf '\033]2;%s\033\\' 'rules engine'" C-j \
  'cd ~/code/rules-engine' C-j \
  'rvm use $(cat .ruby-version)' C-j \
  'sleep 6' C-j \
  'bin/server' C-j \
  \;
  tmux select-pane -D
  tmux send-keys \
  "printf '\033]2;%s\033\\' 'carrier engine'" C-j \
  'cd ~/code/carrier-engine' C-j \
  'rvm use $(cat .ruby-version)' C-j \
  'bin/server' C-j \
  \;
#   tmux splitw -h -p 33
#   tmux send-keys \
#   "printf '\033]2;%s\033\\' 'pqi'" C-j \
#   'cd ~/code/pqi' C-j \
#   'nvm use 10' C-j \
#   'ng serve' C-j \
#   \;
#   tmux select-pane -L
#   tmux splitw -h -p 50
#   tmux send-keys \
#   "printf '\033]2;%s\033\\' 'partner portal'" C-j \
#   'cd ~/code/partner-portal' C-j \
#   'nvm use 10' C-j \
#   'ng serve' C-j \
#   \;
}

function update-app {
  git checkout staging
  git pull
  bundle install
  bin/rails db:migrate RAILS_ENV=development
}
