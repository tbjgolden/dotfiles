# dotfiles

Uses `git --bare` like all the cool kids.

---

```
# clone
git clone --bare https://github.com/tbjgolden/dotfiles.git "$HOME/.dotfiles"
# install (remove files that collide)
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout <darwin|pacman>
# setup repo and add `dot` alias
source $HOME/.scripts/setup.sh
```
