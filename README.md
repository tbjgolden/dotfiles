# dotfiles

Uses `git --bare` like all the cool kids.

---

```
rm -rf $HOME/README.md $HOME/.scripts $HOME/.dotfiles
git clone --bare https://github.com/tbjgolden/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout main
source $HOME/.scripts/sync.zsh
```
