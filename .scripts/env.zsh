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

alias hs='history | grep'
alias hsi='history | grep -i'

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
alias resource="resource"
unalias resource
resource() {
  source ~/.scripts/env.zsh
}
updot() {
  node $HOME/.scripts/lib/updateDotfiles.js
  source ~/.scripts/env.zsh
}
find_big() {
  du -a . | sort -n -r | head -n 40
}
alias conventional="conventional"
unalias conventional
conventional() {
  echo "fix: A bug fix"
  echo "feat: A new feature"
  echo "build: Changes that affect the build system or external dependencies"
  echo "chore: No production code change and not covered by another tag"
  echo "ci: Changes to our CI configuration files and scripts"
  echo "docs: Documentation only changes"
  echo "style: Code-style changes (whitespace, prettier)"
  echo "refactor: A code change that neither fixes a bug nor adds a feature"
  echo "perf: A code change that improves performance"
  echo "test: Adding missing tests or correcting existing tests"
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

