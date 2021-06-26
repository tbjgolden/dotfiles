set -Ux EDITOR vim
set -Ux VISUAL vim
set -Ux BROWSER firefox

alias ga="git add"
alias gcl="git clone"
alias gc="git commit"
alias gr="git reset"
alias gpl="git pull origin"
alias gph="git push origin"
alias gnb="git checkout -b"
alias gs="git status"
alias grnb="git branch -m"

# device specific env
if test -f ~/.fishrc.fish
    source ~/.fishrc.fish
end

starship init fish | source

direnv hook fish | source

