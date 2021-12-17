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

if [ 1 = 0 ]; then
  echo -e "\e[1m\e[31mInstalling and updating packages\e[0m"
  if [ `uname` = "Darwin" ]; then
    if ! (( $+commands[brew] )); then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    BREW="golang jq woff2 node yarn starship diff-so-fancy"
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
    PACMAN="git base-devel go jq woff2 nodejs yarn starship kitty firefox diff-so-fancy"
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
      rm -rf "$HOME/.scripts/.tmp"
      mkdir -p "$HOME/.scripts/.tmp"
      cd "$HOME/.scripts/.tmp"
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
rm -rf $HOME/.scripts/.tmp
mkdir -p $HOME/.scripts/.tmp
cd $HOME/.scripts/.tmp
# build into tmp dir
cp -R ../../.dotfileSrc/all/ .
if [ `uname` = "Darwin" ]; then
  cp -R ../../.dotfileSrc/darwin/ .
elif [ `uname` = "Linux" ]; then
  cp -R ../../.dotfileSrc/linux/ .
  if (( $+commands[pacman] )); then
    cp -R ../../.dotfileSrc/pacman/ .
  else
    echo "Unsupported Linux OS; add equivalent config to .dotfileSrc/pacman"
  fi
fi
# replace references with actual files
IFS=$'\n'
REFERENCES=($( find . -type f -iregex '.*\.reference$' -print0 | xargs -0 -I "{}" echo '"{}"' ))
for reference in $REFERENCES; do
  refname=$reference:t
  refname=${refname[1,-12]}
  refdir=`dirname $reference`'"'
  echo $refdir | xargs rm -rf
  echo $refdir | xargs cp -R ../../.dotfileSrc/references/$refname/
done
IFS=$' \t\n'
# replace references with files
cp -Rn ./ ../../../
# find changed files and prompt user
IFS=$'\n'
FILES=($( find . -type f -print0 | xargs -0 -I "{}" echo '"{}"' ))
for file in $FILES; do
  echo "=========================="
  SRCPATH=$( echo $file | xargs -I '{}' echo '"'{}'"' )
  echo $SRCPATH
  DESTPATH=$( echo $file | xargs -I '{}' echo '"'../../.{}'"' )
  echo $DESTPATH
  return 69

  if ! cmp -s ${DESTPATH[2, -2]} ${SRCPATH[2, -2]}; then
    echo ""
    diff -u ${DESTPATH[2, -2]} ${SRCPATH[2, -2]} | diff-so-fancy | tail -n +4
    result=""
    while [ "$result" != "U" -a "$result" != "u" -a "$result" != "K" -a "$result" != "k" -a "$result" != "M" -a "$result" != "m" ]; do
      echo ""
      vared -p '(U)pdate, (K)eep, (M)erge manually?: ' -c result
    done

    if [ "$result" = "U" -o "$result" = "u" ]; then
      echo "Updating"
      rm ${DESTPATH[2, -2]}
      mv ${SRCPATH[2, -2]} ${DESTPATH[2, -2]}
    elif [ "$result" = "K" -o "$result" = "k" ]; then
      echo "Keeping"
    else
      echo "Manual merge"
      echo "===v=== before ===v===" > ${DESTPATH[2, -2]}.tmp
      cat ${DESTPATH[2, -2]} >> ${DESTPATH[2, -2]}.tmp
      echo "===v=== update ===v===" >> ${DESTPATH[2, -2]}.tmp
      cat ${SRCPATH[2, -2]} >> ${DESTPATH[2, -2]}.tmp
      vim ${DESTPATH[2, -2]}.tmp

      while grep -s "e ===v===" ${DESTPATH[2, -2]}.tmp &>/dev/null; do
        echo ""
        echo "Diff comments remain in the source code, must edit..."
        sleep 3
        vim ${DESTPATH[2, -2]}.tmp
      done

      echo "Manual merge completed"
      rm ${DESTPATH[2, -2]}
      mv ${DESTPATH[2, -2]}.tmp ${DESTPATH[2, -2]}
      rm ${DESTPATH[2, -2]}.tmp
    fi
  fi
done
IFS=$' \t\n'
# cleanup tmp dir
cd ..
rm -rf .tmp
cd $PREV_CWD
