source $HOME/.scripts/env.sh

# if config not set already
git config --global user.name "Tom"
git config --global user.email 8162045+tbjgolden@users.noreply.github.com
git config --global pull.rebase false

if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
  GIT_VERSION=`git --version | xargs`
  GIT_VERSION="${GIT_VERSION:12}"
  echo "$GIT_VERSION"

  sh `dirname ${BASH_SOURCE:-$0}`/lib/semver.sh $GIT_VERSION 2.10.0

  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -lt 2 ]]; then
    git config --global credential.helper libsecret
  elif []; then
    git config --global credential.helper store
  fi
elif [ `uname` = "Darwin" ]; then
  git config --global credential.helper osxkeychain
else
  git config --global credential.helper store
fi

exit 1

fur config status.showUntrackedFiles no

# if upstream not already set
fur push --set-upstream origin main

# if pacman
# should install and update development packages
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

# if macos


# else throw error

###

# expand dotfileSrc, sync changes, user interactive allowing a diff on each file


