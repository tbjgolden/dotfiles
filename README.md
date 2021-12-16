# dotfiles

Uses `git --bare` like all the cool kids.

---

```
git clone --bare https://github.com/tbjgolden/dotfiles.git "$HOME/.dotfiles"
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout main
source $HOME/.scripts/sync.zsh
```
