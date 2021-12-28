source $HOME/.scripts/env.zsh

echo -e "\e[1m\e[31mConfiguring git\e[0m"
git config --global user.name "Tom"
git config --global user.email 8162045+tbjgolden@users.noreply.github.com
git config --global pull.rebase false
git config --global core.pager "diff-so-fancy | less --tabs=2 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global color.ui true

git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.func       "146 bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"

if [ `uname` = "Linux" ]; then
  GIT_VERSION=`git --version | xargs`
  GIT_VERSION="${GIT_VERSION:12}"
  sh $HOME/.scripts/lib/semver.sh $GIT_VERSION 2.11.0

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

echo -e "\e[1m\e[31mInstalling and updating packages\e[0m"
if [ `uname` = "Darwin" ]; then
  if ! (( $+commands[brew] )); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  BREW="golang jq woff2 node yarn starship diff-so-fancy"
  CASK="kitty vscodium maccy homebrew/cask-versions/firefox-developer-edition"
  for brew in $( echo $BREW | xargs ); do
    echo -e "\033[0;36m$brew\033[0m"
    brew install -q $brew
  done
  for cask in $( echo $CASK | xargs ); do
    echo -e "\033[0;36m$cask\033[0m"
    brew install --cask -q $cask
  done
elif (( $+commands[pacman] )); then
  echo `sudo ls` > /dev/null;
  PACMAN="git vim base-devel go jq woff2 nodejs yarn starship kitty firefox diff-so-fancy"
  AUR="vscodium-bin"
  for pacman in $( echo $PACMAN | xargs ); do
    echo -e "\033[0;36m$pacman\033[0m"
    sudo pacman -Syu --noconfirm --needed $pacman
  done
  for aur in $( echo $AUR | xargs ); do
    # this probably needs a rewrite
    # to keep and update the git repo instead of redownloading in full
    echo -e "\033[0;36m$aur\033[0m"
    PREV_CWD="$( pwd )"
    mkdir -p "$HOME/.aurCache"
    cd "$HOME/.aurCache"
    if [ ! -d "$aur" ]; then
      git clone "https://aur.archlinux.org/$aur.git"
      cd "$aur"
      makepkg
      sudo pacman -U --noconfirm --needed "$( node $HOME/.scripts/lib/aur.js $aur )"
    fi
    cd $PREV_CWD
  done
else
  echo "Unsupported OS; add install instructions and rerun"
  return 1
fi

echo -e "\e[1m\e[31mUpdating config files\e[0m"
node $HOME/.scripts/lib/updateDotfiles.js
source $HOME/.zshrc
