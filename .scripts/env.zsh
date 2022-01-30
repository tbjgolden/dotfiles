# ALIASES
alias fur="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

if [ `uname` = "Darwin" ]; then
  alias ls="ls -halG"
else
  alias ls="ls -hal --color=auto"
fi

alias grep='grep --color=auto'

alias pyg="pygmentize -g"

alias ga="git add"
alias gcl="git clone"
alias gc="git commit"
alias gr="git reset"
alias gpl="git pull origin"
alias gph="git push origin"
alias gnb="git checkout -b"
alias gs="git status"
alias grnb="git branch -m"
alias gb="git branch | cat -n"

alias dfs="zsh ~/.scripts/sync.zsh"

# FUNCTIONS
alias gch="gch"
unalias gch
gch() {
  N=$1
  if [[ "$1" == [0-9] || "$1" == [0-9][0-9] ]]; then
    M="$( git branch | sed $N"q;d" )"
    if [[ $( echo "${M:2}" ) ]]; then
      git checkout ${M:2}
    else
      echo "Branch number $1 doesn't exist"
    fi
  else
    git checkout $@
  fi
}
alias gdb="gdb"
unalias gdb
gdb() {
  N=$1
  if [[ "$1" == [0-9] || "$1" == [0-9][0-9] ]]; then
    M="$( git branch | sed $N"q;d" )"
    if [[ $( echo "${M:2}" ) ]]; then
      git branch -D ${M:2}
    else
      echo "Branch number $1 doesn't exist"
    fi
  else
    git branch -D $@
  fi
}
resource() {
  source ~/.scripts/sync.zsh
}

# ZSH SET TITLE
set_win_title() {
  echo -ne "\033]0; zsh $PWD \007"
}
precmd_functions+=(set_win_title)

# VARIABLES
# PATH="$PATH:"

# CONDITIONAL VARIABLES
if (( $+commands[yarn] )); then
  export PATH="$PATH:$( yarn global bin )"
fi

if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
  export ELECTRON_TRASH=kioclient5
fi

if [ `uname` = "Darwin" ]; then
  export PATH="$PATH:/opt/homebrew/bin"
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export JAVA_HOME=`/usr/libexec/java_home`
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi

