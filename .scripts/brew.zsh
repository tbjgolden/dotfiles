#!/bin/zsh
BREW="jq direnv"
CASK="rectangle vscodium"

for brew in $( echo $BREW | xargs ); do
  echo "\u001b[36m| $brew\u001b[0m"
  brew install $brew
done

for cask in $( echo $CASK | xargs ); do
  echo "\u001b[36m| $cask\u001b[0m"
  brew install --cask $cask
done
