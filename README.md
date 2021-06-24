# dotfiles

Uses `git --bare` like all the cool kids.

---

```
git clone --bare https://github.com/tbjgolden/dotfiles.git "$HOME/.dotfiles"
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout main"

# darwin
dot checkout darwin
# pacman
dot checkout pacman

# commands to push updates to configs with git
dot add
dot commit
dot push
```
