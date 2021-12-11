PACMAN="git base-devel go jq woff2 nodejs yarn starship vscode kitty firefox"
AUR="direnv"

for pacman in $( echo $PACMAN | xargs ); do
  echo -e "\033[0;36m$pacman\033[0m"
  sudo pacman -Syu --noconfirm $pacman
done

for aur in $( echo $AUR | xargs ); do
  echo -e "\033[0;36m$aur\033[0m"
  PREV_CWD="$( pwd )"
  rm -rf "$HOME/.scripts/.tmp"
  mkdir -p "$HOME/.scripts/.tmp"
  cd "$HOME/.scripts/.tmp"
  git clone "https://aur.archlinux.org/$aur.git"
  cd "$aur"
  makepkg
  sudo pacman -U --noconfirm "$( node ../../aur.js $aur )"
  cd ../..
  rm -rf .tmp
  cd $PREV_CWD
done
