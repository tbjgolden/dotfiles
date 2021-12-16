DIRNAME=`dirname ${BASH_SOURCE:-$0}`

source $DIRNAME/env.zsh

echo -e "\e[1m\e[31mConfiguring git\e[0m"
git config --global user.name "Tom"
git config --global user.email 8162045+tbjgolden@users.noreply.github.com
git config --global pull.rebase false
if [ `uname` = "Linux" ]; then
  GIT_VERSION=`git --version | xargs`
  GIT_VERSION="${GIT_VERSION:12}"
  sh $DIRNAME/lib/semver.sh $GIT_VERSION 2.11.0

  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -lt 2 ]]; then
    # if git supports libsecret, use it
    git config --global credential.helper libsecret
  elif []; then
    git config --global credential.helper store
  fi
elif [ `uname` = "Darwin" ]; then
  git config --global credential.helper osxkeychain
else
  git config --global credential.helper store
fi

fur config status.showUntrackedFiles no
fur branch --set-upstream-to main &>/dev/null

if [ 1 = 0 ]; then
  echo -e "\e[1m\e[31mInstalling and updating packages\e[0m"
  if [ `uname` = "Darwin" ]; then
    if ! (( $+commands[brew] )); then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    BREW="golang jq woff2 node yarn starship"
    CASK="kitty vscodium maccy homebrew/cask-versions/firefox-developer-edition"
    for brew in $( echo $BREW | xargs ); do
      echo -e "\033[0;36m$brew\033[0m"
      brew install $brew
    done
    for cask in $( echo $CASK | xargs ); do
      echo -e "\033[0;36m$cask\033[0m"
      brew install --cask $cask
    done
  elif (( $+commands[pacman] )); then
    PACMAN="git base-devel go jq woff2 nodejs yarn starship kitty firefox"
    AUR="vscodium-bin"
    for pacman in $( echo $PACMAN | xargs ); do
      echo -e "\033[0;36m$pacman\033[0m"
      sudo pacman -Syu --noconfirm $pacman
    done
    for aur in $( echo $AUR | xargs ); do
      # this probably needs a rewrite
      # to keep and update the git repo instead of redownloading in full
      echo -e "\033[0;36m$aur\033[0m"
      PREV_CWD="$( pwd )"
      rm -rf "$DIRNAME/.tmp"
      mkdir -p "$DIRNAME/.tmp"
      cd "$DIRNAME/.tmp"
      git clone "https://aur.archlinux.org/$aur.git"
      cd "$aur"
      makepkg
      sudo pacman -U --noconfirm "$( node ../../lib/aur.js $aur )"
      cd ../..
      rm -rf .tmp
      cd $PREV_CWD
    done
  else
    echo "Unsupported OS; add install instructions and rerun"
    return 1
  fi
fi

echo -e "\e[1m\e[31mUpdating config files\e[0m"

# create tmp dir
PREV_CWD="$( pwd )"
rm -rf $DIRNAME/.tmp
mkdir -p $DIRNAME/.tmp
cd $DIRNAME/.tmp
# build into tmp dir
cp -Rf $DIRNAME/../.dotfileSrc/all/ .
# cleanup tmp dir
rm -rf $DIRNAME/.tmp
cd $PREV_CWD
