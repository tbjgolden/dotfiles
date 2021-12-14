# ALIASES
alias fur="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

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

# FUNCTIONS
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

# VARIABLES
# PATH="$PATH:"

# CONDITIONAL VARIABLES
if [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
  export ELECTRON_TRASH=kioclient5
fi
