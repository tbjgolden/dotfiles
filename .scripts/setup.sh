# source setup.sh
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dot checkout main
dot config status.showUntrackedFiles no
