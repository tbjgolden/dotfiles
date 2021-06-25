BREW="jq direnv woff2 node yarn starship elvish"
CASK="rectangle vscodium kitty firefox"

for brew in $( echo $BREW | xargs ); do
  echo -e "\033[0;36m$brew\033[0m"
  brew install $brew
done

for cask in $( echo $CASK | xargs ); do
  echo -e "\033[0;36m$cask\033[0m"
  brew install --cask $cask
done
