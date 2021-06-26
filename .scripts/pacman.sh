PACMAN="jq direnv woff2 nodejs yarn starship vscode kitty firefox"

for pacman in $( echo $PACMAN | xargs ); do
  echo -e "\033[0;36m$pacman\033[0m"
  sudo pacman -Syu --noconfirm $pacman
done
